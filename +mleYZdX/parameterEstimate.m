function [est,est2]=parameterEstimate(W,varargin)
% [est,est2]=parameterEstimate(W,dt,...)
% Estimate some model properties and parameters.
%
% minimal operation:
%
% W     : converge HMM model struct
%
% est   : parameter struct with fields
%             D: diffusion constant
%        lambda: 2*D*dt
%            p0: initial state probability
%          pOcc: total occupancy (from variational state distribution)
%           pSS: steady state of the transition matrix A
%             A: transition matrix
%    dwellSteps: mean dwell time in units of time step
%     dwellTime: mean dwell times in units of time
% est2  : same as est, but for the 2-state coarse-grained model described
%         below.
%
% optional input: parameterEstimate(W,dt,'2state',Dthr) produces additional
%               parameter estimates est2 for a coarse-grained model with a
%               slow (D<=Dthr) and a fast (D>Dthr) state, by simply adding
%               up the summary statistics into two groups. If either of the
%               two groups are empty, all parameter estimates are NaN.
%
% ML 2017-07-31 : adapted to mleYZdXs and mleYZdX and models

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameterEstimate, estimate some model properties from diffusive HMM
% =========================================================================
% 
% Copyright (C) 2017 Martin Lindén
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

% the version with time-dependent errors handles this model as a special
% case
[est,est2]=mleYZdXs.parameterEstimate(W,varargin{:});
