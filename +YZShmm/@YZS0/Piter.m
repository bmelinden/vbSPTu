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
        % explicit ML parameter values (for debugging only)
        %this.P.p0=rowNormalize(this.P.wPi);
        %this.P.A=rowNormalize(diag(this.P.wa(:,2))+this.P.wB);
        %this.P.lambda=this.P.c./this.P.n;
        this.P.KL.pi=0;this.P.KL.a=0;this.P.KL.B=0;this.P.KL.lambda=0;
    case 'map'
        [wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(this.YZ,this.S,tau,R);
        this.P.wPi=this.P0.wPi+wPi;
        this.P.wa =this.P0.wa+wa;
        this.P.wB =this.P0.wB+wB;
        this.P.n  =this.P0.n+n;
        this.P.c  =this.P0.c+c;
        % explicit MAP parameter values (for debugging only)
        %this.P.p0=rowNormalize(this.P.wPi-1);
        %a=rowNormalize(this.P.wa-1);
        %B1=ones(this.numStates,this.numStates)-eye(this.numStates);
        %B=rowNormalize(this.P.wB-B1);
        %this.P.A=diag(a(:,2))+diag(a(:,1))*B;
        %this.P.lambda=this.P.c./(this.P.n+1);
        this.P.KL.pi=0;this.P.KL.a=0;this.P.KL.B=0;this.P.KL.lambda=0;
    case 'vb'
        [wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(this.YZ,this.S,tau,R);
        this.P.wPi=this.P0.wPi+wPi;
        this.P.wa =this.P0.wa+wa;
        this.P.wB =this.P0.wB+wB;
        this.P.n  =this.P0.n+n;
        this.P.c  =this.P0.c+c;
        [this.P.KL.pi,this.P.KL.a,this.P.KL.B,this.P.KL.lambda]=YZShmm.P0AD_KLterms(this.P,this.P0);
    case 'none'
        return
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
end
