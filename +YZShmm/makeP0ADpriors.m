function P0=makeP0ADpriors(prior,N,dt)
% makeP0ADpriors(prior,N,dt)
% construct prior distributions from a prior field (prior)
%
% prior     : prior parameter struct (as in opt.prior)
% N         : number of states
% dt        : sampling timestep

%% initial state prior
P0=struct;
switch prior.initialState.type
    case 'flat'
        P0.wPi=ones(1,N); % flat initial state distribution
    case 'natmet13'
        P0.wPi=ones(1,N)*prior_piStrength/N; % the choice used in the nat. meth. 2013 paper.
    otherwise
        error(['YZShmm prior.initialState.type : ' ...
            prior.initialState.type ' not recognized.'])
end
%% transition prior
switch prior.transitionMatrix.type
    case 'dwell_Bflat'
        [P0.wa,P0.wB]=spt.prior_transition_dwell_Bflat(N,...
            prior.transitionMatrix.dwellMean/dt,...
            prior.transitionMatrix.dwellStd/dt);
    case 'dwell_Bweight'
        [P0.wa,P0.wB]=spt.prior_transition_dwell_Bweight(N,...
            prior.transitionMatrix.dwellMean/dt,...
            prior.transitionMatrix.dwellStd/dt,...
            prior.transitionMatrix.Bweight);        
    case 'natmet13'
        [P0.wa,P0.wB]=spt.priorA_natmet13(N,...
            prior.transitionMatrix.dwellMean/dt,...
            prior.transitionMatrix.rowStrength);
    otherwise
        error(['YZShmm prior.transitionMatrix.type : ' ...
            prior.initialState.type ' not recognized.'])
end
%% diffusion constant prior
switch prior.diffusionCoeff.type
    case 'mean_strength'
        [P0.n,P0.c]=spt.prior_inverse_gamma_mean_strength(N,...
            2*prior.diffusionCoeff.D*dt,...
            prior.diffusionCoeff.strength);
    case 'mode_strength'
        [P0.n,P0.c]=spt.prior_inverse_gamma_mode_strength(N,...
            2*prior.diffusionCoeff.D*dt,...
            prior.diffusionCoeff.strength);
    case 'inv_mean_strength'
        [P0.n,P0.c]=spt.prior_inverse_gamma_invmean_strength(N,...
            2*prior.diffusionCoeff.D*dt,...
            prior.diffusionCoeff.strength);
    otherwise
        error(['YZShmm prior.diffusionCoeff.type : ' ...
            prior.diffusionCoeff.type ' not recognized.'])
end
end
