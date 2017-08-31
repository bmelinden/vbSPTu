classdef dXt < YZShmm.YZSmodel
    % a hidden diffusive HMM with externally estimated point-wise
    % localization errors 
    properties
    end
    methods
        function this=dXt(varargin)            
            % dXt(N,opt,dat,p0_init,D_init,A_init)
            % same syntax as for the YZShmm.YZSmodel constructor, except
            % that the data struct dat is expected to contain estimated
            % position variances.
            this=this@YZShmm.YZSmodel(varargin{:});

            % initialize trajectory model
            if(nargin>=3)
                dat=varargin{3};
                this.YZ=spt.naiveYZfromX(dat);
            end
        end
        
        function this= Siter(this,dat,iType)
            % update the variational hidden state distribution            
            tau=this.param.shutterMean;
            R  =this.param.blurCoeff;
            % for now, I assume that the difference btw MAP/MLE is
            % only in computing the parameter counts (i.e., adding
            % prior pseudocounts or not).
            switch lower(iType)
                case 'mle'
                    lnp0=log(rowNormalize(this.P.wPi));
                    lnQ =log(rowNormalize(diag(this.P.wa(:,2))+this.P.wB));
                    Lambda = this.P.c./this.P.n;
                    iLambda =1./Lambda;
                    lnLambda=log(Lambda);
                    this.S=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
                    this.lnL=this.S.lnZ+this.YZ.mean_lnpxz-this.YZ.mean_lnqyz;
                case 'map'
                    lnp0=log(rowNormalize(this.P.wPi-1));
                    a=rowNormalize(this.P.wa-1);
                    B1=ones(this.numStates,this.numStates)-eye(this.numStates);
                    B=rowNormalize(this.P.wB-B1);
                    A=diag(a(:,2))+diag(a(:,1))*B;
                    lnQ =log(A);
                    Lambda = this.P.c./(this.P.n+1);
                    iLambda =1./Lambda;
                    lnLambda=log(Lambda);
                    this.S=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
                    this.lnL=this.S.lnZ+this.YZ.mean_lnpxz-this.YZ.mean_lnqyz;
                case 'vb'                    
                    [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
                    this.S=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
                    this.lnL=this.S.lnZ...
                        -sum(this.P.KL_a)-sum(this.P.KL_B)-sum(this.P.KL_pi)-sum(this.P.KL_lambda)...
                        +this.YZ.mean_lnpxz-this.YZ.mean_lnqyz;
                case 'none'
                    return
                otherwise
                    error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
            end

            %[this.S,sMaxP,sVit,funWS]=YZShmm.hiddenStateUpdate(dat,YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
            % dat   : preprocessed data struct (spt.preprocess)
            % YZ    : variational trajectory model struct
            % tau   : W.shutterMean
            % R     : W.blurCoeff
            % iLambda : <1/lambda=W.P.n./W.P.c (VB), or 1./W.P.lambda (MLE)
            % lnLambda: <ln(lambda)>=ln(W.P.c)-psi(W.P.n) (VB) or ln(lambda) (MLE)
            % lnp0  : <ln(pi)>=psi(W.P.wPi)-psi(sum(W.P.wPi))   (VB) or ln(p0) (MLE)
            % lnQ   : lnQ(i,i) = <ln(1-a(i))>                   (VB)
            %         lnQ(i,j) = <ln(a(i))>  + <lnB(i,j)>, i~=j (VB)
            %         <ln(1-a)> = psi(W.P.wa(:,2)) - psi(sum(W.P.wa,2)); (VB)
            %         <ln(a)>   = psi(W.P.wa(:,1)) - psi(sum(W.P.wa,2)); (VB)
            %         <ln(B)>   = psi(W.P.wB) - psi(sum(W.P.wB,2));      (VB)
            %         or ln(A) (MLE).            
            % ------------------------------------------------------------------------
            % for models where localization errors are fit parameters
            % lnVs  : <ln v> =ln(cv)-psi(nv) (VB) or ln(v) (MLE)
            % iVs   : <1./v> = nv./cv        (VB) or 1./v  (MLE)
            % -------------------------------------------------------------------------
        end
        function this=YZiter(this,dat,iType)            
            switch lower(iType)
                % for now, I assume that the difference btw MAP/MLE is
                % in computing the parameter counts (i.e., adding
                % prior pseudocounts or not in the P subfields).
                case {'mle','map'}
                    lnp0=log(rowNormalize(this.P.wPi));
                    lnQ =log(rowNormalize(diag(this.P.wa(:,2))+this.P.wB));
                    Lambda = this.P.c./this.P.n;
                    iLambda =1./Lambda;
                case 'vb'
                    [~,~,iLambda,~]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
                case 'none'
                    return
                otherwise
                    error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
            end         
            tau=this.param.shutterMean;
            Rcoeff  =this.param.blurCoeff;
            this.YZ=YZShmm.diffusionPathUpdate(dat,this.S,tau,Rcoeff,iLambda);
            
            % [YZ,funWS]=diffusionPathUpdate(dat,S,tau,R,iLambda,iV)
            % one round of diffusion path update in a diffusive HMM, with possibly
            % missing position data. This function handles either point-wise
            % localization errors (variances dat.V), or uniform or state-dependent
            % errors (if iV is given).
            %
            % dat   : preprocessed data field.
            % S     : W.S, variational hidden state distribution struct
            % tau   : W.shutterMean
            % R     : W.blurCoeff
            % iLambda : <1/lambda= W.P.n./W.P.c   (VB), or 1./W.P.lambda (MLE)
            % iV    :   <1./v>   = W.P.nv./W.P.cv (VB), or 1./W.P.v      (MLE)
            %
            % YZ   : updated variational trajectory distribution struct
            
        end
        function this= Piter(this,~,iType)
            tau=this.param.shutterMean;
            R  =this.param.blurCoeff;
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
    end    
end
