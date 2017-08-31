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
                case {'mle','map'}
                    warning('ML to do: separate counts and pseudocounts in P, P0')

                    lnp0=log(rowNormalize(this.P.wPi));
                    lnQ =log(rowNormalize(diag(this.P.wa(:,2))+this.P.wB));
                    Lambda = this.P.c./(this.P.n+1);
                    iLambda =1./Lambda;
                    lnLambda=log(Lambda);
                case 'vb'                    
                    [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
                case 'none'
                    return
                otherwise
                    error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
            end
            
            [this.S,this.lnL,~,~,~]=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
            %[this.S,this.lnL,sMaxP,sVit,funWS]=YZShmm.hiddenStateUpdate(dat,YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
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
                case {'mle','map'}
                    lnp0=log(rowNormalize(this.P.wPi));
                    lnQ =log(rowNormalize(diag(this.P.wa(:,2))+this.P.wB));
                    Lambda = this.P.c./(this.P.n+1);
                    iLambda =1./Lambda;
                    lnLambda=log(Lambda);
                case 'vb'
                    [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
                case 'none'
                    return
                otherwise
                    error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
            end         
            YZ=YZShmm.diffusionPathUpdate(dat,S,tau,R,iLambda,iV)
            % [YZ,funWS]=diffusionPathUpdate(dat,S,tau,R,iLambda,iV)
            % one round of diffusion path update in a diffusive HMM, with possibly
            % missing position data. This function handles either point-wise
            % localization errors (variances dat.V), or uniform or state-dependent
            % errors (if iV and logV are given).
            %
            % dat   : preprocessed data field.
            % S     : W.S, variational hidden state distribution struct
            % tau   : W.shutterMean
            % R     : W.blurCoeff
            % iLambda : <1/lambda= W.P.n./W.P.c   (VB), or 1./W.P.lambda (MLE)
            % iV    :   <1./v>   = W.P.nv./W.P.cv (VB), or 1./W.P.v      (MLE)
            %
            % YZ   : updated variational trajectory distribution struct
            % Note: the
            % funWS: optional output, workspace at end of the function

        end
        function this= Piter(this,dat,iType)
            switch lower(iType)
                case {'mle','map'}
                    warning('ML to do: separate counts and pseudocounts in P, P0')
                    
                    lnp0=log(rowNormalize(this.P.wPi));
                    lnQ =log(rowNormalize(diag(this.P.wa(:,2))+this.P.wB));
                    Lambda = this.P.c./(this.P.n+1);
                    iLambda =1./Lambda;
                    lnLambda=log(Lambda);
                case 'vb'
                    [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
                case 'none'
                    return
                otherwise
                    error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
            end
            
            
        end
        %this=converge(this,dat,iType);

        
    end    
end
