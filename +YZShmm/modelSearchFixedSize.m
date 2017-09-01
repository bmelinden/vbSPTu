function [Wbest,lnL,initMethod,convTime,initTime,YZmv]=modelSearchFixedSize(classFun,N0,opt,X,iType,YZww,Nrestarts,YZ0,nDisp)
% [Wbest,lnL,initMethod,convTime,initTime,YZmv]=...
%      YZShmm.modelSearchFixedSize(classFun,opt,X,N0,iType,YZww,Nrestarts,YZ0,nDisp)
%
% classFun : YZhmm model constructor handle (e.g. @YZShmm.dXt)
% N0    : model size to search for
% opt   : options struct
% X     : data struct from spt.preprocess
% iType : type of learning {'mle','map','vb'} (maximum likeihood, maximum
%         aposteriori, variational Bayes).
% --- optional ---
% YZww  : list of smoothing radii for q(Y,Z) moving average diffusion
%         filter. Default [] (no YZ filtering used in the search).
% Nrestarts : number of independent restarts. Nrestarts=0 only computes
%             moving average q(Y,Z) distributions. Default 1.
% YZ0   : precomputed q(Y,Z) distribution(s) to include as initial guesses,
%         either as a single YZ
%         subfield, or as a cell vector of YZ subfields. Default {} (no
%         pre-computed YZ distributions used). 
% nDisp : display level, ~as for vbYZdXt.converge, default 0.
% 
% output
% Wbest : the best converged model
% lnL   : all converged lower bound values
% initMethod: cell vector of initialization method names
% convTime  : convergence times of all initialization attempts.
% initTime  : preprocessing time for the various initialization methods
%             (only non-zero for moving average YZ models).
% YZmv      : moving averages YZ structs (to make it possible to reuse
%             them). 

% search parameters

% test non-opptional parameters
W=classFun(N0,opt,X);
W.YZiter(X,iType);
clear W;

Nwu=10;
dt=opt.trj.timestep;
if(~exist('Nrestarts','var') || isempty(Nrestarts))
    Nrestarts=1;
end
if(~exist('nDisp','var') || isempty(nDisp))
    nDisp=0;
end

% small variance data
X0=X;
warning('cannot assume data with variances')
X0.v=1e-6*X0.v;
cDisp=0;
% precompute moving average q(Y,Z) distributions
if(~exist('YZww','var') || isempty(YZww))
    YZww=[];
    YZmv={};
    initTime=[];
elseif(isreal(YZww)) % then compute moving average initializations
    YZmv=cell(size(YZww));
    initTime={};
    parfor k=1:numel(YZww)
        tic
        YZmv{k}=mleYZdXt.YZinitMovingAverage(X,YZww(k),3e-2,opt.trj.shutterMean,opt.trj.blurCoeff,dt);
        initTime{k}=toc;
    end
    initTime=[initTime{:}];    
    if(cDisp>0)
        disp(['YZfilters [ ' int2str(YZww) ' ] computed in [ ' num2str(initTime,3) ' ] s.']);
    end
end
initTime=[initTime zeros(1,5)];

% precomputed YZ structs
if(exist('YZ0','var') && ~isempty(YZ0))
    if(isstruct(YZ0))
        YZ0={YZ0};
    end
    initTime=[initTime zeros(1,numel(YZ0))];
else
    YZ0={};
end

