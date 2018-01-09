function [Wbest,YZmv,lnL,initMethod,convTime,initTime,Wall]=modelSearchFixedSize(varargin)
% [Wbest,YZmv,lnL,initMethod,convTime,initTime,Wall]=modelSearchFixedSize('P1',P1,...)
% Simple model search for a fixed number of diffusive states: generates and
% converges models with random initial parameters and a few different
% initial guesses for q(S) and/or q(Y,Z). Mainly inteneded as a lower-level
% part of YZShmm.modelSearch. 
%
% Input parameters are given as parameter-value pairs on the form
% 'parameter',parameter (case sensitive). 
% N0    : Number of hidden states (model size) to search within.
% iType : type of learning {'mle','vb'} (maximum likeihood, variational
%         Bayes). Default: N.A. 
% opt   : options struct or name of runinput file.
%
% Further optional parameters, take precedence over the corresponding
% options in the opt struct in applicable cases:
% classFun    : YZhmm model constructor handle (e.g. @YZShmm.dXt).
%               Default: opt.model.class
% data  : data struct from spt.preprocess.
%         Default: read from from opt.trj.inputfile
% YZww  : list of window widths (radii) for q(Y,Z) moving average diffusion
%         filter, positive integers. Default: opt.modelSearch.YZww
% restarts : number of independent restarts. restarts=0 only computes
%         moving average q(Y,Z) distributions.
%         Default opt.modelSearch.restarts
% qYZ0  : precomputed q(Y,Z) distribution(s) to include as initial guesses,
%         either as a single YZ subfield, or as a cell vector of YZ
%         subfields. Default {} (no pre-computed YZ distributions used).
% allInit : if true, a larger set of model initializations are included in
%           addition to the moving averages approach described by the YZww
%           parameter, and the pre-computed ones (qYZ0). The additional
%           ones seem to be less efficient, so the recommendation is false
%           (but default is true, for now).
% displayLevel : display level. Default 1.
%
% output
% Wbest : the best converged model
% YZmv      : moving averages YZ structs (for later reuse).
% lnL       : all converged lower bound values
% initMethod: cell vector of initialization method names
% convTime  : convergence times of all initialization attempts.
% initTime  : preprocessing time for the various initialization methods
%             (only non-zero for moving average YZ models).
% Wall      : all converged models considered in the fit. This is a memory
%             intensive output, and not recommended if the number of
%             restarts is large.

%% parameters and default values

warning('modelSearchFixedSize with default allInit=true')
allInit=true; % if false, exclude all but running averages (YZww) and precomputed YZ model (qYZ0).

% get options
kOpt=2*find(strcmp('opt',varargin(1:2:end)),1);
opt=varargin{kOpt};
opt=spt.readRuninputFile(opt);
% two parameters without default values
N0=[];
iType=[];
% defaults
classFun=eval(['@' opt.model.class]);
data=[];
YZww=opt.modelSearch.YZww;
qYZ0={};
displayLevel=1;
restarts=opt.modelSearch.restarts;
% input parameters
parNames={'opt','N0','iType','classFun','data','YZww','qYZ0','displayLevel','restarts','allInit'};
for k=1:2:numel(varargin)
    if(isempty(find(strcmp(varargin{k},parNames),1)))
        error(['Parameter ' varargin{k} ' not recognized.'])
    end
    eval([varargin{k} '=varargin{ ' int2str(k+1) '};'])
end

if(isempty(data))
    data=spt.preprocess(opt);
end
% test itertions before heavy computing starts
W=classFun(N0,opt,data);
W.YZiter(data,iType);
clear W;
% more parameters
Pwarmup=opt.modelSearch.Pwarmup;
dt=opt.trj.timestep;
% Wall output requested or not?
if(nargout>=7)
    doWall=true;
else
    doWall=false;
end
%% start computing

% small variance data
X0=data;
if(isfield(X0,'v') && ~isempty(X0.v))
    X0.v=1e-6*X0.v;
else % use rough SNR instead
    X0.v=1e-6*mean(median(diff(X0.x).^2,'omitnan'))*ones(size(X0.x));
    X0.v(isnan(X0.x))=nan;
end

% precompute moving average q(Y,Z) distributions
if(~exist('YZww','var') || isempty(YZww))
    YZww=[];
    YZmv={};
    initTime=[];
