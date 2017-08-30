classdef dXt < YZShmm.YZSmodel
    % a hidden diffusive HMM with externally estimated point-wise
    % localization errors 
    properties
    end
    methods
        function this=dXt(opt,dat,N)
            this=this@YZShmm.YZSmodel(opt,dat,N);
            % initialize trajectory model
            this.YZ=spt.naiveYZfromX(dat);
        end
        
        function this= Siter(this,dat,iType)
            % update the variational hidden state distribution
            
            warning('need to separate counts and pseudocounts in P, P0')
            switch lower(iType)
                case 'mle'
                    %%% got this far
                    lnp0=
                case 'map'
                case 'vb'                    
                    [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
                case 'none'
                    return
                otherwise
                    error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
            end
            tau=this.param.shutterMean;
            R  =this.param.blurCoeff;
            
            [S,lnL,sMaxP,sVit,funWS]=spt.hiddenStateUpdate(dat,YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs)            
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
        end
        function this=YZiter(this,dat,iType)
        end
        function this= Piter(this,dat,iType)
            
        end
        %this=converge(this,dat,iType);

        
    end    
end
