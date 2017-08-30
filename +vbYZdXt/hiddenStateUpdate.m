function [W,sMaxP,sVit,WS]=hiddenStateUpdate(W,dat)
% [W,sMaxP,sVit,WS]=hiddenStateUpdate(W,dat)
% one round of VB hidden state EM iteration (maximum likelihood) in a
% diffusive HMM, with possibly missing position data. Calling
% YZShmm.hiddenStateUpdate with appropriate effective parameters
%
% W     : vbYZdXt model struct
% dat   : data struct with variance field dat.v (from spt.preprocess)
%
% sMAxP and sVit are only computed if asked for by output arguments.
% WS : struct containing the whole workspace at the end of the function
% call. Expensive, computed only when asked for.
%
% ML 2017-07-06

% compute variational average parameters
[lnp0,lnQ,iLambda,lnLambda]=YZShmm.VBmeanLogParam(W.P.wPi,W.P.wa,W.P.wB,W.P.n,W.P.c);

% update variatyional q(S)
switch nargout
    case 1
        W.S=YZShmm.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
    case 2
        [W.S,~,sMaxP]=YZShmm.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
    case 3
        [W.S,~,sMaxP,sVit]=YZShmm.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
    case 4
        [W.S,~,sMaxP,sVit,WS]=YZShmm.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
end
%% assemble the lower bound
W.lnL=W.S.lnZ...
    -sum(W.P.KL_a)-sum(W.P.KL_B)-sum(W.P.KL_pi)-sum(W.P.KL_lambda)...
    +W.YZ.mean_lnpxz-W.YZ.mean_lnqyz;
