function [Wbest,lnL,initMethod,convTime,initTime,YZmv]=modelSearchFixedSize(opt,X,N0,YZww,Nrestarts,YZ0,nDisp)
% [Wbest,lnL,initMethod,convTime,initTime,YZmv]=...
%               modelSearchFixedSize(opt,X,N0,tDwell,Drange,YZww,Nrestarts,YZ0,nDisp)
%
% opt   : options struct, 
% X     : data struct from spt.preprocess
% N0    : model size to search for
% YZww  : list of smoothing radii for q(Y,Z) moving average diffusion
%         filter. Default [] (no YZ filtering used in the search).
% Nrestarts : number of independent restarts. Default 1.
% YZ0   : precomputed q(Y,Z) distribution(s), either as a single YZ
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

Nwu=10;
dt=opt.timestep;
if(~exist('Nrestarts','var') || isempty(Nrestarts))
    Nrestarts=1;
end
if(~exist('nDisp','var') || isempty(nDisp))
    nDisp=0;
end

% small variance data
X0=X;
X0.v=1e-6*X0.v;

% precompute moving average q(Y,Z) distributions
if(isempty(YZww))
    YZmv={};
    initTime=[];
elseif(isreal(YZww)) % then compute moving average initializations
    YZmv=cell(size(YZww));
    initTime={};
    parfor k=1:numel(YZww)
        tic
        YZmv{k}=mleYZdXt.YZinitMovingAverage(X,YZww(k),3e-2,opt.shutterMean,opt.blurCoeff,dt);
        initTime{k}=toc;
    end
    initTime=[initTime{:}];    
    if(nDisp>0)
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
parfor r=1:Nrestarts
%%%for r=1:Nrestarts
    tDwell=(opt.init_tD(1)+diff(opt.init_tD)*rand(1,N0)); % [s]
    wAinit=tDwell/dt*eye(N0)+(ones(N0,N0)-eye(N0));
    P=mleYZdXt.randomParameters(N0,dt,opt.init_D,wAinit);
    initMethod{r}={};
    m=0;
    W{r}=struct('lnL',-inf);
    WlnL{r}={};
    WCtime{r}={};
    %% YZfilter
    for k=1:numel(YZww)
        m=m+1;tic;
        initMethod{r}{m}=['yzF(' int2str(YZww(k)) ')S'];
        V=vbYZdXt.createModel(opt,X,N0,P.lambda/2/dt,P.A,P.p0);
        V.YZ=YZmv{k};
        V=vbYZdXt.hiddenStateUpdate(V,X);
        V=vbYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);
        WlnL{r}{m}=V.lnL;
        V.init=initMethod{r}{m};
        if(V.lnL>W{r}.lnL)
            W{r}=V;
        end
        WCtime{r}{m}=toc;
    end
    %% pre-computed YZ structs
    for k=1:numel(YZ0)
        m=m+1;tic;
        initMethod{r}{m}=['YZ0(' int2str(k) ')S'];
        V=vbYZdXt.createModel(opt,X,N0,P.lambda/2/dt,P.A,P.p0);
        V.YZ=YZ0{k};
        V=vbYZdXt.hiddenStateUpdate(V,X);
        V=vbYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);
        WlnL{r}{m}=V.lnL;
        V.init=initMethod{r}{m};
        if(V.lnL>W{r}.lnL)
            W{r}=V;
        end
        WCtime{r}{m}=toc;
    end
    %% Suniform : q(S) = uniform
    m=m+1;tic;
    initMethod{r}{m}='uniformS';
    V=vbYZdXt.createModel(opt,X,N0,P.lambda/2/dt,P.A,P.p0);
    V=vbYZdXt.diffusionPathUpdate(V,X);
    V=vbYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    %% YZdata   : q(Y,Z) = data
    m=m+1;tic;
    initMethod{r}{m}='YZdata';
    V=vbYZdXt.createModel(opt,X,N0,P.lambda/2/dt,P.A,P.p0);
    V=vbYZdXt.hiddenStateUpdate(V,X);
    V=vbYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    %% YZne     : q(Y,Z) = data, low errors    
    m=m+1;tic;
    initMethod{r}{m}='YZneS';
    V=vbYZdXt.createModel(opt,X0,N0,P.lambda/2/dt,P.A,P.p0);
    V=vbYZdXt.hiddenStateUpdate(V,X);
    V=vbYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);    
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    %% YZnbeInit: start w YZdata but with low error and blur
    m=m+1;tic;
    initMethod{r}{m}='SPnbe';
    opt0=opt;
    opt0.shutterMean=1e-2;
    opt0.blurCoeff=1e-2/3;
    V0=vbYZdXt.createModel(opt0,X0,N0,P.lambda/2/dt,P.A,P.p0);
    V0=vbYZdXt.hiddenStateUpdate(V0,X0);
    V0=vbYZdXt.converge(V0,X0,'display',nDisp,'Dsort',false);
    V=vbYZdXt.createModel(opt,X,N0,P.lambda/2/dt,P.A,P.p0);
    V.S=V0.S;
    V.P=V0.P;
    V=vbYZdXt.diffusionPathUpdate(V,X);
    V=vbYZdXt.parameterUpdate(V,X);
    V=vbYZdXt.converge(V,X,'display',nDisp,'Nwarmup',0);
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    %% YZnbeInit: start w YZdata but with low error and blur, reser params
    m=m+1;tic;
    initMethod{r}{m}='Snbe';
    V=vbYZdXt.createModel(opt,X,N0,P.lambda/2/dt,P.A,P.p0);
    V.S=V0.S;
    V=vbYZdXt.diffusionPathUpdate(V,X);
    V=vbYZdXt.parameterUpdate(V,X);
    V=vbYZdXt.converge(V,X,'display',nDisp,'Nwarmup',0);
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
end
lnL=[WlnL{1}{:}];
convTime=[WCtime{1}{:}];
initMethod=initMethod{1};
Wbest=W{1};
for r=2:Nrestarts
    lnL(r,:)=[WlnL{r}{:}];
    convTime(r,:)=[WCtime{r}{:}];
    if(Wbest.lnL<W{r}.lnL)
        Wbest=W{r};
    end
end
Wbest=vbYZdXt.sortModel(Wbest);
% to do: save correlation btw method and lnL


