function [Wbest,lnL,initMethod,convTime,initTime]=modelSearchFixedSize(X,dt,tau,R,N0,tDwell,Drange,YZww,Nrestarts)

%% generate synthetic data and try to find a good models

% search parameters
wAinit=tDwell*eye(N0)+(ones(N0,N0)-eye(N0)); % <dwell> ~ tDwell steps,

Nwu=10;
nDisp=0;

% small variance data
X0=X;
X0.v=1e-6*X0.v;

YZmv=cell(size(YZww));
initTime={};
parfor k=1:numel(YZww)
    tic
    YZmv{k}=mleYZdXt.YZinitMovingAverage(X,YZww(k),3e-2,tau,R,dt);
    initTime{k}=toc;
end
initTime=[initTime{:}];
if(nDisp>0)
   disp(['YZfilters [ ' int2str(YZww) ' ] computed in [' num2str(initTime,3) ' ] s.]']); 
end
initTime=[initTime zeros(1,5)];


% independent restarts
W=cell(1,Nrestarts);
WlnL=cell(1,Nrestarts);
WCtime=cell(1,Nrestarts);
initMethod={};
parfor r=1:Nrestarts
%%%for r=1:Nrestarts
    P=mleYZdXt.randomParameters(N0,dt,Drange,wAinit);
    initMethod{r}={};
    m=0;
    W{r}=struct('lnL',-inf);
    WlnL{r}={};
    WCtime{r}={};
    %% YZfilter
    for k=1:numel(YZww)
        m=m+1;tic;
        initMethod{r}{m}=['yzF(' int2str(YZww(k)) ')S'];
        V=mleYZdXt.init_P_dat(tau,R,P.lambda/2/dt,dt,P.A   ,P.p0   ,X);
        V.YZ=YZmv{k};
        V=mleYZdXt.hiddenStateUpdate(V,X);
        V=mleYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);
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
    V=mleYZdXt.init_P_dat(tau,R,P.lambda/2/dt,dt,P.A   ,P.p0   ,X);
    V=mleYZdXt.diffusionPathUpdate(V,X);
    V=mleYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    %% YZdata   : q(Y,Z) = data
    m=m+1;tic;
    initMethod{r}{m}='YZdata';
    V=mleYZdXt.init_P_dat(tau,R,P.lambda/2/dt,dt,P.A   ,P.p0   ,X);
    V=mleYZdXt.hiddenStateUpdate(V,X);
    V=mleYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    %% YZne     : q(Y,Z) = data, low errors    
    m=m+1;tic;
    initMethod{r}{m}='YZneS';
    V=mleYZdXt.init_P_dat(tau,R,P.lambda/2/dt,dt,P.A   ,P.p0   ,X0);
    V=mleYZdXt.hiddenStateUpdate(V,X);
    V=mleYZdXt.converge(V,X,'display',nDisp,'Nwarmup',Nwu);    
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;
    %% YZnbeInit: start w YZdata but with low error and blur
    m=m+1;tic;
    initMethod{r}{m}='SPnbe';
    V0=mleYZdXt.init_P_dat(1e-2,1e-2/3,P.lambda/2/dt,dt,P.A   ,P.p0   ,X0);
    V0=mleYZdXt.hiddenStateUpdate(V0,X0);
    V0=mleYZdXt.converge(V0,X0,'display',nDisp,'Dsort',false);
    V=mleYZdXt.init_P_dat(tau,R,P.lambda/2/dt,dt,P.A   ,P.p0   ,X);
    V.S=V0.S;
    V.P=V0.P;
    V=mleYZdXt.diffusionPathUpdate(V,X);
    V=mleYZdXt.parameterUpdate(V,X);
    V=mleYZdXt.converge(V,X,'display',nDisp,'Nwarmup',0);
    WlnL{r}{m}=V.lnL;
    V.init=initMethod{r}{m};
    if(V.lnL>W{r}.lnL)
        W{r}=V;
    end
    WCtime{r}{m}=toc;

    %% YZnbeInit: start w YZdata but with low error and blur, reser params
    m=m+1;tic;
    initMethod{r}{m}='Snbe';
    V=mleYZdXt.init_P_dat(tau,R,P.lambda/2/dt,dt,P.A   ,P.p0   ,X);
    V.S=V0.S;
    V=mleYZdXt.diffusionPathUpdate(V,X);
    V=mleYZdXt.parameterUpdate(V,X);
    V=mleYZdXt.converge(V,X,'display',nDisp,'Nwarmup',0);
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
    if(Wbest.lnL>W{r}.lnL)
        Wbest=W{r};
    end
end

% to do: save correlation btw method and lnL


