function W=hiddenStateUpdate(W,dat)
% hiddenStateUpdate(W,dat) = YZdXt.hiddenStateUpdate(W,dat);
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
[W.S,W.lnL]=spt.hiddenStateUpdate(dat,W.YZ,tau,R,iLambda,lnLambda,lnp0,lnQ,lnVs,iVs);
