function [Wbest,WbestN,lnL,IINlnL,P,qYZmv]=modelSearch(varargin)
% [Wbest,WbestN,lnL,IINlnL,P,qYZmv]=YZShmm.modelSearch('P1',P1,...)
% A greedy multi-size model search algorithm that 
% 1) only compares models of equal size, and hence work for VB and MLE (but
%    MLE may not be stable when over-fitting). 
% 2) detects and discards 'clone states', i.e., diffusive states with
%    identical hidden state occupancy patterns, which is a sign of
%    effectively empty state.
% 3) uses a width-first greedy search all the way down to N=1-state models,
%    as implemented in YZShm.YZS0.greedyReduce.m
%
% Input parameters are given as parameter-value pairs on the form
% 'parameter',parameter (case sensitive):
% opt   : options struct or runinputfile name
% optional additional arguments, take precedence over the corresponding
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
% iType : Type of iterations to use {'mle','vb'}. Default: vb.
% qYZ0  : precomputed q(Y,Z) distribution(s) to include as initial guesses,
%         either as a single YZ subfield, or as a cell vector of YZ
%         subfields. Default {} (no pre-computed YZ distributions used).
% Winit : cell vector of converged models to include in the comparison
%         (e.g., result of an earlier model search).
% displayLevel : display level. Default 1.
%
% output: 
% Wbest : the best converged model
% WbestN: best converged models of each size ( or a struct with field
%         lnL=-inf, if the search did not get to small enough model sizes).
% lnL   : The highest lnL-values for each model size; lnL(k)=WbestN{k}.lnL
% IINlnL: Iteration-, initial model, model size, and lnL- value for each
%          model encountered during the greedy search. 
% P     : Parameter struct (using the getParameters method) for each model
%         encountered during the greedy search.
% 
% qYZmv : moving averages YZ structs for later reuse. To use in other
% models, simply replace the YZ field and reconverge (starting with Siter
% or Piter to propagate the effects of the new YZ model).

% ML 2018-01-02
%% parameters and defaults
% get options first
kOpt=2*find(strcmp('opt',varargin(1:2:end)),1);
opt=varargin{kOpt};
opt=spt.readRuninputFile(opt);
% default values
restarts=opt.modelSearch.restarts;
classFun=eval(['@' opt.model.class]);
maxHidden  =opt.modelSearch.maxHidden;
if(isfield(opt.modelSearch,'VBinitHidden'))
    VBinitHidden = opt.modelSearch.VBinitHidden;
else
   warning('Missing  opt.modelSearch.VBinitHidden, using opt.modelSearch.maxHidden instead.')
   VBinitHidden=maxHidden;
end
YZww=opt.modelSearch.YZww;
data=[];
qYZ0={};
Winit={};
displayLevel=1;
iType='vb';
% additional input parameters
parNames={'opt','classFun','data','YZww','qYZ0','displayLevel','restarts','Winit','iType'};
for k=1:2:numel(varargin)
    if(isempty(find(strcmp(varargin{k},parNames),1)))
        error(['Parameter ' varargin{k} ' not recognized.'])
    end
    eval([varargin{k} '=varargin{ ' int2str(k+1) '};'])
end
if(~iscell(qYZ0))
    qYZ0={qYZ0};
end
%% start message
tstart=tic;
% display some starting information
uSPTlicense(mfilename)
disp('----------')
disp(['Restarts     : ' int2str(restarts )])
disp(['Max states   : ' int2str(maxHidden)])
%disp(['Init states  : ' int2str(VBinitHidden)])

if(isempty(data))
    data=spt.preprocess(opt);
    disp(['runinput file: ' opt.runinputfile])
    disp(['input  file  : ' opt.trj.inputfile])
end
disp(['Num. trj     : ' int2str(numel(data.T))])
disp(['Num. steps   : ' int2str(sum(  data.T-1))])
disp([ datestr(now) ' : Starting ' iType ' greedy model search.'])
disp('----------')

% test parameters
W=classFun(maxHidden,opt,data);
W.YZiter(data,iType);
clear W;
% pre-compute moving average initial guesses
[~,qYZmv]=YZShmm.modelSearchFixedSize('classFun',classFun,'N0',1,'opt',opt,...
    'data',data,'iType',iType,'YZww',YZww,'displayLevel',0,'restarts',1);
