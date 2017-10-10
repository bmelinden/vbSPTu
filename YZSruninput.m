% Martin Linden 2017-09-01
% a reference runinput file for the YZShmm suite of model objects


%% Input trajectories and sample properties
% this section specifies the location and proiperties of the input data to
% be used in the analysis
trj.inputfile = [];
trj.trajectoryfield  = 'x';
trj.uncertaintyfield = 'v';
trj.miscfield={'s','y','z'};
% this section is devoted to properties of the data that are needed to
% model it
dt=5e-3;            % s
tE=3/5*dt;              % exposure time
trj.timestep = dt;     % in [s]
trj.shutterMean=tE/dt/2; % shutter mean, tau          
trj.blurCoeff  =tE/dt/6; % Berglund blur coefficient R
trj.dim = 2;
trj.Tmin = 5;         % minimum number of positions per trajectory >=2 is 
clear dt tE
%% default model type (constructor handle, e.g., @YZShmm.xxx)
model=@YZShmm.dXt; 
%% Prior distributions
% Diffusion constants
%prior.diffusionCoeff.type    = 'mean_strength';
prior.diffusionCoeff.type    = 'mode_strength';
prior.diffusionCoeff.D    = 0.1e6;       % prior diffusion constant [length^2/time] in same length units as the input data.
prior.diffusionCoeff.strength= 2;        % strength of diffusion constant prior, number of pseudocounts (positive).

% initial state distribution
prior.initialState.type = 'flat';
%prior.initialState.type = 'natmet13';
%prior.initialState.strength = 10;

prior.transitionMatrix.type  = 'dwell_Bflat';
prior.transitionMatrix.dwellMean = 10*trj.timestep;      % prior dwell time in [s]. Must be greater than timestep (recommended > 2*timestep)
prior.transitionMatrix.dwellStd  = 100*trj.timestep;  % standard deviation of prior dwell times [s]. 

%prior.transitionMatrix.type = 'natmet13';
%prior.transitionMatrix.dwellMean = 10*timestep;      % prior dwell time in [s].
%prior.transitionMatrix.dwellStrength = 20;  % transition rate strength (number of pseudocounts). Recommended to be at least 2*prior_tD/timestep.

prior.positionVariance.type    = 'mode_strength';
prior.positionVariance.v       = 20^2; % units of length^2
prior.positionVariance.strength= 2;

prior.detachment.type='';
%% initial parameter guess
% if fields are left out or empty, the model constructor will sample from
% the prior distribution instead.
init.Drange = [0.01 10]*1e6;   % interval for diffusion constant initial guess [length^2/time] in same length units as the input data.
init.Trange = [2 20]*trj.timestep;     % interval for mean dwell time initial guess in [s].
% It is recommended to keep the initial tD guesses on the lower end of the expected spectrum.
init.vrange = [5 50].^2; % interval for localization variance initial value(s), in units of length^2

%% convergence criteria (leave empty to use model defaults)
conv.maxIter = 1e4;    % maximum number of VB iterations ([]: use default values).
conv.lnLTol  = 1e-8;   % convergence criterion for relative change in likelihood bound.
conv.parTol  = 1e-3;   % convergence criterion for M-step parameters (leave non-strict).
conv.saveErr = false;  % if true, some errors will will write a workspace dump to file, for debugging
%% parallellization
compute.parallelize_config = false; % controls if the parallell_Start and parallell_end commands are executed
compute.parallel_start = 'theSPTpool=gcp;';  % executed before the parallelizable loop.
compute.parallel_end = 'delete(theSPTpool)'; % executed after the parallelizable loop.
%% model search
modelSearch.YZww      = 2:6; % range of smoothing windows for running average initialization
modelSearch.restarts  = 100; % number of independent restarts for model searches
modelSearch.Pwarmup   = 10; % number of warmup iterations without parameter updates 
modelSearch.maxHidden = 10; % maximum model size to return from multi-model search
modelSearch.VBinitHidden= 25; % starting model model size for greedy VB model search
%% computing and optimization options
%% cross-validation / pseudo Bayes factors
%% bootstrap
%% not-yet used options
return
% HMM analysis output
out.outputFile = './foo.mat';
out.jobID = '';
% Bootstrapping on individual trajectories
compute.bootstrapNum =  100; % for production, more bootstrap iterations are better
compute.fullBootstrap = false; % this option is not implemented yet
% output 
% This section sepifices where the output of the analysis is to be saved


% Evaluate extra estimates including Viterbi paths
compute.stateEstimate = 0;

