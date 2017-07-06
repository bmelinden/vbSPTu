function [W,sMaxP,sVit,WS]=hiddenStateUpdate(W,dat)
% [W,sMaxP,sVit,WS]=hiddenStateUpdate(W,dat)
% one round of VB hidden state EM iteration (maximum likelihood) in a
% diffusive HMM, with possibly missing position data. Calling
% spt.hiddenStateUpdate with appropriate effective parameters
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
[iLambda,lnLambda,lnp0,lnQ]=vbYZdXt.effectiveParameters(W);

% update variatyional q(S)
switch nargout
    case 1
        [W.S,W.lnL]=spt.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
    case 2
        [W.S,W.lnL,sMaxP]=spt.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
    case 3
        [W.S,W.lnL,sMaxP,sVit]=spt.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
    case 4
        [W.S,W.lnL,sMaxP,sVit,WS]=spt.hiddenStateUpdate(dat,W.YZ,W.shutterMean,W.blurCoeff,iLambda,lnLambda,lnp0,lnQ);
end
