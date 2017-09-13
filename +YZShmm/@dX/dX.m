classdef dX < YZShmm.YZS0
    % a hidden diffusive HMM with externally estimated point-wise
    % localization errors 
    properties
    end
    methods
        function this=dX(varargin)            
            % dXt(N,opt,dat,p0_init,D_init,A_init,v_init)
            % same syntax as for the YZShmm.YZS0 constructor, except
            % that the data struct dat is expected to contain estimated
            % position variances.
            this=this@YZShmm.YZS0(varargin{:});

            parName={'N','opt','dat','p0_init','A_init','D_init','v_init'};
            for k=1:min(6,nargin)
               eval([parName{k} '= varargin{' int2str(k) '};']);
            end
            %% localization variance prior
            P0v=opt.prior.positionVariance;
            switch P0v.type
                case 'mean_strength'
                    [this.P0.nv,this.P0.cv]=spt.prior_inverse_gamma_mean_strength(N,P0v.v,P0v.strength);
                case 'mode_strength'
                    [this.P0.nv,this.P0.cv]=spt.prior_inverse_gamma_mode_strength(N,P0v.v,P0v.strength);
                %case 'inv_mean_strength'
                %    [this.P0.nv,this.P0.cv]=spt.prior_inverse_gamma_invmean_strength(N,P0v.v,P0v.strength);
                otherwise
                    error(['YZShmm prior.localizationVariance.type : ' P0v.type ' not recognized.'])
            end
            this.P.nv=this.P0.nv;
            this.P.cv=this.P0.cv;
            %% set localization variance value
            this.P.nv=this.P0.nv;
            this.P.cv=this.P0.cv;
            if(exist('opt','var'))
                % first, check for given parameter values, and replace
                % with prior samples if not given
                if(exist('v_init','var') && numel(v_init)==1)
                    % then we're good!
                elseif(isfield(opt,'init') && isfield(opt.init,'vrange') && ~isempty(opt.init.vrange))
                    lnvrange=log(opt.init.vrange);
                    lnv_init=(lnvrange(1)+diff(lnvrange)*rand);
                    v_init=exp(lnv_init);
                else % sample from the prior
                    v_init=1./gamrnd(this.P0.nv,1./this.P0.cv);
                end
                % make v_init agree with ist max.lik.estimate
                npc=1e5;
                this.P.nv=npc;
                this.P.c=v_init*this.P.n;
            end
            %% initialize trajectory model
            if(nargin>=3)
                dat=varargin{3};
                this.YZ=spt.naiveYZfromX(dat,v_init);
            end
        end
        %%% got this far!!!
        P=getParameters(this,varargin);
    end
end
