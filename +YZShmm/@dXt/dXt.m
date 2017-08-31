classdef dXt < YZShmm.YZSmodel
    % a hidden diffusive HMM with externally estimated point-wise
    % localization errors 
    properties
    end
    methods
        function this=dXt(varargin)            
            % dXt(N,opt,dat,p0_init,D_init,A_init)
            % same syntax as for the YZShmm.YZSmodel constructor, except
            % that the data struct dat is expected to contain estimated
            % position variances.
            this=this@YZShmm.YZSmodel(varargin{:});

            % initialize trajectory model
            if(nargin>=3)
                dat=varargin{3};
                this.YZ=spt.naiveYZfromX(dat);
            end
        end
    end
end
