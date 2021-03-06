function [YZ,funWS]=diffusionPathUpdate(dat,S,tau,R,iLambda,iV)
% [YZ,funWS]=diffusionPathUpdate(dat,S,tau,R,iLambda,iV)
% one round of diffusion path update in a diffusive HMM, with possibly
% missing position data. This function handles either point-wise
% localization errors (variances dat.v), or uniform or state-dependent
% errors (if iV is given).
%
% dat   : preprocessed data field.
% S     : W.S, variational hidden state distribution struct
% tau   : W.shutterMean
% R     : W.blurCoeff
% iLambda : <1/lambda= W.P.n./W.P.c   (VB), or 1./W.P.lambda (MLE)
% iV    :   <1./v>   = W.P.nv./W.P.cv (VB), or 1./W.P.v      (MLE)
%
% YZ   : updated variational trajectory distribution struct
% Note: the 
% funWS: optional output, workspace at end of the function

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
% v6 : omitting the mean_lnpxz term for the case of state-dependent
% localization errors.

%% start of actual code
% derived parameters
beta=tau*(1-tau)-R;
dim=size(dat.x,2);          % data dimensionality
N=size(S.pst,2);
if(exist('iV','var') && ~isempty(iV))
    if(numel(iV)==1)
        iV=iV*ones(1,N);
    end
    % compute efffective time-dependent localization errors
    datV=(1./(S.pst*(iV')))*ones(1,dim);
    datV(~isfinite(dat.x(:,1)),:)=inf;
    datV(dat.i1+1,:)=0;
elseif(isfield(dat,'v'))
    datV=dat.v;
else
    error('no localization precision information!')
end

%% hidden path: optimized and validated version

% fields to compute
YZ=struct;
YZ.i0=dat.i0;
YZ.i1=dat.i1+1;
YZ.muY=zeros(size(dat.x));
YZ.muZ=zeros(size(dat.x));
YZ.varY   =zeros(size(dat.x));
YZ.varZ   =zeros(size(dat.x));
YZ.covYtYtp1=zeros(size(dat.x));
YZ.covYtZt  =zeros(size(dat.x));
YZ.covYtp1Zt=zeros(size(dat.x));
YZ.mean_lnqyz=0;
YZ.mean_lnpxz=0;

iAlpha=((S.pst*(iLambda)')*ones(1,dim)); % 1/alpha_t
iAlpha(YZ.i1,:)=0; % redundant usually
iAzz0=1./(1./datV+iAlpha/beta); % diagonal elements of A_{zzm}^{1}
iAzz0(YZ.i1,:)=0; % missing data points are zeroes here

am=iAlpha*(1+(1-tau)^2/beta)-iAlpha.^2*(1-tau)^2/beta^2.*iAzz0;
bm=iAlpha*(1+tau^2/beta)-iAlpha.^2*tau^2/beta^2.*iAzz0;
iSyy0=am+bm([end 1:end-1],:);

iSyy1=iAlpha*R/beta-iAlpha.^2*tau*(1-tau)/beta^2.*iAzz0;

Vx=dat.x./datV;
Vx(YZ.i1,:)=0;
Vx(~isfinite(Vx))=0; % missing data 

yRHS         =          (1-tau)/beta*iAlpha.*iAzz0.*Vx;
yRHS(2:end,:)=yRHS(2:end,:)+tau/beta*iAlpha(1:end-1,:).*iAzz0(1:end-1,:).*Vx(1:end-1,:);

% compute <y> and Syy
logDetInvSyy=zeros(1,dim);
for m=1:dim % inversion and back-substitution, one dimension at a time
    [YZ.muY(:,m),YZ.varY(:,m),YZ.covYtYtp1(:,m),logDetInvSyy(m)]=...
        triSym_triInv_backsubLDU(iSyy0(:,m),iSyy1(:,m),yRHS(:,m));    
end

YZ.muZ=iAzz0.*(Vx+iAlpha/beta.*((1-tau)*YZ.muY+tau*YZ.muY([2:end end],:)));

YZ.covYtZt  =iAlpha/beta.*iAzz0.*((1-tau)*YZ.varY+tau*YZ.covYtYtp1);
YZ.covYtp1Zt=iAlpha/beta.*iAzz0.*((1-tau)*YZ.covYtYtp1+tau*YZ.varY([2:end 1],:));
YZ.varZ    =iAzz0.*(1+(1-tau)/beta*iAlpha.*YZ.covYtZt+tau/beta*iAlpha.*YZ.covYtp1Zt);

% <ln q(y,z)> :
logDetAzz=-sum(log(iAzz0(iAzz0(:,1)>0,:))); % sum |Azzm|
Tx=YZ.i1-YZ.i0; % number of points per trj
YZ.mean_lnqyz=-dim*sum((1+log(2*pi))*(2*Tx+1)/2)+0.5*sum((logDetAzz+logDetInvSyy));

% <ln p(x|z)> : only contributes when the localization error is not a model parameter
if(exist('iV','var') && ~isempty(iV))
    YZ.mean_lnpxz=0;
    %YZ.Fs_yz=-YZ.mean_lnqyz;
else
    ot=isfinite(datV(:,1))&(datV(:,1)>0);
    YZ.mean_lnpxz=-0.5*sum(sum(log(2*pi*datV(ot,:))+((dat.x(ot,:)-YZ.muZ(ot,:)).^2+YZ.varZ(ot,:))./datV(ot,:)));
    %YZ.Fs_yz=YZ.mean_lnpxz-YZ.mean_lnqyz;
end

if(nargout>=2)
   fname=['foo_' int2str(ceil(1e9*rand)) '.mat'];
   save(fname);
   funWS=load(fname);
   delete(fname);
end
