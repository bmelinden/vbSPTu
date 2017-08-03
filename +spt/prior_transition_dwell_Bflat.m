function [wa,wB]=prior_transition_dwell_Bflat(N,dwellStepMean,dwellStepStd)
% [wa,wB]=prior_transition_dwell_Bflat(N,dwellSteps,dwellStepStd)
% 
% Default transition prior, which specifies mean and std of the mean
% dwell times, and uses a flat Dirichlet prior for each row of the jump
% matrix B.
%
% N         : number of states to construct
% dwellSteps: prior mean value of dwell time [timesteps]
% dwellStepStd : prior std of dwell time [time steps]

if(dwellStepMean<1)
    error('prior_transition_dwell_Bflat: prior dwell time must exceed 1 timestep')
end

t0Var=dwellStepStd^2; % prior dwell time variance

% conditional jump probabilities are flat
wB=ones(N,N)-eye(N);

% mean dwell times are Gamma-distributed
wa=ones(N,2)+dwellStepMean*(dwellStepMean-1)/t0Var;
wa(:,2)=wa(:,1)*(dwellStepMean-1);

% in case there is only one hidden states, B and a are not defined in the
% model:
if(N==1)
    wB=0;
    %wa=[0 0]; % there really should not be an a-variable for N=1, but
    %this is taken care of elsewhere (mostly in VBEMiterator).
end

