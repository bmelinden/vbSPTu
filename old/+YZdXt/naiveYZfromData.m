function YZ=naiveYZfromData(dat)
% W=mleYZdXt.init_P_dat(tau,R,D_init,dt,A_init,p0_init,dat)
%
% Initialize a diffusive HMM model with 
% dat      : trajectory data, from spt.preprocess
%

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init_P_dat, initialize variational diffusive HMM
% =========================================================================
% 
% Copyright (C) 2016 Martin Lindén
% 
% E-mail: bmelinden@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or any later
% version.   
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
%  Additional permission under GNU GPL version 3 section 7
%  
%  If you modify this Program, or any covered work, by linking or combining it
%  with Matlab or any Matlab toolbox, the licensors of this Program grant you 
%  additional permission to convey the resulting work.
%
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <http://www.gnu.org/licenses/>.
%% start of actual code

YZ=struct;


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
YZ.varZ=dat.v;

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

% lower bound contributions
YZ.mean_lnqyz=0;
YZ.mean_lnpxz=0;
YZ.Fs_yz=0;



