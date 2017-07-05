function [W,WS]=diffusionPathUpdate(W,dat)
% [W,WS]=diffusionPathUpdate(W,dat)
% one round of diffusion path update in a diffusive HMM, with possibly
% missing position data. This code extends the EMhmm diffusion path update
% to the variational formulation using q(Y,Z) for later incorporation into
% the vbUSPT package
%
% WS: optional output, workspace at end of the function
%
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

%% start of actual code

tau=W.shutterMean;
R=W.blurCoeff;
beta=tau*(1-tau)-R;

%% hidden path: optimized and validated version

% fields to compute
W.YZ.muY=zeros(size(dat.x));
W.YZ.muZ=zeros(size(dat.x));
W.YZ.varY   =zeros(size(dat.x));
W.YZ.varZ   =zeros(size(dat.x));
W.YZ.covYtYtp1=zeros(size(dat.x));
W.YZ.covYtZt  =zeros(size(dat.x));
W.YZ.covYtp1Zt=zeros(size(dat.x));
W.YZ.mean_lnqyz=zeros(numel(W.YZ.i0),W.dim);
W.YZ.mean_lnpxz=0;

iAlpha=((W.S.pst*(1./W.P.lambda)')*ones(1,W.dim)); % 1/alpha_t
iAlpha(W.YZ.i1,:)=0; % redundant usually
iAzz0=1./(1./dat.v+iAlpha/beta); % diagonal elements of A_{zzm}^{1}
iAzz0(W.YZ.i1,:)=0; % missing data points are zeroes here

am=iAlpha*(1+(1-tau)^2/beta)-iAlpha.^2*(1-tau)^2/beta^2.*iAzz0;
bm=iAlpha*(1+tau^2/beta)-iAlpha.^2*tau^2/beta^2.*iAzz0;
iSyy0=am+bm([end 1:end-1],:);

iSyy1=iAlpha*R/beta-iAlpha.^2*tau*(1-tau)/beta^2.*iAzz0;

Vx=dat.x./dat.v;
Vx(W.YZ.i1,:)=0;
Vx(~isfinite(Vx))=0; % missing data 

yRHS         =          (1-tau)/beta*iAlpha.*iAzz0.*Vx;
yRHS(2:end,:)=yRHS(2:end,:)+tau/beta*iAlpha(1:end-1,:).*iAzz0(1:end-1,:).*Vx(1:end-1,:);

% compute <y> and Syy
logDetInvSyy=zeros(1,W.dim);
for m=1:W.dim % inversion and back-substitution, one dimension at a time
    [W.YZ.muY(:,m),W.YZ.varY(:,m),W.YZ.covYtYtp1(:,m),logDetInvSyy(m)]=...
        triSym_triInv_backsubLDU(iSyy0(:,m),iSyy1(:,m),yRHS(:,m));    
end

W.YZ.muZ=iAzz0.*(Vx+iAlpha/beta.*((1-tau)*W.YZ.muY+tau*W.YZ.muY([2:end end],:)));

W.YZ.covYtZt  =iAlpha/beta.*iAzz0.*((1-tau)*W.YZ.varY+tau*W.YZ.covYtYtp1);
W.YZ.covYtp1Zt=iAlpha/beta.*iAzz0.*((1-tau)*W.YZ.covYtYtp1+tau*W.YZ.varY([2:end 1],:));
W.YZ.varZ    =iAzz0.*(1+(1-tau)/beta*iAlpha.*W.YZ.covYtZt+tau/beta*iAlpha.*W.YZ.covYtp1Zt);

% <ln q(y,z)> :
logDetAzz=-sum(log(iAzz0(iAzz0(:,1)>0,:))); % sum |Azzm|
Tx=W.YZ.i1-W.YZ.i0; % number of points per trj
W.YZ.mean_lnqyz=-W.dim*sum((1+log(2*pi))*(2*Tx+1)/2)+0.5*sum((logDetAzz+logDetInvSyy));

% <ln p(x|z)> :
ot=isfinite(dat.v(:,1))&(dat.v(:,1)>0);
W.YZ.mean_lnpxz=-0.5*sum(sum(log(2*pi*dat.v(ot,:))+((dat.x(ot,:)-W.YZ.muZ(ot,:)).^2+W.YZ.varZ(ot,:))./dat.v(ot,:)));

W.YZ.Fs_yz=W.YZ.mean_lnpxz-W.YZ.mean_lnqyz;

if(nargout>=2)
   fname=['foo_' int2str(ceil(1e9*rand)) '.mat'];
   save(fname);
   WS=load(fname);
   delete(fname);
end
