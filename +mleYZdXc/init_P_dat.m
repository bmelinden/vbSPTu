function W=init_P_dat(tau,R,Ddt_init,A_init,p0_init,v_init,dat)
% W=mleYZdXc.init_P_dat(tau,R,Ddt_init,A_init,p0_init,v_init,dat)
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

W=struct;   % model struct
W.numStates=length(Ddt_init);
W.dim=dat.dim;

W.lnL=0;    % log likelihood
W.shutterMean=tau;
W.blurCoeff=R;
W.pOcc=zeros(1,W.numStates);

% parameter subfield
W.P=struct; 
W.P.lambda=2*Ddt_init;
W.P.A=A_init;
W.P.p0=reshape(p0_init,1,W.numStates);
W.P.v=v_init;

% hidden path subfield, with no Infs or NaNs
W.YZ=struct;
W.YZ.i0  = dat.i0;
W.YZ.i1  = dat.i1+1;
W.YZ.muZ=dat.x;
W.YZ.varZt=ones(size(dat.x))*v_init;

% fill out missing positions and uncertainties by linear interpolation
ind0=find( isfinite(dat.x(:,1)));
ind1=find(~isfinite(dat.x(:,1)));
for d=1:W.dim
    W.YZ.muZ(ind1,d)=interp1(ind0,W.YZ.muZ(ind0,d),ind1,'linear','extrap');
    %W.YZ.varZt(ind1,d)=interp1(ind0,W.YZ.varZt(ind0,d),ind1,'linear','extrap');
end
W.YZ.muZ(W.YZ.i1,:)=0;
W.YZ.muY=W.YZ.muZ;
W.YZ.muY(W.YZ.i1,:)=W.YZ.muZ(W.YZ.i1-1,:); % unobserved last positions
W.YZ.varYt=W.YZ.varZt;
W.YZ.varYt(W.YZ.i1,:)=W.YZ.varZt(W.YZ.i1-1,:); % unobserved last positions

% covariances: no correlations
W.YZ.covYtYtp1=zeros(size(dat.x));
W.YZ.covYtZt  =zeros(size(dat.x));
W.YZ.covYtp1Zt=zeros(size(dat.x));

% lower bound contributions
W.YZ.mean_lnqyz=0;
W.YZ.mean_lnpxz=0;
W.YZ.Fs_yz=0;

% initialize hidden state field: a really guess, should probably be update
% first
W.S=struct;
W.S.pst=ones(size(dat.x,1),W.numStates)/W.numStates;
W.S.pst(W.YZ.i1,:)=0;
W.S.wA=ones(W.numStates,W.numStates);




