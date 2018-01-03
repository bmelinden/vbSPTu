function [dlnLrel,dlnLterms,sMaxP,sVit]=Siter(this,dat,iType)
% [dlnLrel,dlnLterms,sMaxP,sVit]=Siter(dat,iType)
% update the variational hidden state distribution
%
% dat   : spt.preprocess data struct 
% iType : type of iteration {'mle','vb'}
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
lnL0=this.lnL;
lnL0terms=this.lnLterms;
if(isempty(lnL0terms))
    lnL0terms=-inf(1,7);
end
switch lower(iType)
    case 'mle'
        lnp0=log(rowNormalize(this.P.wPi));
        lnQ =log(rowNormalize(diag(this.P.wa(:,2))+this.P.wB));
        Lambda = this.P.c./this.P.n;
        iLambda =1./Lambda;
        lnLambda=log(Lambda);
        lnLp=[];
    case 'vb'
        [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
        lnLp=[-sum(this.P.KL.pi) -sum(this.P.KL.a)  -sum(this.P.KL.B)  -sum(this.P.KL.lambda)];
    otherwise
        error(['iType= ' iType ' not known. Use {mle,vb}.'] )
end
        
switch nargout
    case {0,1,3}
        this.S=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
    case 4
        [this.S,sMaxP]=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
    case 5
        [this.S,sMaxP,sVit]=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ);
end
lnL1=sum(lnLp)+this.S.lnZ+this.YZ.mean_lnpxz-this.YZ.mean_lnqyz;
dlnLrel=(lnL1-lnL0)*2/abs(lnL1+lnL0);
this.lnL=lnL1;

this.lnLterms=[this.S.lnZ this.YZ.mean_lnpxz -this.YZ.mean_lnqyz lnLp];
if(numel(this.lnLterms)==lnL0terms)
    dlnLterms    =(this.lnLterms-lnL0terms)*2./abs(this.lnLterms+lnL0terms);
else
    dlnLterms=[];
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
