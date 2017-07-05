function W=createModel(opt,N,X)
        % W=vbUSPTmodel(opt,N,X)
        % construct a vbYZdXt model struct based on prior parameters in
        % opt. opt can be either an options struct or the name of a
        % runinput file.
        % opt   : runinput options struct or runinput file name
        % N     : number of states
        % X     : preprocessed data struct
        
        % save model options: try not to, to avoid redundant information
        % opt=vbspt.getOptions(opt);
        % W.opt=opt;
        
        % number of states
        W.numStates=N;
        W.sAggregate=1:N; % default state aggregation (no aggregation)
        
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
                [W.P0.n,W.P0.c]=vbspt.prior_inverse_gamma_mean_strength(N,...
                    2*opt.prior.diffusionCoeff.D*W.timestep,...
                    opt.prior.diffusionCoeff.strength);
            case 'mode_strength'
                [W.P0.n,W.P0.c]=vbspt.prior_inverse_gamma_mode_strength(N,...
                    2*opt.prior.diffusionCoeff.D*W.timestep,...
                    opt.prior.diffusionCoeff.strength);
            case 'inv_mean_strength'
                [W.P0.n,W.P0.c]=vbspt.prior_inverse_gamma_invmean_strength(N,...
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
            [W.P0.wa,W.P0.wB]=vbspt.prior_transition_dwell_Bflat(N,...
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
        %% parameter model = prior
        W.P=W.P0;
        %% empty trajectory model
        dim=W.dim;
        if(~isempty(X))
            W.YZ.i0=reshape(X.i0,length(X.i0),1);
            W.YZ.i1=reshape(X.i1,length(X.i1),1)+1;
            Tmax=W.YZ.i1(end);
        else
            W.YZ.i0=[];
            W.YZ.i1=[];
            Tmax=1;
        end
        % variances
        W.YZ.varY=zeros(Tmax,dim);
        W.YZ.varZ=zeros(Tmax,dim);
        % covarinces: all zero
        W.YZ.sigYYp1=zeros(Tmax,dim);
        W.YZ.sigYZ  =zeros(Tmax,dim);
        W.YZ.sigYp1Z=zeros(Tmax,dim);
        % mean values
        W.YZ.muY =zeros(Tmax,dim);
        W.YZ.muZ =zeros(Tmax,dim);
    end
