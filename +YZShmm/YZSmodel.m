classdef YZSmodel
    % < handle ?
    % handle class inheritance would make it possible to manipulate
    % internal properties without making a copy
    
    %% copyright notice
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % vbXdXmodel.m, model object in the vbUSPT package
    % =========================================================================
    %
    % Copyright (C) 2013 Martin Lindén and Fredrik Persson
    %
    % E-mail: bmelinden@gmail.com, freddie.persson@gmail.com
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
    properties
        param=struct('dim',0,'timestep',0,'shutterMean',0,'blurCoeff',0);
        P0=struct;%('n',[],'c',[],'wPi',[],'wa',[],'wB',[],'Daggregate',[]);
        P =struct;%('n',[],'c',[],'wPi',[],'wa',[],'wB',[]);
        S =struct('pst',[],'wA',[],'lnZs',0);
        YZ=struct('i0',[],'i1',[],...
            'muY',[],'muZ',[],'varY',[],'varZ',[],...
            'covYtYtp1',[],'covYtZt',[],'covYtp1Zt',[],...
            'mean_lnqyz',0,'mean_lnpxz',0);
        
        numStates=0;
        convergence=struct;
        comment='';
        lnL=-inf; % log likelohood (lower bound)
        opt=struct;
    end
    methods
        function this=YZSmodel(opt,dat,N,p0_init,A_init,D_init,npc)
            % YZSmodel(opt,dat,N)
            % construct a YZS model object based on prior parameters in
            % opt. opt can be either an options struct or the name of a
            % runinput file.
            % opt   : runinput options struct or runinput file name
            % N     : number of states
            % dat   : preprocessed data struct, from spt.preprocess. If not
            %         given, YZSmodel tries to read from the runinput options.
            %         If that fails, an error is thrown.
            % initial parameters :
            % p0_init,D_init,A_init : specify parameter mean values. Default: sample
            %                         from the prior distributions, if opt.prior exist.
            %                         Otherwise, all prior and parameter fields are
            %                         set to zero.
            % npc   : strength (number of pseudocounts) in the parameter distributions.
            %         Default = number of steps in the data set.
            %
            % a variational path model q(Y,Z) is constructed from data
            % positions, and assuming var(y_t)=var(z_t)=0.01*<x(t+1)-x(t))^2>
            
            %% set up basic model structure
            this.numStates=N;
            
            % dimension
            this.param.dim=opt.trj.dim;
            % sampling properties
            this.param.timestep=opt.trj.timestep;
            this.param.shutterMean=opt.trj.shutterMean; % tau
            this.param.blurCoeff=opt.trj.blurCoeff;     % R
            beta=this.param.shutterMean*(1-this.param.shutterMean)-this.param.blurCoeff; % beta = tau(1-tau)-R
            if( this.param.shutterMean>0 && this.param.shutterMean<1 && ...
                    this.param.blurCoeff>0 && this.param.blurCoeff<=0.25 && beta>0)
            else
                error('Unphysical blur coefficients. Need 0<tau<1, 0<R<=0.25.')
            end
            
            % parameter and prior structs
            this.P0.wPi=zeros(1,this.numStates);
            this.P0.wa =zeros(this.numStates,2);
            this.P0.wB =zeros(this.numStates,this.numStates);
            this.P0.n  =zeros(1,this.numStates);
            this.P0.c  =zeros(1,this.numStates);
            this.P=this.P0;
            
            %% construct prior distributions and sample parameters
            if(~isfield(opt,'prior'))
                % if no prior, clean up the struct so that computations that
                % use the prior will not fail silently
                this.P0=struct;
            else
                %% initial state prior
                switch opt.prior.initialState.type
                    case 'flat'
                        this.P0.wPi=ones(1,N); % flat initial state distribution
                    case 'natmet13'
                        this.P0.wPi=ones(1,N)*opt.prior_piStrength/N; % the choice used in the nat. meth. 2013 paper.
                    otherwise
                        error(['uSPT prior.initialState.type : ' ...
                            this.opt.prior.initialState.type ' not recognized.'])
                end
                %% transition prior
                if(strcmp(opt.prior.transitionMatrix.type,'dwell_Bflat'))
                    [this.P0.wa,this.P0.wB]=spt.prior_transition_dwell_Bflat(N,...
                        opt.prior.transitionMatrix.dwellMean/this.param.timestep,...
                        opt.prior.transitionMatrix.dwellStd/this.param.timestep);
                elseif(strcmp(opt.prior.transitionMatrix.type,'natmet13'))
                    [this.P0.wa,this.P0.wB]=priorA_natmet13(N,...
                        opt.prior.transitionMatrix.dwellMean/this.param.timestep,...
                        opt.prior.transitionMatrix.rowStrength);
                else
                    error(['vbUSPT prior.transitionMatrix.type : ' ...
                        this.opt.prior.initialState.type ' not recognized.'])
                end
                %% diffusion constant prior
                switch opt.prior.diffusionCoeff.type
                    case 'mean_strength'
                        [this.P0.n,this.P0.c]=spt.prior_inverse_gamma_mean_strength(N,...
                            2*opt.prior.diffusionCoeff.D*this.param.timestep,...
                            opt.prior.diffusionCoeff.strength);
                    case 'mode_strength'
                        [this.P0.n,this.P0.c]=spt.prior_inverse_gamma_mode_strength(N,...
                            2*opt.prior.diffusionCoeff.D*this.param.timestep,...
                            opt.prior.diffusionCoeff.strength);
                    case 'inv_mean_strength'
                        [this.P0.n,this.P0.c]=spt.prior_inverse_gamma_invmean_strength(N,...
                            2*opt.prior.diffusionCoeff.D*this.param.timestep,...
                            opt.prior.diffusionCoeff.strength);
                    otherwise
                        error(['vbUSPT prior.diffusionCoeff.type : ' ...
                            this.opt.prior.diffusionCoeff.type ' not recognized.'])
                end
                %% Kullback-Leibler divergence terms
                this.P.KL_pi=0;
                this.P.KL_a=zeros(this.numStates,1);
                this.P.KL_B=zeros(this.numStates,1);
                this.P.KL_lambda=zeros(1,this.numStates);
                %% initial parameters
                if(~exist('npc','var') || isempty(npc) || npc<1)
                    npc=sum(dat.T); % total strength
                end
                if(exist('p0_init','var') && numel(p0_init)==this.numStates)
                    p0_mean=reshape(p0_init,1,this.numStates);
                else
                    p0_mean=0.001+0.999*dirrnd(this.P0.wPi); % keep away from 0 and 1
                end
                if(exist('p0_mean','var'))
                    this.P.wPi=this.P0.wPi+p0_mean*npc;
                end
                if(exist('A_init','var') && prod(size(A_init)==this.numStates)==1)
                    a_mean=[1-diag(A_init) diag(A_init)];
                    B_mean=rowNormalize(A_init-diag(diag(A_init)));
                else
                    % keep probabilities away from 0 and 1
                    a_mean=0.001+0.999*dirrnd(this.P0.wa);
                    %a_mean=a_mean(:,1); % <a>
                    B_mean=0.001+0.999*dirrnd(this.P0.wB);
                end
                if(exist('a_mean','var'))
                    this.P.wa=this.P0.wa+npc*a_mean;
                    this.P.wB=this.P0.wB+npc/this.numStates*B_mean;
                end
                if(exist('D_init','var') && numel(D_init)==this.numStates)
                    lambda_mean=reshape(2*D_init*this.param.timestep,1,this.numStates);
                else
                    lambda_mean=1./gamrnd(this.P0.n,1./this.P0.c);
                end
                if(exist('lambda_mean','var'))
                    this.P.n=this.P0.n+npc/this.numStates*ones(1,this.numStates);
                    this.P.c=this.P0.c+(this.P.n-this.P0.n).*lambda_mean;
                end
            end
            %% uniform hidden state distribution
            this.S.pst=ones(size(dat.x,1),this.numStates)/this.numStates;
            this.S.pst(dat.i1+1,:)=0;
            this.S.wA=ones(this.numStates,this.numStates);
            %% simple trajectory model
            this.YZ=spt.naiveYZfromX(dat);
        end
        
    end
    methods (Abstract, Access = public)
        
        this= Siter(this,dat,iType);
        this=YZiter(this,dat,iType);
        this= Piter(this,dat,iType);
        this=converge(this,dat,iType);

        this=remove1state(this,dat,s);
        this=splitModel(this,dat,s);
        this=sortModel(this,ind,p)
        
        this=initParameters(this,opt,dat,varargin);
        P=estimateParameters(this,dat);
        [dlnL,dM]=modelConvergence(W1,W2);
    end
end
