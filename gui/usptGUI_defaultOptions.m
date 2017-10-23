% options that cannot be changed by the GUI
opt.trj.miscfield={};
opt.prior.initialState.type = 'flat';
opt.modelSearch.Pwarmup=10;

% other default values/recommendations
trj.Tmin = 5;

prior.diffusionCoeff.type    = 'median_strength';
prior.diffusionCoeff.strength= 2;


prior.transitionMatrix.type  = 'dwell_Bweight';
prior.transitionMatrix.Bweight  =1; % 1: flat, <1: favors sparse jump matrix, >1: favors dense jump matrix

prior.positionVariance.type    = 'median_strength';
prior.positionVariance.strength= 2;

conv.maxIter = 1e4;    % maximum number of VB iterations ([]: use default values).
conv.lnLTol  = 1e-9;   % convergence criterion for relative change in likelihood bound.
conv.parTol  = 1e-3;   % convergence criterion for M-step parameters (leave non-strict).
conv.saveErr = false;  % if true, some errors will will write a workspace dump to file, for debugging

modelSearch.YZww        = [2 3 5 8];
modelSearch.restarts    = 100;
modelSearch.Pwarmup     = 10; 
modelSearch.maxHidden   = 10; 
modelSearch.VBinitHidden= 30;

opt.modelSearch.PBF=false;
opt.modelSearch.MLEparam=true;

opt.bootstrap.bestParam=false;
opt.bootstrap.modelSelection=false;
bootstrap.bootstrapNum=300;



