classdef YZSmodel < handle
    % handle class inheritance makes the object call pass by reference,
    % i.e., one can manipulate the internal state of the object without
    % explicitly accepting an object output. 
    
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
        S =struct('pst',[],'wA',[],'lnZ',0);
        YZ=struct('i0',[],'i1',[],...
            'muY',[],'muZ',[],'varY',[],'varZ',[],...
            'covYtYtp1',[],'covYtZt',[],'covYtp1Zt',[],...
            'mean_lnqyz',0,'mean_lnpxz',0);        
        numStates=0;
        lnL=0; % log likelohood (lower bound)        
        convergence=struct;
        comment='';
    end
    methods
        function this=YZSmodel(varargin)
            % YZSmodel(N,opt,dat,p0_init,A_init,D_init)
            % construct a bare bones YZSmodel object 
            %
            % N     : number of states
            % opt   : optional runinput options struct or runinput file
            %         name. If given, a prior is constructed, and parameter
            %         mean values (p0,A,D) are sampled from the prior
            %         distributions with strength 1e5.
            % dat   : preprocessed data struct, from spt.preprocess, not
            %         necessarily with localization variance fields. If
            %         given, the variational distributions for hidden 
            %         states and paths are initialized. 
            % initial parameters :
            % p0_init,A_init,D_init : specify parameter most likely values.
            %
            % opt, dat, and initial parameters are optional, but omitting
            % opt, dat will reslt in an incomplete model object, which is
            % only useful for cloning when all object properties are
            % duplicated later. 
                        
            parName={'N','opt','dat','p0_init','A_init','D_init'};
            for k=1:min(6,nargin)
               eval([parName{k} '= varargin{' int2str(k) '};']);
            end
            %% set up basic model structure with a number of states
            this.numStates=N;
            
            % dimension
            % parameter and prior structs
            this.P0.wPi=zeros(1,this.numStates);
            this.P0.wa =zeros(this.numStates,2);
            this.P0.wB =zeros(this.numStates,this.numStates);
            this.P0.n  =zeros(1,this.numStates);
            this.P0.c  =zeros(1,this.numStates);
            this.P=this.P0;                        
            % Kullback-Leibler divergence terms
            this.P.KL_pi=0;
            this.P.KL_a=zeros(this.numStates,1);
            this.P.KL_B=zeros(this.numStates,1);
            this.P.KL_lambda=zeros(1,this.numStates);
            %% sampling properties and prior parameters
            if(exist('opt','var'))
                opt=spt.getOptions(opt); % in case optt is a runinput file
                
                % sampling parameters
                this.param.dim=opt.trj.dim;                
                this.param.timestep=opt.trj.timestep;
                this.param.shutterMean=opt.trj.shutterMean; % tau
                this.param.blurCoeff=opt.trj.blurCoeff;     % R
                beta=this.param.shutterMean*(1-this.param.shutterMean)-this.param.blurCoeff; % beta = tau(1-tau)-R
                if( this.param.shutterMean>0 && this.param.shutterMean<1 && ...
                        this.param.blurCoeff>0 && this.param.blurCoeff<=0.25 && beta>0)
                else
                    error('Unphysical blur coefficients. Need 0<tau<1, 0<R<=0.25.')
                end
            
                % construct prior distributions
                this.P0=YZShmm.makeP0ADpriors(opt.prior,this.numStates,this.param.timestep);
            end
            %% simple trajectory model and hidden state distributions
            if(exist('dat','var') && ~isempty(dat))
                this.YZ=spt.naiveYZfromX(dat);
                this.S.pst=ones(size(dat.x,1),this.numStates)/this.numStates;
                this.S.pst(dat.i1+1,:)=0;
                this.S.wA=ones(this.numStates,this.numStates);
            end
            %% set parameter values
            % fisrt, check for given parameter values, and replace
            % with prior samples if not given
            if(exist('p0_init','var') && numel(p0_init)==this.numStates)
                p0_init=reshape(p0_init,1,this.numStates);
            else
                p0_init=dirrnd(this.P0.wPi);
            end
            if(exist('A_init','var') && prod(size(A_init)==this.numStates)==1)
                % then all is wewll
            else
                a_init=dirrnd(this.P0.wa);  % <a> = a_init(:,1) = prob(s(t+1)~=s(t))
                B_init=dirrnd(this.P0.wB);                
                A_init=diag(a_init(:,2))+diag(a_init(:,1))*B_init;
            end
            if(exist('D_init','var') && numel(D_init)==this.numStates)
                D_init=reshape(D_init,1,this.numStates);
            else
                D_init=1./gamrnd(this.P0.n,1./this.P0.c)/2/this.param.timestep;
            end
            this.setParameters(p0_init,A_init,D_init);
        end
        function setParameters(this,p0,A,D,npc)
            % setParameters(p0,D,A,npc)
            % set maximum likelihood values of rate&diffusion model parameters.
            % p0,D,A: parameter mode values.
            % npc   : strength (number of pseudocounts) in the parameter
            %         distributions. Must be >=2. Default = 1e5.
            
            if(~exist('npc','var') || isempty(npc) || npc<2)
                npc=1e5;
            end
            % initial parameters
            this.P.wPi=p0*npc;
            
            wA=npc*A;
            wB=wA-diag(diag(wA));
            wa=[sum(wB,2) diag(wA)];
            this.P.wa=wa;
            this.P.wB=wB;
            if(this.numStates==1)
                this.P.wa=npc;
                this.P.wB=0;
            end
            this.P.n=npc/this.numStates*ones(1,this.numStates);
            this.P.c=2*D*this.param.timestep.*this.P.n; 
        end
        function that=clone(this)
            % clone()
            % initialize a copy of the present object with exactly the same
            % attributes
            
            % initialize new object of the same class as this, possibly a
            % subclass of YZSmodel
            that=eval([class(this) '(' int2str(this.numStates) ');']);
            
            prop=fieldnames(this);
            for k=1:numel(prop)
                this.(prop{k})= that.(prop{k});
            end
        end
    end
    methods (Abstract, Access = public)
        Siter(this,dat,iType);
        YZiter(this,dat,iType);
        Piter(this,dat,iType);
        %this=converge(this,dat,iType);
        
        %S=estimateStates(this,dat,iType);
        %P=estimateParameters(this,dat);
        
        %this=remove1state(this,dat,s);
        %this=splitModel(this,dat,s);
        %this=sortModel(this,ind,p)
        
        %this=initParameters(this,opt,dat,varargin);

        %[dlnL,dM]=relDiff(this,W0);
    end
end
