function Piter(this,dat,iType)
tau=this.sample.shutterMean;
R  =this.sample.blurCoeff;

[wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(this.YZ,this.S,tau,R);
[nv,cv]=YZShmm.V_sumStats(this.YZ,this.S,dat);
switch lower(iType)
    case 'mle'
        % gentle regularization of unoccupied t=0
        if(~isempty(find(wPi==0, 1)))            
            wPi=wPi+eps;
        end
        % gentle regularization of un-occupied states
        wAemptyRows=find((sum(wa,2)==0))';
        if(~isempty(wAemptyRows)) % regularization with no new transitions
            wa(wAemptyRows,:)=eps;
        end
        wBemptyRows=find((sum(wB,2)==0))';
        if(~isempty(wBemptyRows)) % regularization with no new transitions
            wB(wBemptyRows,:)=eps;
            wB=wB.*(1-eye(size(wB)));
        end
        % diffusion const. regularization: D(unoccupied) -> infty
        wDempty=find(n==0)';
        if(~isempty(wDempty))
           n(wDempty)=10*eps; % eps is ~smallest double in matlab
           c(wDempty)=1e100*eps;
        end        
        
        this.P.wPi=wPi;
        this.P.wa =wa;
        this.P.wB =wB;
        this.P.n  =n;
        this.P.c  =c;
        % lump stats for all dimensions and states, no regularization
        % needed
        this.P.cv=sum(cv(:));
        this.P.nv=sum(nv(:));                        
        
        % no KL terms in mle updates
        this.P.KL.pi=0;this.P.KL.a=0;this.P.KL.B=0;this.P.KL.lambda=0;this.P.KL.v=0;
    case 'vb'
        this.P.wPi=this.P0.wPi+wPi;
        this.P.wa =this.P0.wa+wa;
        this.P.wB =this.P0.wB+wB;
        this.P.n  =this.P0.n+n;
        this.P.c  =this.P0.c+c;
        % lump stats for all dimensions and states        
        this.P.cv=this.P0.cv+sum(cv(:));
        this.P.nv=this.P0.nv+sum(nv(:));
        % compute KL terms
        [this.P.KL.pi,this.P.KL.a,this.P.KL.B,this.P.KL.lambda]=YZShmm.P0AD_KLterms(this.P,this.P0);                
        this.P.KL.v= this.P0.nv.*log(this.P.cv./this.P0.cv)...
            -this.P.nv.*(1-this.P0.cv./this.P.cv)...
            -gammaln(this.P.nv)+gammaln(this.P0.nv)...
            +(this.P.nv-this.P0.nv).*psi(this.P.nv);
        
    case 'none'
        return
    otherwise
        error(['iType= ' iType ' not known. Use {mle,vb}.'] )
end
end