% independent restarts
W=cell(1,Nrestarts);
WlnL=cell(1,Nrestarts);
WCtime=cell(1,Nrestarts);
initMethod={};
if(Nrestarts>0)
parfor r=1:Nrestarts
%%%for r=1:Nrestarts
    V0=classFun(N0,opt,X); % model, data, and initial parameter guess
    
    initMethod{r}={};    
    m=0;
    W{r}=struct('lnL',-inf);
    WlnL{r}={};
    WCtime{r}={};
    %% YZfilter
    for k=1:numel(YZww)
        m=m+1;tic;
        initMethod{r}{m}=['yzF(' int2str(YZww(k)) ')S'];
        V=V0.clone();
        V.YZ=YZmv{k};
        V.Siter(X,iType);
        V.converge(X,'display',nDisp,'SYPwarmup',[0 0 Nwu],'minIter',Nwu+2,'iType',iType);
        WlnL{r}{m}=V.lnL;
        V.comment=initMethod{r}{m};
        if(V.lnL>W{r}.lnL)
            W{r}=V;
        end
        WCtime{r}{m}=toc;
        if(cDisp>0)
            V.EMexit.init=V.comment;disp(V.EMexit);
            disp('----------')
        end
    end
    %% pre-computed YZ structs
    for k=1:numel(YZ0)
        m=m+1;tic;
        initMethod{r}{m}=['YZ0(' int2str(k) ')S'];
        V=V0.clone();
        V.YZ=YZ0{k};
        V.Siter(X,iType);
        V.converge(X,'display',nDisp,'SYPwarmup',[0 0 Nwu],'minIter',Nwu+2,'iType',iType);        
        WlnL{r}{m}=V.lnL;
        V.comment=initMethod{r}{m};
        if(V.lnL>W{r}.lnL)
            W{r}=V;
        end
        if(cDisp>0)
            V.EMexit.init=V.comment;disp(V.EMexit);
            disp('----------')
        end
        WCtime{r}{m}=toc;
    end
    %% Suniform : q(S) = uniform
    m=m+1;tic;
    initMethod{r}{m}='uniformS';
    V=V0.clone();
    V.YZiter(X,iType);
    try
        V.converge(X,'display',nDisp,'SYPwarmup',[0 0 Nwu],'minIter',Nwu+2,'iType',iType);
        WlnL{r}{m}=V.lnL;
        V.comment=initMethod{r}{m};
        if(V.lnL>W{r}.lnL)
            W{r}=V;
        end
        if(cDisp>0)
            V.EMexit.init=V.comment;disp(V.EMexit);
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
    V.Siter(X,iType);
    V.converge(X,'display',nDisp,'SYPwarmup',[0 0 Nwu],'minIter',Nwu+2,'iType',iType);
    WlnL{r}{m}=V.lnL;
    V.comment=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    if(cDisp>0)
        V.EMexit.init=V.comment;disp(V.EMexit);
        disp('----------')
    end
    %% YZne     : q(Y,Z) = data, low errors    
    m=m+1;tic;
    initMethod{r}{m}='YZneS';
    V1=classFun(N0,opt,X0);
    V=V0.clone();
    V.YZ=V1.YZ; % initial guess created from X0 data
    V.Siter(X,iType);
    V.converge(X,'display',nDisp,'SYPwarmup',[0 0 Nwu],'minIter',Nwu+2,'iType',iType);    
    WlnL{r}{m}=V.lnL;
    V.comment=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    if(cDisp>0)
        V.EMexit.init=V.comment;disp(V.EMexit);
        disp('----------')
    end
    %% YZnbeInit: start w YZdata but with low error and blur
    m=m+1;tic;
    initMethod{r}{m}='SPnbe';
    % first one conergence round with small errors in the data
    opt0=opt;
    opt0.shutterMean=1e-2;
    opt0.blurCoeff=1e-2/3;
    V1=classFun(N0,opt0,X0);
    V1.Siter(X0,iType);
    V1.converge(X0,'display',nDisp,'Dsort',false,'iType',iType);
    V=V0.clone(); % now go back to original data
    V.S=V1.S;
    V.P=V1.P;
    V.YZiter(X,iType);
    V.Piter(X,iType);
    V.converge(X,'display',nDisp,'SYPwarmup',[0 0 0],'iType',iType);
    WlnL{r}{m}=V.lnL;
    V.comment=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    if(cDisp>0)
        V.EMexit.init=V.comment;disp(V.EMexit);
        disp('----------')
    end
    %% YZnbeInit: start w YZdata but with low error and blur, reser params
    m=m+1;tic;
    initMethod{r}{m}='Snbe';
    V=V0.clone();
    V.S=V0.S;
    V.YZiter(X,iType);
    V.Piter(X,iType);
    V.converge(X,'display',nDisp,'SYPwarmup',[0 0 0],'iType',iType);
    WlnL{r}{m}=V.lnL;
    V.comment=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    if(cDisp>0)
        V.EMexit.init=V.comment;disp(V.EMexit);
        disp('----------')
    end
    %% look for winner for this particular initial condition
    this_lnL=[ WlnL{r}{:}];
    [this_lnLmax,b]=max(this_lnL);
    lnL_sort=-sort(-this_lnL);
    fprintf('round %d winner: %s dlnL = %0.1e.\n',r,initMethod{r}{b},this_lnLmax-lnL_sort(2));
end
lnL=[WlnL{1}{:}];
convTime=[WCtime{1}{:}];
initMethod=initMethod{1};
Wbest=W{1};
for r=2:Nrestarts
    lnL(r,:)=[WlnL{r}{:}];
    convTime(r,:)=[WCtime{r}{:}];
    if(W{r}.lnL>Wbest.lnL)
        Wbest=W{r};
    end
end
Wbest.sortModel();
Wbest=Wbest.clone(); % sewer ties to earlier models
else
    Wbest=struct;
    lnL=[];
    convTime=[];
end
% to do: save correlation btw method and lnL


