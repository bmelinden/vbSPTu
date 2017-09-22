function Piter(this,~,iType)
tau=this.sample.shutterMean;
R  =this.sample.blurCoeff;

switch lower(iType)
    case 'mle'
        [wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(this.YZ,this.S,tau,R);
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
