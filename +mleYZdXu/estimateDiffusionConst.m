function [D,RMS,W]=estimateDiffusionConst(x,dt,R,tau,Dinit,RMSinit)
% [D,RMS,W]=estimateDiffusionConst(x,dt,R,tau,Dinit,RMSinit)
% A wrapper to estimate diffusion constant and average localization error
% from a single trajectory
%
% x     : trajectory, different columns being different dimension
%         coordinates (x,y,...). All columns are used in the estimate.
%         NaN entries are interpreted as missing positions.
% dt    : sampling time step
% R     : Berglund's blur coefficient [1].
% tau   : average exposure time
%         For precise definitions of R,tau, see e.g., eqs 18,20 in the SI
%         of [2], but note that this code uses a slightly different
%         formulation of the model than described there. In the common
%         special case of constant exposure during an exposure time tE<=dt,
%         we get R=tE/dt/6, tau=tE/dt/2. The limit R,tau=0 cannot be
%         handled.
% Dinit,RMSinit : initial guesses for the diffusion constant and RMS error.
%         No accuracy is required, but a good guess can speed up the
%         convergence of the estimator. 
%
% Output
% D     : estimated diffusion constant
% RMS   : estimated RMS localization error (square root of estimated
%         localization variance).
% W     : the converged 1-state HMM model struct, which contains some
%         potentially interesting additional information, such as a refined
%         trajectory estimate. E.g., W.YZ.muY, W.YZ.varY are the posterior
%         mean and variance estimates of the actual point-wise particle
%         positions. Similarly, W.YZ.muZ,W.YZ.varZ are posterior mean and
%         variance of the true localized positions.
%
% M.L. 2017-08-17
%
% [1] Berglund, A.J. (2010). Statistics of camera-based single-particle
% tracking. Phys. Rev. E 82, 011917.
% http://link.aps.org/doi/10.1103/PhysRevE.82.011917 
%
% [2] Lindén, M., Ćurić, V., Amselem, E., and Elf, J. (2017). Pointwise
% error estimates in localization microscopy. Nat Commun 8, 15115. 
% http://www.nature.com/ncomms/2017/170503/ncomms15115/full/ncomms15115.html

% preprocess
dim=size(x,2);
X=spt.preprocess({x},[],dim,[],true);
W=mleYZdXu.init_P_dat(tau,R,Dinit,dt,1,1,RMSinit^2,X);
W=mleYZdXu.converge(W,X,'display',0,'Nwarmup',1);
P=mleYZdXu.parameterEstimate(W,X);
D=P.D;
RMS=P.RMSerr;