qYZ0=[qYZ0,qYZmv];
%% greedy search 
WbestNiter  =cell(1,restarts); % best model of each size in each run
Niter  =cell(1,restarts); % from all models generated in each run
lnLiter=cell(1,restarts); % from all models generated in each run
Piter  =cell(1,restarts); % from all models generated in each run
parfor iter=1:restarts+(~isempty(Winit))
%%% warning('debugging without parfor')
%%% for iter=1:restarts+(~isempty(Winit))
    % Greedy search strategy is probably more efficient than independent
    % searches at each model size. We simply start with a large model, and 
    % systematically remove states looking for the best model of every
    % size. 
    % 2017-12-28 : numerical experiments suggest the best many-state model
    % (say N=30) is not always reduced to the best low-state model. So, all
    % high-state initial models should be used for greedy search.
    titer=tic;
    if(iter==1 && ~isempty(Winit))
        % first iteration based on supplied models, if available
        if(~iscell(Winit))
            Winit={Winit};
        end
        W0i=cell(size(Winit));
        for k=1:numel(Winit)
            %w=eval([opt.model.class '(' int2str(Winit{k}.numStates) ',opt)']);
            w=classFun(Winit{k}.numStates,opt);
            P0=w.P0;
            w=Winit{k}.clone();
            w.P0=P0;
            w.converge( data,'iType',iType,'PSYwarmup',[-1 0 0 ],'displayLevel',displayLevel-2);
            W0i{k}=w.clone();
        end
    else
        % generate a set of large-N models started from the same random parameters
        [~,~,~,~,~,~,W0i]=YZShmm.modelSearchFixedSize('classFun',classFun,'N0',VBinitHidden,'opt',opt,...
            'data',data,'iType',iType,'qYZ0',qYZ0,'YZww',[],'displayLevel',displayLevel-2,'restarts',1);
    end
    % reduce all W0i and keep the best of each size
    WbestNiter{iter}=cell(1,opt.modelSearch.maxHidden);
    lnLiter{iter}={};
    Niter{iter}={};
    Piter{iter}={};
    for mm=1:numel(W0i)
        if(displayLevel>=2)
            disp(['greedy reduction search: iter ' int2str(iter) ...
                ', init ' int2str(mm) ' (' W0i{mm}.comment ').'])
        end
        % greedy searchfrom each initial model
        [~,W0Ni,lnL0i,N0i,P0i]=W0i{mm}.greedyReduce(data,opt,displayLevel-2);
        lnLiter{iter}{end+1}=lnL0i;
        Niter{iter}{end+1}=N0i;

        %for j=1:numel(P0i)
        %    P0i(j).comment=W0i{mm}.comment;
        %end
        Piter{iter}{end+1}=P0i;
        % keep only the best model of each size
        for nn=1:numel(W0Ni)
            if(strcmp(class(W0Ni{nn}),opt.model.class))
                Ni=W0Ni{nn}.numStates;                       
                if(Ni<=opt.modelSearch.maxHidden && ...
                        (isempty(WbestNiter{iter}{Ni}) || W0Ni{nn}.lnL>WbestNiter{iter}{Ni}.lnL))
                    WbestNiter{iter}{Ni}=W0Ni{nn}.clone();
                end
            end
        end
    end
    % warning if maxHidden is too small
    lnLbestIter=-inf(1,opt.modelSearch.maxHidden);
    NbestIter=1:opt.modelSearch.maxHidden;
    for nn=1:opt.modelSearch.maxHidden
        if(~isempty(WbestNiter{iter}{nn}))
            lnLbestIter(nn)=WbestNiter{iter}{nn}.lnL;
        end
    end
    [~,NbestIter]=max(lnLbestIter);
    if(NbestIter==maxHidden)
        warning(['greedyReduce found ' int2str(maxHidden) ' states, which is maximum. Consider increasing opt.modelSearch.maxHidden .'])
    end
    
    if(displayLevel>=2)
        disp(['modelSearch iter ' int2str(iter) ' finished in '  ...
            num2str(toc(titer)) ' s, with ' int2str(NbestIter) ...
            ' states from ' WbestNiter{iter}{NbestIter}.comment] )
    end
end
%% collect the results
% best models
WbestN=cell(1,maxHidden);
lnL=-inf(1,maxHidden);
for k=1:maxHidden
    for iter=1:restarts
        if(~isempty(WbestNiter{iter}{k}) && WbestNiter{iter}{k}.lnL>lnL(k))
            WbestN{k}=WbestNiter{iter}{k}.clone();
            lnL(k)=WbestN{k}.lnL;
        end
    end
end
% some history of all models encountered during search
IINlnL=[];
P=[];
for iter=1:restarts
    for init=1:numel(lnLiter{iter})  
        ind=Niter{iter}{init}<=maxHidden;
        M=sum(ind);
        IINlnL0=[iter*ones(M,1) init*ones(M,1) ...
            reshape(Niter{iter}{init}(ind),M,1) ...
            reshape(lnLiter{iter}{init}(ind),M,1) ];
        P    =[P  Piter{iter}{init}(ind)];
        IINlnL=[IINlnL;IINlnL0] ;
    end
end
clear Piter Niter lnLiter
[~,b]=max(IINlnL(:,4));
bestIter=IINlnL(b,1);
bestInit=IINlnL(b,2);

% best overall model
[~,Nbest]=max(lnL);
Wbest=WbestN{Nbest}.clone();
% display final result
if(displayLevel>=1)
        fprintf([datestr(now) ' : modelSearch found ' int2str(Wbest.numStates) ' states in ' num2str(toc(tstart)/60,2) ' min, '])
    if(bestIter==1 && ~isempty(Winit))
        fprintf(['from Winit{' int2str(bestInit) '}, ' Wbest.comment '.\n'])
    else
        fprintf(['from iter ' int2str(bestIter) ', ' Wbest.comment '.\n'])
    end
end
