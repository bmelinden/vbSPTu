function YZ=naiveYZfromX(dat,v)
% YZ=naiveYZfromXV(dat)
%
% Initialize a diffusive hidden path model from trajectory fields in the
% data + an estimated average variance, and filling out the nan/inf entries
% by interpolation. 
% dat      : trajectory data, from spt.preprocess
% v        : optional localization variance estimate. If not given, assume
%            a small signal to noise ratio and take v ~ 0.001*median( steplength^2) 


%% start of actual code

YZ=struct;
if(~exist('v','var')  || isempty(v))
    dx2=diff(dat.x,1).^2;
    v=0.001*median(dx2(isfinite(dx2)));
    clear dx2
end

% hidden path subfield, with no Infs or NaNs
YZ.i0  = dat.i0;
YZ.i1  = dat.i1+1;
Tmax=sum(YZ.i1-YZ.i0+1);
% subfields in a specific order
% mean values
YZ.muY =zeros(Tmax,dat.dim);
YZ.muZ =zeros(Tmax,dat.dim);
% variances
YZ.varY=zeros(Tmax,dat.dim);
YZ.varZ=zeros(Tmax,dat.dim);
% covarinces: all zero
YZ.covYtYtp1=zeros(Tmax,dat.dim);
YZ.covYtZt  =zeros(Tmax,dat.dim);
YZ.covYtp1Zt=zeros(Tmax,dat.dim);

YZ.muZ=dat.x;
YZ.varZ=v*ones(size(dat.x));

% fill out missing positions and uncertainties by linear interpolation
ind0=find( isfinite(dat.x(:,1)));
ind1=find(~isfinite(dat.x(:,1)));
for d=1:dat.dim
    YZ.muZ(ind1,d)=interp1(ind0,YZ.muZ(ind0,d),ind1,'linear','extrap');
    YZ.varZ(ind1,d)=interp1(ind0,YZ.varZ(ind0,d),ind1,'linear','extrap');
end
YZ.muZ(YZ.i1,:)=0;
YZ.muY=YZ.muZ;
YZ.muY(YZ.i1,:)=YZ.muZ(YZ.i1-1,:); % unobserved last positions
YZ.varY=YZ.varZ;
YZ.varY(YZ.i1,:)=YZ.varZ(YZ.i1-1,:); % unobserved last positions

% covariances: no correlations
YZ.covYtYtp1=zeros(size(dat.x));
YZ.covYtZt  =zeros(size(dat.x));
YZ.covYtp1Zt=zeros(size(dat.x));

% log likelihood contributions
YZ.mean_lnqyz=0;
YZ.mean_lnpxz=0;

