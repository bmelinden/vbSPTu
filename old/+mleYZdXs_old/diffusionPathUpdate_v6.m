function [W,WS]=diffusionPathUpdate_v6(W,dat)
% [W,WS]=diffusionPathUpdate(W,dat)
% one round of diffusion path update in a diffusive YZdXc HMM (with
% constant localization error) and possibly missing position data. This
% code extends the EMhmm diffusion path update to the variational
% formulation using q(Y,Z) for later incorporation into the vbUSPT package
%
% WS: optional output, workspace at end of the function

% v1: initial implementation, validated by comparing to EMhmm variational
% distribution q(y) (reasonable agreement), and lnH (small
% difference), viterbi path (good agreement). Not clear how good a match to
% expect given that the formulations differ.
% v2: mostly removed loops over individual trajectories, for speed and
% simplicity
% v3: using a tri-diagonal inversion algorithm to speed up covariance
% computations 
% v4: replace spdiags lin-alg with explicit back-substitution for computing
% muY
% v5: a single function combining both matrix inversion and
% back-substitution, and a mex-implementation of it
% v6 : switch to using a general-purpose spt function instead
%% start of actual code

tau=W.shutterMean;
R=W.blurCoeff;
beta=tau*(1-tau)-R;

% For MLE, the model with constant localization errors has the same algebra
% as that with point-wise estimated errors if the estimated error is
% substituted as follows: 
%datV=W.P.v*ones(size(dat.x));
%datV(~isfinite(dat.x(:,1)),:)=inf;
%datV(W.YZ.i1,:)=0;
iLambda=1./W.P.lambda;
iVs    =1./W.P.v;
W.YZ=spt.diffusionPathUpdate(dat,W.S,tau,R,iLambda,iVs);
