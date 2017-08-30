function [W,sMaxP,sVit]=hiddenStateUpdate(W,dat)
% [W,sMaxP,sVit]= YZdXs.hiddenStateUpdate(W,dat);
% the mle hidden state update for the YZdxc HMM (constant localization
% error) is the same as for the model with estimated point-wise
% localization errors. 

%W=mleYZdXt.hiddenStateUpdate(W,dat);
tau=W.shutterMean;
R=W.blurCoeff;
iLambda=1./W.P.lambda;
lnLambda=log(W.P.lambda);
lnp0=log(W.P.p0);
lnQ=log(W.P.A);
lnVs=log(W.P.v);
iVs=1./W.P.v;
switch nargout
    case 1
        [W.S,W.lnL]           =YZShmm.hiddenStateUpdate(dat,W.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
    case 2
        [W.S,W.lnL,sMaxP]     =YZShmm.hiddenStateUpdate(dat,W.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
    case 3
        [W.S,W.lnL,sMaxP,sVit]=YZShmm.hiddenStateUpdate(dat,W.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
end

%[S,lnL,sMaxP,sVit,funWS]=hiddenStateUpdate(dat,YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs)