elseif(isreal(YZww)) % then compute moving average initializations
    YZmv=cell(size(YZww));
    initTime={};
    parfor k=1:numel(YZww)
        %for k=1:numel(YZww)
        tic
        if(isfield(data,'v'))
            YZmv{k}=mleYZdXt.YZinitMovingAverage(data,YZww(k),3e-2,opt.trj.shutterMean,opt.trj.blurCoeff,dt);
        else
            YZmv{k}=mleYZdXs.YZinitMovingAverage(data,YZww(k),3e-2,opt.trj.shutterMean,opt.trj.blurCoeff,dt);
        end
        YZmv{k}.initMethod=['yzF(' int2str(YZww(k)) ')S'];
        initTime{k}=toc;
    end
    initTime=[initTime{:}];
    if(displayLevel>=2)
        disp(['YZfilters [ ' int2str(YZww) ' ] computed in [ ' num2str(initTime,3) ' ] s.']);
    end
end
if(allInit) % allInit adds 5 extra initializations
    initTime=[initTime zeros(1,5)];
end

% precomputed YZ structs
if(~isempty(qYZ0))
    if(isstruct(qYZ0))
        qYZ0={sZ0};
    end
    initTime=[initTime zeros(1,numel(qYZ0))];
else
    qYZ0={};
end
%% independent restarts
W=cell(1,restarts);         % best model from every restart
WlnL=cell(1,restarts);      % cell vectors of lnL values
WCtime=cell(1,restarts);    % convergence times
Wallrm=cell(1,restarts);    % all encountered models
initMethod={};
if(restarts<=0 || (isempty(YZww) && isempty(qYZ0) && ~allInit) )
    % nothing to be computed
    Wbest=struct;
    lnL=[];
    convTime=[];
    if(doWall)
        Wall={};
    end
