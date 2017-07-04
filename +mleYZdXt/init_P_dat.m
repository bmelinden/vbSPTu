function W=init_P_dat(tau,R,Ddt_init,A_init,p0_init,dat)
% W=EMhmm.init_P_dat(tau,R,Ddt_init,A_init,p0_init,dat)
%
% Initialize a diffusive HMM model with 
% tau,R    : blur parameters
% Ddt_init : diffusion constant*timestep
% A_init   : transition matrix 
% p0_init  : initial state probability
% dat      : trajectory data, from EMhmm.preprocess
%
% Number of hidden states given by the length of Ddt_init.
% ML 2016-07-04

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EMhmm.init_P_dat, initialize variational diffusive HMM
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


W=struct;   % model struct
W.N=length(Ddt_init);
W.dim=dat.dim;

W.i0  = dat.i0;
W.i1  = dat.i1+1;
W.lnL=0;    % log likelihood
W.tau=tau;
W.R=R;
W.pOcc=zeros(1,W.N);

% parameter subfield
W.P=struct; 
W.P.lambda=2*Ddt_init;
W.P.A=A_init;
W.P.p0=reshape(p0_init,1,W.N);

% hidden path subfield, with no Infs or NaNs
W.YZ=struct;
W.YZ.muZ=dat.x;
W.YZ.varZt=dat.v;

% fill out missing positions and uncertainties by linear interpolation
ind0=find( isfinite(dat.v(:,1)));
ind1=find(~isfinite(dat.v(:,1)));
for d=1:W.dim
    W.YZ.muZ(ind1,d)=interp1(ind0,W.YZ.muZ(ind0,d),ind1,'linear','extrap');
    W.YZ.varZt(ind1,d)=interp1(ind0,W.YZ.varZt(ind0,d),ind1,'linear','extrap');
end
W.YZ.muZ(W.i1,:)=0;
W.YZ.muY=W.YZ.muZ;
W.YZ.muY(W.i1,:)=W.YZ.muZ(W.i1-1,:); % unobserved last positions
W.YZ.varYt=W.YZ.varZt;
W.YZ.varYt(W.i1,:)=W.YZ.varZt(W.i1-1,:); % unobserved last positions

% covariances: no correlations
W.YZ.covYtYtp1=zeros(size(dat.v));
W.YZ.covYtZt  =zeros(size(dat.v));
W.YZ.covYtp1Zt=zeros(size(dat.v));

% lower bound contributions
W.YZ.mean_lnqyz=0;
W.YZ.mean_lnpxz=0;
W.YZ.Fs_yz=0;

% initialize hidden state field
W.S=struct;
W.S.pst=ones(size(dat.x,1),W.N)/W.N;
W.S.pst(W.i1,:)=0;
W.S.wA=ones(W.N,W.N);




