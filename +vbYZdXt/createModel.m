function W=createModel(opt,N,X,Di,Ai,p0i)
% W=vbUSPTmodel(opt,N,X,Di,Ai,p0i)
% construct a vbYZdXt model struct based on prior parameters in
% opt. opt can be either an options struct or the name of a
% runinput file.
% opt   : runinput options struct or runinput file name
% N     : number of states
% X     : preprocessed data struct
% Di,Ai,p0i: Optional initial guess for variational mean values of model
%            parameters (strength according to data set size). If not
%            given, the mean values are sampled from the prior
%            distributions.
%
% Variational models for trajectories and hidden states are constructed
% based on the input data (using mleYZdXt.init_P_dat).

% save model options: try not to, to avoid redundant information
% opt=spt.getOptions(opt);
% W.opt=opt;

% number of states
W.numStates=N;

% dimension
W.dim=opt.dim;

% create prior distributions: ML decides to pass the arguments
% that are actually needed, rather than constructing e.g., a
% class hierarchy of priors. Philisophy is that the vbXdXmodel
% objects knows and handles its own priors, and that these
% priors might be resused by other models as well.
%% sampling properties
W.timestep=opt.timestep;
W.shutterMean=opt.shutterMean; % tau
W.blurCoeff=opt.blurCoeff;     % R
%% diffusion constant prior
switch opt.prior.diffusionCoeff.type
    case 'mean_strength'
        [W.P0.n,W.P0.c]=spt.prior_inverse_gamma_mean_strength(N,...
            2*opt.prior.diffusionCoeff.D*W.timestep,...
            opt.prior.diffusionCoeff.strength);
    case 'mode_strength'
        [W.P0.n,W.P0.c]=spt.prior_inverse_gamma_mode_strength(N,...
            2*opt.prior.diffusionCoeff.D*W.timestep,...
            opt.prior.diffusionCoeff.strength);
    case 'inv_mean_strength'
        [W.P0.n,W.P0.c]=spt.prior_inverse_gamma_invmean_strength(N,...
            2*opt.prior.diffusionCoeff.D*W.timestep,...
            opt.prior.diffusionCoeff.strength);
    otherwise
        error(['vbUSPT prior.diffusionCoeff.type : ' ...
            W.opt.prior.diffusionCoeff.type ' not recognized.'])
end
%% initial state prior
switch opt.prior.initialState.type
    case 'flat'
        W.P0.wPi=ones(1,N); % flat initial state distribution
    case 'natmet13'
        W.P0.wPi=ones(1,N)*opt.prior_piStrength/N; % the choice used in the nat. meth. 2013 paper.
    otherwise
        error(['vbUSPT prior.initialState.type : ' ...
            W.opt.prior.initialState.type ' not recognized.'])
end
%% transition prior
if(strcmp(opt.prior.transitionMatrix.type,'dwell_Bflat'))
    [W.P0.wa,W.P0.wB]=spt.prior_transition_dwell_Bflat(N,...
        opt.prior.transitionMatrix.dwellMean/W.timestep,...
        opt.prior.transitionMatrix.dwellStd/W.timestep);
elseif(strcmp(opt.prior.transitionMatrix.type,'natmet13'))
    [W.P0.wa,W.P0.wB]=priorA_natmet13(N,...
        opt.prior.transitionMatrix.dwellMean/W.timestep,...
        opt.prior.transitionMatrix.rowStrength);
else
    error(['vbUSPT prior.transitionMatrix.type : ' ...
        W.opt.prior.initialState.type ' not recognized.'])
end
%% initial parameter model
W.P=W.P0;
W.P.aggregate=1:N; % default state aggregation (no aggregation)
if(exist('Di','var') && numel(Di)==W.numStates)
    lambda_mean=reshape(2*Di*W.timestep,1,W.numStates);
else
    lambda_mean=1./gamrnd(W.P0.n,1./W.P0.c);
end
if(exist('p0i','var') && numel(p0i)==W.numStates)
    p0_mean=reshape(p0i,1,W.numStates);
else
    p0_mean=0.001+0.999*dirrnd(W.P0.wPi); % keep away from 0 and 1    
end
if(exist('Ai','var') && prod(size(Ai)==W.numStates)==1)
    a_mean=[1-diag(Ai) diag(Ai)];
    B_mean=rowNormalize(Ai-diag(diag(Ai)));
else
    % keep probabilities away from 0 and 1
    a_mean=0.001+0.999*dirrnd(W.P0.wa);
    %a_mean=a_mean(:,1); % <a>
    B_mean=0.001+0.999*dirrnd(W.P0.wB);
    Ai=diag(a_mean(:,2))+diag(a_mean(:,1))*B_mean;
end
% variational parameters
Ttot=sum(X.T); % total strength
W.P.n=W.P0.n+Ttot/W.numStates*ones(1,W.numStates);
W.P.c=W.P0.c+(W.P.n-W.P0.n).*lambda_mean;
W.P.wPi=W.P0.wPi+p0_mean*numel(X.T);
W.P.wa=W.P0.wa+Ttot*a_mean;
W.P.wB=W.P0.wB+Ttot/W.numStates*B_mean;
% Kullback-Leibler divergence terms
W.P.KL_a=zeros(W.numStates,1);
W.P.KL_B=zeros(W.numStates,1);
W.P.KL_pi=0;
W.P.KL_lambda=zeros(1,W.numStates);
%% trajectory and hidden state models
U=mleYZdXt.init_P_dat(W.shutterMean,W.blurCoeff,lambda_mean/2/W.timestep,W.timestep,Ai,p0_mean,X);
W.YZ=U.YZ;
W.YZ.mean_lnqyz=0;
W.YZ.mean_lnpxz=0;
W.YZ.Fs_yz=0;
W.S=U.S;
