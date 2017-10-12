function [wa,wB]=prior_transition_dwell_Bweight(N,dwellStepMean,dwellStepStd,Bweight)
% [wa,wB]=spt.prior_transition_dwell_Bweight(N,dwellStepMean,dwellStepStd,Bweight)
%
% Default transition prior, which specifies mean and std of the mean
% dwell times. The prior in the total jump probability a is a beta
% distribution, with parameters chosen to give the specified mean and
% standard deviation of the mean dwell time 1/a. 
%
% For the jump probability matrix B, we use a Dirichlet distribution with
% identical weights (pseudo-counts) Bweight for each transition.
% 
% Roughly, 0 < Bweight < 1 favors a sparse transition probability, Bweight=1
% gives a flat distribution, (same as spt.prior_transition_dwell_Bflat),
% and Bweight>1 favors a dense transition  matrix.
%
% N            : number of states to construct
% dwellSteps   : prior mean value of dwell time [timesteps]
% dwellStepStd : prior std of dwell time [time steps]
% Bweight      : Dirichlet weight of the jump probabilities wB
%
% ML 2017-10-12

if(dwellStepMean<1)
    error('prior_transition_dwell_Bweight: prior dwell time must exceed 1 timestep.')
end
if(Bweight<=0)
    error('prior_transition_dwell_Bweight: B weight must be positive.')
end

t0Var=dwellStepStd^2; % prior dwell time variance

% conditional jump probabilities are flat
wB=Bweight*(ones(N,N)-eye(N));

% mean dwell times are Gamma-distributed
wa=ones(N,2)+dwellStepMean*(dwellStepMean-1)/t0Var;
wa(:,2)=wa(:,1)*(dwellStepMean-1);

% in case there is only one hidden states, B and a are not defined in the
% model:
if(N==1)
    wB=0;
    wa=[0 1]; % there really should not be an a-variable for N=1, but
    %this is taken care of elsewhere (mostly in VBEMiterator).
end