elseif(restarts>0)
    parfor r=1:restarts
        %%% warning('modelSearchFixedSize without parfor')
        %%% for r=1:restarts
        V0=classFun(N0,opt,data); % model, data, and initial parameter guess
        initMethod{r}={};
        m=0;
        W{r}=struct('lnL',-inf);
        WlnL{r}={};
        WCtime{r}={};
        if(doWall)
            Wallrm{r}={};
        end
        %% YZfilter
        for k=1:numel(YZww)
            m=m+1;tic;
            initMethod{r}{m}=['yzF(' int2str(YZww(k)) ')S'];
            V=V0.clone();
            V.YZ=YZmv{k};
            V.Siter(data,iType);
            V.converge(data,'displayLevel',displayLevel-2,'PSYwarmup',[Pwarmup 0 0],'minIter',Pwarmup+2,'iType',iType,'Dsort',true);
            WlnL{r}{m}=V.lnL;
            V.comment=['init N=' int2str(V.numStates) ' ' initMethod{r}{m}];
            if(V.lnL>W{r}.lnL)
                W{r}=V;
            end
            if(doWall)
                Wallrm{r}{m}=V.clone();
            end
            WCtime{r}{m}=toc;
            if(displayLevel>=2)
                V.EMexit.init=V.comment;
                disp(V.EMexit);
                disp('----------')
            end
        end
        %% pre-computed YZ structs
        for k=1:numel(qYZ0)
            m=m+1;tic;
            if(isfield(qYZ0{k},'initMethod'))
                initMethod{r}{m}=qYZ0{k}.initMethod;
            else
                initMethod{r}{m}=['YZ0(' int2str(k) ')S'];
            end
            V=V0.clone();
            V.YZ=qYZ0{k};
            V.Siter(data,iType);
            V.converge(data,'displayLevel',displayLevel-2,'PSYwarmup',[Pwarmup 0 0],'minIter',Pwarmup+2,'iType',iType,'Dsort',true);
            WlnL{r}{m}=V.lnL;
            V.comment=['init N=' int2str(V.numStates) ' ' initMethod{r}{m}];
            if(V.lnL>W{r}.lnL)
                W{r}=V;
            end
            if(doWall)
                Wallrm{r}{m}=V.clone();
            end
            WCtime{r}{m}=toc;
            if(displayLevel>=2)
                try
                    V.EMexit.init=V.comment;
                    disp(V.EMexit);
                    disp('----------')
                catch me
                    warning('Cannot display EMexit/comment with pre-computed models.')
                end
            end
        end
        %% less efficient initializations
        if(allInit)
            %% Suniform : q(S) = uniform
            m=m+1;tic;
            initMethod{r}{m}='uniformS';
            V=V0.clone();
            V.YZiter(data,iType);
            try
                V.converge(data,'displayLevel',displayLevel-2,'PSYwarmup',[Pwarmup 0 0],'minIter',Pwarmup+2,'iType',iType,'Dsort',true);
                WlnL{r}{m}=V.lnL;
                V.comment=['init N=' int2str(V.numStates) ' ' initMethod{r}{m}];
                if(V.lnL>W{r}.lnL)
                    W{r}=V;
                end
                if(doWall)
                    Wallrm{r}{m}=V.clone();
                end
                if(displayLevel>=2)
                    V.EMexit.init=V.comment;
                    disp(V.EMexit);
                    disp('----------')
                end
            catch me
                me
                WlnL{r}{m}=nan;
            end
            WCtime{r}{m}=toc;
            %% YZdata   : q(Y,Z) = data
            m=m+1;tic;
            initMethod{r}{m}='YZdata';
            V=V0.clone();
            V.Siter(data,iType);
            V.converge(data,'displayLevel',displayLevel-2,'PSYwarmup',[Pwarmup 0 0],'minIter',Pwarmup+2,'iType',iType,'Dsort',true);
            WlnL{r}{m}=V.lnL;
            V.comment=['init N=' int2str(V.numStates) ' ' initMethod{r}{m}];
            if(V.lnL>W{r}.lnL)
                W{r}=V;
            end
            if(doWall)
                Wallrm{r}{m}=V.clone();
            end
            WCtime{r}{m}=toc;
            if(displayLevel>=2)
                V.EMexit.init=V.comment;
                disp(V.EMexit);
                disp('----------')
            end
            %% YZnbeInit: start w YZdata but with low error and blur
            m=m+1;tic;
            initMethod{r}{m}='YZnbe';
            % first one conergence round with small errors in the data
            opt0=opt;
            opt0.trj.shutterMean=1e-2;
            opt0.trj.blurCoeff=1e-2/3;
            V1=classFun(N0,opt0,X0);
            V1.YZ.varZ=zeros(size(V1.YZ.varZ));
            V1.YZ.varY=zeros(size(V1.YZ.varY));
            
            V1.Siter(X0,iType);
            % converge with fixed YZ model with no variances
            V1.converge(X0,'displayLevel',displayLevel-2,'Dsort',false,'iType',iType,'PSYfixed',3,'Dsort',true)%,'PSYwarmup',25);
            V=V0.clone(); % now go back to original data
            V.S=V1.S;     % but keep hidden states and parameters from V1
            V.P=V1.P;
            V.YZiter(data,iType);
            V.Piter(data,iType);
            V.converge(data,'displayLevel',displayLevel-2,'PSYwarmup',[Pwarmup 0 0],'minIter',Pwarmup+2,'iType',iType,'Dsort',true);
            WlnL{r}{m}=V.lnL;
            V.comment=['init N=' int2str(V.numStates) ' ' initMethod{r}{m}];
            if(V.lnL>W{r}.lnL)
                W{r}=V;
            end
            if(doWall)
                Wallrm{r}{m}=V.clone();
            end
            WCtime{r}{m}=toc;
            if(displayLevel>=2)
                V.EMexit.init=V.comment;
                disp(V.EMexit);
                disp('----------')
            end
        end
        %% look for winner for this particular initial condition
        this_lnL=[ WlnL{r}{:}];
        [this_lnLmax,b]=max(this_lnL);
        lnL_sort=-sort(-this_lnL);
        if(numel(lnL_sort)>1)
            dlnLrel=(this_lnLmax-lnL_sort(2))*2/abs(this_lnLmax+lnL_sort(2));
        else
            dlnLrel=nan;
        end
        if(displayLevel>1)
            fprintf('Round %d winner: %s dlnLrel = %0.1e.\n',r,initMethod{r}{b},dlnLrel);
        end
    end
    lnL=[WlnL{1}{:}];
    convTime=[WCtime{1}{:}];
    initMethod=initMethod{1};
    
    Wbest=struct('lnL',-inf);
    bestIter=nan;
    for r=1:restarts
        lnL(r,:)=[WlnL{r}{:}];
        convTime(r,:)=[WCtime{r}{:}];
        if(W{r}.lnL>Wbest.lnL)
            Wbest=W{r};
            bestIter=r;
            [~,bestInit]=max(lnL(r,:));
        end
    end
    Wbest.sortModel();
    Wbest=Wbest.clone(); % sewer ties to earlier models
    if(displayLevel>0)
        fprintf('modelSearch done. Init %s, round %d.\n',initMethod{bestInit},bestIter);
    end
    if(doWall)
        Wall={};
        m=0;
        for r=1:restarts
            for m=1:numel(Wallrm{r})
                Wall{end+1}=Wallrm{r}{m};
            end
        end
    end
end
% to do: save correlation btw method and lnL


