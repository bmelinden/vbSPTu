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
        v=this.P.cv./this.P.nv.*ones(1,this.numStates);
        lnV=log(v);
        iV=1./v;
        % iType dependent contributions to lnL
        lnL1=0;
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
        v=this.P.cv./(this.P.nv+1);
        lnV=log(v)*ones(1,this.numStates);
        iV=1./v*ones(1,this.numStates);
        % iType dependent contributions to lnL: log-priors in case of MAP
        % iterations
        % 'omitnan' in the last term because 0*log(0)=nan in matlab, but we
        % want the limit log(0^0)=log(1)=0
        p0lnPrior=gammaln(sum(this.P0.wPi))-sum(gammaln(this.P0.wPi))+sum(lnp0.*(this.P0.wPi-1),'omitnan'); % p0-log prior
        walnPrior=sum(gammaln(sum(this.P0.wa,2))-sum(gammaln(this.P0.wa),2)+sum(log(a).*(this.P0.wa-1),2,'omitnan'),1);
        % wB: special construct so that the diagonal B-terms do not contribute,
        wBlnPrior=sum(gammaln(sum(this.P0.wB,2))-sum(gammaln(this.P0.wB+1-B1),2)+sum(log(B+1-B1).*(this.P0.wB-1),2,'omitnan'),1);
        
        lalnPrior=sum(this.P0.n.*log(this.P0.c)-gammaln(this.P0.n)-(this.P0.n-1).*log(Lambda)-this.P0.c./Lambda);
        vlnPrior=sum(this.P0.nv.*log(this.P0.cv)-gammaln(this.P0.nv)-(this.P0.nv-1).*log(v)-this.P0.cv./v);
        lnL1=p0lnPrior+walnPrior+wBlnPrior+lalnPrior+vlnPrior;
        %%%this.P.lnP0=lnL1; %%% debug
    case 'vb'
        [lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
        % localization variances length variance takes the same variational
        % distribution as lambda, but with nv,cv statistics instead.
        [~,~,iV,lnV]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.nv,this.P.cv);

        % iType dependent contributions to lnL
        lnL1=-sum(this.P.KL_a)-sum(this.P.KL_B)-sum(this.P.KL_pi)-sum(this.P.KL_lambda)-sum(this.P.KL_v);
    case 'none'
        return
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
% update the hidden state distribution and compute path estimates as needed
switch nargout
    case {0,1}
        this.S=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnV,iV);
    case 2
        [this.S,sMaxP]=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnV,iV);
    case 3
        [this.S,sMaxP,sVit]=YZShmm.hiddenStateUpdate(dat,this.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnV,iV);
end
% add S- and YZ-contributions to lnL: cotribution <ln p(z|x,s,v)> is
% included in lnZs when v is a parameter
lnL1=lnL1+this.S.lnZ-this.YZ.mean_lnqyz;%+this.YZ.mean_lnpxz
dlnLrel=(lnL1-lnL0)*2/abs(lnL1+lnL0);
this.lnL=lnL1;
%[this.S,sMaxP,sVit,funWS]=YZShmm.hiddenStateUpdate(dat,YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
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
