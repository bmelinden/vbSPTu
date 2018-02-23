% options that cannot be changed by the GUI
opt.trj.miscfield={};
opt.prior.initialState.type = 'flat';
opt.modelSearch.Pwarmup=10;

% other default values/recommendations
trj.Tmin = 5;
trj.maxRMSE=inf;

model.class='YZShmm.dXt';

prior.diffusionCoeff.type    = 'median_strength';
prior.diffusionCoeff.strength= 1;

prior.transitionMatrix.type  = 'dwellRelStd_Bweight';
prior.transitionMatrix.dwellRelStd=10;
prior.transitionMatrix.Bweight  =1; % 1: flat, <1: favors sparse jump matrix, >1: favors dense jump matrix

prior.positionVariance.type    = 'median_strength';
prior.positionVariance.strength= 10;

conv.maxIter = 1e4;    % maximum number of VB iterations ([]: use default values).
conv.lnLTol  = 1e-9;   % convergence criterion for relative change in likelihood bound.
conv.parTol  = 1e-4;   % convergence criterion for M-step parameters (leave non-strict).
conv.dsTol   = 1e-4;   % convergence criterion for <s(t,j> and tolerance for finding cloned states
conv.saveErr = false;  % if true, some errors will will write a workspace dump to file, for debugging

modelSearch.YZww        = [3 6 10 15];
modelSearch.restarts    = 100;
modelSearch.Pwarmup     = 10; 
modelSearch.maxHidden   = 10; 
modelSearch.VBinitHidden= 30;

modelSearch.PBF=true;
modelSearch.PBFfracPos=0.1;
modelSearch.PBFrestarts=300;

modelSearch.MLEparam=true;

bootstrap.bestParam=true;
bootstrap.modelSelection=false;
bootstrap.bootstrapNum=300;



