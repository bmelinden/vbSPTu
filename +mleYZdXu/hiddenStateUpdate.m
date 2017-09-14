function W=hiddenStateUpdate(W,dat)
% hiddenStateUpdate(W,dat) = YZdXt.hiddenStateUpdate(W,dat);
% the mle hidden state update for the YZdxc HMM (constant localization
% error) is the same as for the model with estimated point-wise
% localization errors. 

tau=W.shutterMean;
R=W.blurCoeff;
iLambda=1./W.P.lambda;
lnLambda=log(W.P.lambda);
lnp0=log(W.P.p0);
lnQ=log(W.P.A);
lnVs=log(W.P.v)*ones(1,W.numStates);
iVs=1./W.P.v*ones(1,W.numStates);
switch nargout
    case 1
        [W.S]           =YZShmm.hiddenStateUpdate(dat,W.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
    case 2
        [W.S,sMaxP]     =YZShmm.hiddenStateUpdate(dat,W.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
    case 3
        [W.S,sMaxP,sVit]=YZShmm.hiddenStateUpdate(dat,W.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
end

W.lnL=W.S.lnZ-W.YZ.mean_lnqyz;
