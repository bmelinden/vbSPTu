function Piter(this,~,iType)
tau=this.sample.shutterMean;
R  =this.sample.blurCoeff;

switch lower(iType)
    case 'mle'
        MLEregularization={};
        [wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(this.YZ,this.S,tau,R);
        % regularization of unoccupied t=0 : not needed to avoid nan/inf
        if(false && ~isempty(find(wPi==0, 1)))            
            wPi=wPi+eps;
            MLEregularization{end+1}= 'pInit=0';
        end
        % gentle regularization of un-occupied states
        wAemptyRows=find((sum(wa,2)==0))';
        if(~isempty(wAemptyRows)) % regularization with no new transitions
            %%wa(wAemptyRows,:)=eps;
            wa(wAemptyRows,2)=eps; % no transitions from this state
             MLEregularization{end+1}= 'wa=0';
        end
        wBemptyRows=find((sum(wB,2)==0))';
        if(false && ~isempty(wBemptyRows)) % regularization with no new transitions
            % not needed to avoid nan/inf, as long as wa has no empty lines
            wB(wBemptyRows,:)=eps;
            wB=wB.*(1-eye(size(wB)));
            MLEregularization{end+1}= 'wB=0';
        end
        % diffusion const. regularization 1: D(unoccupied) -> infty
        wDempty=find(n==0)';
        if(~isempty(wDempty))
            n(wDempty)=10*eps; % eps is ~smallest double in matlab
            c(wDempty)=1e100*eps;
            MLEregularization{end+1}= 'n=0';
        end
        % diffusion const. regularizarion 2: D >= 10*eps
        Dzero=find(c<n*10*eps);
        if(false && ~isempty(Dzero))
            % inactivated, since it is not guaranteed to help
            c(Dzero)=n(Dzero)*10*eps;
            MLEregularization{end+1}= 'D=0';
        end
        if(~isempty(MLEregularization))
           wStr=['MLE regularization : ' MLEregularization{1}];
           for r=2:numel(MLEregularization)
              wStr=[wStr ', '  MLEregularization{r}];
           end
           warning(wStr)
        end
        this.P.wPi=wPi;
        this.P.wa =wa;
        this.P.wB =wB;
        this.P.n  =n;
        this.P.c  =c;
        % no KL terms in mle updates
        this.P.KL.pi=0;this.P.KL.a=0;this.P.KL.B=0;this.P.KL.lambda=0;this.P.KL.v=0;
        % no log-prior terms in mle updates
        this.P.lnP0.pi=0;this.P.lnP0.a=0;this.P.lnP0.B=0;this.P.lnP0.lambda=0;this.P.lnP0.v=0;
    case 'map'
        [wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(this.YZ,this.S,tau,R);
        this.P.wPi=this.P0.wPi+wPi;
        this.P.wa =this.P0.wa+wa;
        this.P.wB =this.P0.wB+wB;
        this.P.n  =this.P0.n+n;
        this.P.c  =this.P0.c+c;
        % no KL terms in map updates
        this.P.KL.pi=0;this.P.KL.a=0;this.P.KL.B=0;this.P.KL.lambda=0;this.P.KL.v=0;
        % compute log-prior terms
        [this.P.lnP0.pi,this.P.lnP0.a,this.P.lnP0.B,this.P.lnP0.lambda]=YZShmm.P0AD_lnP0terms(this.P,this.P0);
    case 'vb'
        [wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(this.YZ,this.S,tau,R);
        this.P.wPi=this.P0.wPi+wPi;
        this.P.wa =this.P0.wa+wa;
        this.P.wB =this.P0.wB+wB;
        this.P.n  =this.P0.n+n;
        this.P.c  =this.P0.c+c;
        [this.P.KL.pi,this.P.KL.a,this.P.KL.B,this.P.KL.lambda]=YZShmm.P0AD_KLterms(this.P,this.P0);
        % no log-prior terms in vb updates
        this.P.lnP0.pi=0;this.P.lnP0.a=0;this.P.lnP0.B=0;this.P.lnP0.lambda=0;this.P.lnP0.v=0;
    case 'none'
        return
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
end
