function [Pbs,Pmean,Pstd,P0,lnL]=bootstrap(W0,X,iType,Nbs,varargin)
% [Pbs,Pmean,Pstd,P0,lnL]=YZShmm.bootstrap(W0,X,iType,Nbs,...)
% Bootstrap estimates of model parameters and log likelihood. 
%
% W0    : YZShmm model or cell vector of models (pre-converged)
% X     : data corresponding to W0
% iType : {'mle','map','vb'} sets the type of iterations
% Nbs   : number of bootstrap samples to evaluate.
% displayLevel : amount of computational details to write to the command
%                line. Integer>=0, 0=no output (default), then increasingly
%                more output with increasing level.
% Dsort : sort bootstrap models according to increasing diffusoion constant
%         (default: false).

% output:
% Pbs   : bootstrap parameters, P{n}.X(:,:,j) are parameter X, bootstrap
%         round j, model n. 
% Pmean : mean bootstrap parameters, Pmean{n}.X = mean(P{n}.X,3);
% Pstd  : bootstrap parameter std,   Pstd{n}.X  =  std(P{n}.X,[],3);
% P0    : parameter values of input models (for comparison)
% lnL   : lnL(n,j)=P{n}.lnL(1,1,j), may be convenient for model selection
%         statistics 
%
% ML 2017-09-27

%% parameters
displayLevel=0;
Dsort=false;
% additional input parameters
parNames={'displayLevel','Dsort'};
for k=1:2:numel(varargin)
    if(isempty(find(strcmp(varargin{k},parNames),1)))
        error(['Parameter ' varargin{k} ' not recognized.'])
    end
    eval([varargin{k} '=varargin{ ' int2str(k+1) '};'])
end
% put W0 in cell vector if not already 
if(~iscell(W0) )
    if(~iscell(W0))
        Winput=W0;
        W0=cell(size(Winput));
        for k=1:numel(Winput)
            W0{k}=Winput(k);
        end
    end
    clear Winput;
end
%% set up Hiter
lnLiter=cell(Nbs,1);
Piter  =cell(Nbs,1);
Ntrj=numel(X.i0); % number of trajectories
% loop over data partitions
parfor iter=1:Nbs
%%%for iter=1:Nbs
    lnLiter{iter}=zeros(1,numel(W0));
    Piter{iter}=cell(1,numel(W0));
    % partition data set and models
    ii=sort(ceil(Ntrj*rand(1,Ntrj)));
    % loop over models
    for m=1:numel(W0)
        [Wbs,Xbs]=W0{m}.splitModelAndData(X,ii);
        % start bootstrap convergence with a parameter update, since S,YZ
        % are supposedly already converged. Also makes robust towards
        % iType-switching.
        Wbs.converge(Xbs,'iType',iType,'PSYwarmup',[-1 0 0 ],'displayLevel',displayLevel-1,'Dsort',Dsort);
        lnLiter{iter}(m)=Wbs.lnL;
        Piter{iter}{m}  =Wbs.getParameters(Xbs,iType);
    end
    if(displayLevel>=1)
       disp(['Finished bootstrap round ' int2str(iter) ' of ' int2str(Nbs) '.'])
    end
end
% reorganize parameters
% alternative parameter organization
Pbs  =cell(1,numel(W0));
Pmean=cell(1,numel(W0));
Pstd =cell(1,numel(W0));
lnL=zeros(Nbs,numel(W0));
for m=1:numel(W0)
    P0{m}=W0{m}.getParameters(X,iType);
    Pbs{m}    =Piter{1}{m};
    Pmean{m}=Piter{1}{m};
    Pstd{m} =Piter{1}{m};
    fn=fieldnames(Piter{1}{m});
    for f=1:numel(fn)
        V=zeros(size(Piter{1}{m}.(fn{f}),1),size(Piter{1}{m}.(fn{f}),2),Nbs);
        for iter=1:Nbs
            V(:,:,iter)=Piter{iter}{m}.(fn{f});
        end
        
        Pbs{m}.(fn{f})=V;
        Pmean{m}.(fn{f})=mean(V,3);
        Pstd{m}.(fn{f}) =std(V,[],3);
    end
    for iter=1:Nbs
        lnL(iter,m)=lnLiter{iter}(m);
    end
end


