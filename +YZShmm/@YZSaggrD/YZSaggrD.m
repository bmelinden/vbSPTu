classdef YZSaggrD < YZS0 
    % a version of the YZS0 class which handles aggregated states
    % Conventions: 
    %   1) P0.wB(i,j)=0 indicates a dis-allowed transition, and this shall
    %   be respected for both MLE, MAP, and VB updates, including KL- and
    %   log-prior terms. 
    %   2) aggregated diffusive states are indicated by the property
    %   Dstates. if N=numStates, Dstates=[i1 i2 i3 ... iN] is a list of
    %   diffusion parameter indices such that im==ik means that state m and
    %   k have the same diffusion constant. In principle, ij>N is possible,
    %   in which case there will be a number of unused diffusion parameters
    %   that are simply ignored.
    % 
    %   - RemoveState needs to preserve the wB 0-structure and aggregation
    %   indices.
    %   - sortModel needs to clean up and reorder the aggregation indices
    %% copyright notice
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YZSaggD.m, model object in the vbUSPT package
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
        P0=struct;%('n',[],'c',[],'wPi',[],'wa',[],'wB',[],'Daggregate',[]);
        P =struct;%('n',[],'c',[],'wPi',[],'wa',[],'wB',[]);
        S =struct('pst',[],'wA',[],'lnZ',0);
        YZ=struct('i0',[],'i1',[],...
            'muY',[],'muZ',[],'varY',[],'varZ',[],...
            'covYtYtp1',[],'covYtZt',[],'covYtp1Zt',[],...
            'mean_lnqyz',0,'mean_lnpxz',0);        
        sample=struct('dim',0,'timestep',0,'shutterMean',0,'blurCoeff',0);
        conv=struct('maxIter',1e4,'lnLTol',1e-9,'parTol',1e-3,'saveErr',false);
        numStates=0;
        Dstates=[]; % diffusion parameter indices of the hidden states
        lnL=0; % log likelohood (lower bound)        
        EMexit=struct;
        comment='';
    end
    methods
        function this=YZSaggrD(varargin)
            % YZS0(N,opt,dat,p0_init,A_init,D_init)
            % construct a bare bones YZS0 object 
            %
            % N     : number of hidden states
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
            % opt, dat will result in an incomplete model object, which is
            % only useful for cloning when all object properties are
            % duplicated later. 
            %
            
            %%% got this far:
            % By default, no aggregation or disallowed transitions?
            
            parName={'N','opt','dat','p0_init','A_init','D_init'};
            for k=1:min(6,nargin)
               eval([parName{k} '= varargin{' int2str(k) '};']);
            end
            %% set up basic model structure with a number of states
            this.numStates=N;
            % parameter and prior structs
            this.P0.wPi=zeros(1,this.numStates);
            this.P0.wa =zeros(this.numStates,2);
            this.P0.wB =zeros(this.numStates,this.numStates);
            this.P0.n  =zeros(1,this.numStates);
            this.P0.c  =zeros(1,this.numStates);
            this.P=this.P0;                        
            % Kullback-Leibler divergence terms
            this.P.KL=struct;
            this.P.KL.pi=0;
            this.P.KL.a=zeros(this.numStates,1);
            this.P.KL.B=zeros(this.numStates,1);
            this.P.KL.lambda=zeros(1,this.numStates);
            % MAP log prior terms
            this.P.lnP0=struct;
            this.P.lnP0.pi=0;
            this.P.lnP0.a=zeros(this.numStates,1);
            this.P.lnP0.B=zeros(this.numStates,1);
            this.P.lnP0.lambda=zeros(1,this.numStates);
            %% sampling properties and prior parameters
            if(exist('opt','var'))
                
                opt=spt.readRuninputFile(opt); % in case optt is a runinput file
                
                % sampling parameters
                this.sample.dim=opt.trj.dim;                
                this.sample.timestep=opt.trj.timestep;
                this.sample.shutterMean=opt.trj.shutterMean; % tau
                this.sample.blurCoeff=opt.trj.blurCoeff;     % R
                beta=this.sample.shutterMean*(1-this.sample.shutterMean)-this.sample.blurCoeff; % beta = tau(1-tau)-R
                if( this.sample.shutterMean>0 && this.sample.shutterMean<1 && ...
                        this.sample.blurCoeff>0 && this.sample.blurCoeff<=0.25 && beta>0)
                else
                    error('Unphysical blur coefficients. Need 0<tau<1, 0<R<=0.25.')
                end
                % convergence parameters, if specified and non-empty
                if(isfield(opt,'conv'))
                    fn=fieldnames(this.conv);
                    for k=1:numel(fn)
                        if(isfield(opt.conv,fn{k}) && ~isempty(opt.conv.(fn{k})))
                            this.conv.(fn{k})=opt.conv.(fn{k});
                        end
                    end
                end
                % construct prior distributions
                this.P0=YZShmm.makeP0ADpriors(opt.prior,this.numStates,this.sample.timestep);
            end
            %% simple trajectory model and hidden state distributions
            if(exist('dat','var') && ~isempty(dat))
                this.YZ=spt.naiveYZfromX(dat);
                this.S.pst=ones(size(dat.x,1),this.numStates)/this.numStates;
                this.S.pst(dat.i1+1,:)=0;
                this.S.wA=ones(this.numStates,this.numStates);
            end
            %% set parameter values
            if(exist('opt','var'))
                % first, check for given parameter values, and replace
                % with prior samples if not given
                if(exist('p0_init','var') && numel(p0_init)==this.numStates)
                    p0_init=reshape(p0_init,1,this.numStates);
                else
                    % seems better to give all states equal probability to
                    % start with
                    p0_init=ones(1,this.numStates)/this.numStates;%dirrnd(this.P0.wPi);
                end
                if(exist('A_init','var') && prod(size(A_init)==this.numStates)==1)
                    % then all is well
                elseif(isfield(opt,'init') && isfield(opt.init,'Trange') && ~isempty(opt.init.Trange))
                    n_init=(opt.init.Trange(1)+diff(opt.init.Trange)*rand(this.numStates,1))/opt.trj.timestep;
                    a_init=[1./n_init 1-1./n_init];
                    B_init=ones(this.numStates)-eye(this.numStates);
                    A_init=diag(a_init(:,2))+diag(a_init(:,1))*B_init;
                else % sample from the prior
                    a_init=dirrnd(this.P0.wa);  % <a> = a_init(:,1) = prob(s(t+1)~=s(t))
                    B_init=dirrnd(this.P0.wB);
                    A_init=diag(a_init(:,2))+diag(a_init(:,1))*B_init;
                end
                if(exist('D_init','var') && numel(D_init)==this.numStates)
                    D_init=reshape(D_init,1,this.numStates);
                elseif(isfield(opt,'init') && isfield(opt.init,'Drange') && ~isempty(opt.init.Drange))
                    lnDrange=log(opt.init.Drange);
                    lnD_init=(lnDrange(1)+diff(lnDrange)*rand(this.numStates,1));
                    D_init=exp(lnD_init);
                else % sample from the prior
                    D_init=1./gamrnd(this.P0.n,1./this.P0.c)/2/this.sample.timestep;
                end
                this.setParamMLE('p0',p0_init,'A',A_init,'D',D_init);
            end
        end
        %%% misc methods, commented out until they are filled in or
        %%% determined to be simply inherited from YZS0. 
        
        %[Wbest,WNbest,lnLsearch,Nsearch,Psearch]=VBgreedyReduce(this,dat,opt,displayLevel);
        %[dlnLrel,dPmax,dPmaxName]=modelDiff(this,that);
        %%%W=removeState(this,s,opt);
        %%%ind=sortModel(this,ind);
        %[sMaxP,sVit]=converge(this,dat,varargin);
        %Piter(this,dat,iType);
        %P=getParameters(this,dat,iType);
        %setParamMLE(this,varargin);
        %displayParameters(this,varargin);
        %[Wii,Xii,W0,X0]=splitModelAndData(this,X,ii);
    end
    methods (Abstract, Access = public)
        [slnLrel,sMaxP,sVit]=Siter(this,dat,iType);
        YZiter(this,dat,iType);
    end
end
