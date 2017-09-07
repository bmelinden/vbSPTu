function Piter(this,~,iType)
tau=this.sample.shutterMean;
R  =this.sample.blurCoeff;

switch lower(iType)
    case 'mle'
        [wPi,wa,wB,n,c]=YZShmm.parameterParameters(this.YZ,this.S,tau,R);
        %[wPi,wa,wB,n,c,wd,KL_pi,KL_a,KL_B,KL_lambda,KL_d]=parameterParameters(YZ,S,tau,R,wBstruct)
        this.P.wPi=wPi;
        this.P.wa =wa;
        this.P.wB =wB;
        this.P.n  =n;
        this.P.c  =c;
        % explicit ML parameter values (for debugging only)
        %this.P.p0=rowNormalize(this.P.wPi);
        %this.P.A=rowNormalize(diag(this.P.wa(:,2))+this.P.wB);
        %this.P.lambda=this.P.c./this.P.n;
        this.P.KL_pi=0;this.P.KL_a=0;this.P.KL_B=0;this.P.KL_lambda=0;
    case 'map'
        [wPi,wa,wB,n,c]=YZShmm.parameterParameters(this.YZ,this.S,tau,R);
        %[wPi,wa,wB,n,c,wd,KL_pi,KL_a,KL_B,KL_lambda,KL_d]=parameterParameters(YZ,S,tau,R,wBstruct)
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
        this.P.KL_pi=0;this.P.KL_a=0;this.P.KL_B=0;this.P.KL_lambda=0;
    case 'vb'
        [wPi,wa,wB,n,c]=YZShmm.parameterParameters(this.YZ,this.S,tau,R);
        %[wPi,wa,wB,n,c,wd,KL_pi,KL_a,KL_B,KL_lambda,KL_d]=parameterParameters(YZ,S,tau,R,wBstruct)
        this.P.wPi=this.P0.wPi+wPi;
        this.P.wa =this.P0.wa+wa;
        this.P.wB =this.P0.wB+wB;
        this.P.n  =this.P0.n+n;
        this.P.c  =this.P0.c+c;
        [this.P.KL_pi,this.P.KL_a,this.P.KL_B,this.P.KL_lambda]=YZShmm.KLterms(this.P,this.P0);
    case 'none'
        return
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
end
