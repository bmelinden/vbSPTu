function [dlnLrel,sMaxP,sVit]=Siter(this,dat,iType)
% [dlnLrel,sMaxP,sVit]=Siter(dat,iType)
% update the variational hidden state distribution
%
% dat   : spt.preprocess data struct 
% iType : type of iteration {'mle','map','vb'}
%
% dlnLrel : relative change in log likelihood/lower bound
% sMaxP   : sequence of most likely states
% sVit    : Viterbi path, most likely sequence of states. Note that the
% 
% sMaxP, sVit require some extra computing, and are therefore only computed
% when asked for. 

% ML 2017-09-01

tau=this.sample.shutterMean;
R  =this.sample.blurCoeff;
% for now, I assume that the difference btw MAP/MLE is
% only in computing the parameter counts (i.e., adding
% prior pseudocounts or not).
lnL0=this.lnL;
switch lower(iType)
    case 'mle'
        lnp0=log(rowNormalize(this.P.wPi));
        lnQ =log(rowNormalize(diag(this.P.wa(:,2))+this.P.wB));
        Lambda = this.P.c./this.P.n;
        iLambda =1./Lambda;
        lnLambda=log(Lambda);
        lnL1=this.YZ.mean_lnpxz-this.YZ.mean_lnqyz;
    case 'map'
        lnp0=log(rowNormalize(this.P.wPi-1));
        a=rowNormalize(this.P.wa-1);
        B1=ones(this.numStates,this.numStates)-eye(this.numStates);
        I1=eye(this.numStates);
        B=rowNormalize(this.P.wB-B1);
        A=diag(a(:,2))+diag(a(:,1))*B;
        lnQ =log(A);
        Lambda = this.P.c./(this.P.n+1);
        iLambda =1./Lambda;
        lnLambda=log(Lambda);        
        if(~isempty(find(A(:)<0)))
           error('Negative transition weight matrix MAP Siter. Possibly because the last Piter was not an MAP update.')
        end
        
        % log(prior) terms
        % 'omitnan' in the last term because 0*log(0)=nan in matlab, but we
        % want the limit log(0^0)=log(1)=0
        p0lnPrior=    gammaln(sum(this.P0.wPi,2))-sum(gammaln(this.P0.wPi),2)+sum(lnp0.*(this.P0.wPi-1),'omitnan'); % p0-log prior
        walnPrior=sum(gammaln(sum(this.P0.wa, 2))-sum(gammaln(this.P0.wa), 2)+sum(log(a).*(this.P0.wa-1),2,'omitnan'),1);
        % special construct so that the diagonal B-terms do not contribute,
        wBlnPrior=sum(gammaln(sum(this.P0.wB, 2))-sum(gammaln(this.P0.wB+1-B1),2)+sum(log(B+I1).*(this.P0.wB-B1),2,'omitnan'),1);
        
        lalnPrior=sum(this.P0.n.*log(this.P0.c)-gammaln(this.P0.n)-(this.P0.n-1).*log(Lambda)-this.P0.c./Lambda);
        %%%this.P.lnP0=p0lnPrior+walnPrior+wBlnPrior+lalnPrior;
        
        lnL1=p0lnPrior+walnPrior+wBlnPrior+lalnPrior...
            +this.YZ.mean_lnpxz-this.YZ.mean_lnqyz; % + q(Y,Z)-terms
    case 'vb'
        [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
        lnL1=-sum(this.P.KL_a)-sum(this.P.KL_B)-sum(this.P.KL_pi)-sum(this.P.KL_lambda)...
            +this.YZ.mean_lnpxz-this.YZ.mean_lnqyz;
    case 'none'
        return
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
        
switch nargout
    case {0,1}
        this.S=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
    case 2
        [this.S,sMaxP]=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
    case 3
        [this.S,sMaxP,sVit]=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
end
lnL1=lnL1+this.S.lnZ;
dlnLrel=(lnL1-lnL0)*2/abs(lnL1+lnL0);
this.lnL=lnL1;

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
