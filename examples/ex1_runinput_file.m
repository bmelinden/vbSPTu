% SMeagol runinputfile, created 14-Mar-2018 14:29:18.
% a note on units: SMeagol does not know about units, and so the user is
% charged with using consistent units of length, time, and diffusion
% constants (units of length^2/time).
%% trj
% ----------------------------------------------------------------------- %
% trj: information about the input data.
trj.miscfield = {};
trj.Tmin=5;
trj.maxRMSE=Inf;
trj.inputfile='./ex1_data.mat';
trj.trajectoryfield='x';
trj.uncertaintyfield='v';
trj.dim=2;
trj.timestep=0.005;
trj.shutterMean=0.15;
trj.blurCoeff=0.05;
% ----------------------------------------------------------------------- %
%% output
% ----------------------------------------------------------------------- %
% output: what to output, and where.
output.outputFile='./ex1_result.mat';
% ----------------------------------------------------------------------- %
%% model
% ----------------------------------------------------------------------- %
% Model: name of the model class.
model.class='YZShmm.dXt';
% ----------------------------------------------------------------------- %
%% prior
% ----------------------------------------------------------------------- %
% Prior: how to create prior distribution for different model sizes.
prior.initialState.type='flat';
prior.diffusionCoeff.type='median_strength';
prior.diffusionCoeff.strength=1;
prior.diffusionCoeff.D=30000;
prior.transitionMatrix.type='dwellRelStd_Bweight';
prior.transitionMatrix.dwellRelStd=10;
prior.transitionMatrix.Bweight=1;
prior.transitionMatrix.dwellMean=0.025;
prior.positionVariance.type='median_strength';
prior.positionVariance.strength=10;
prior.positionVariance.v=400;
% ----------------------------------------------------------------------- %
%% init
% ----------------------------------------------------------------------- %
% init: parameters for initializing new models.
init.Drange=[ 50000     1.5e+07];
init.Trange=[ 0.01        0.05];
% ----------------------------------------------------------------------- %
%% conv
% ----------------------------------------------------------------------- %
% conv: convergence parameters.
conv.maxIter=10000;
conv.lnLTol=1e-09;
conv.parTol=0.0001;
conv.dsTol=0.0001;
conv.saveErr=false;
% ----------------------------------------------------------------------- %
%% modelSearch
% ----------------------------------------------------------------------- %
% modelSearch: methods and parameters to search for good models.
modelSearch.Pwarmup=10;
modelSearch.restarts=50;
modelSearch.VBinitHidden=20;
modelSearch.maxHidden=10;
modelSearch.YZww=[ 3           6          10          15];
modelSearch.PBF=0;
modelSearch.PBFfracPos=0.1;
modelSearch.PBFrestarts=300;
modelSearch.MLEparam=0;
% ----------------------------------------------------------------------- %
%% bootstrap
% ----------------------------------------------------------------------- %
% bootstrap: bootstrap-based uncertainty estimates of model selection and parameters.
bootstrap.bestParam=1;
bootstrap.modelSelection=false;
bootstrap.bootstrapNum=300;
% ----------------------------------------------------------------------- %
