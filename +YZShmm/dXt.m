classdef dXt < YZShmm.YZSmodel
    % a hidden diffusive HMM with externally estimated point-wise
    % localization errors 
    properties
    end
    methods
        function this=dXt(opt,dat,N)
            this=this@YZShmm.YZSmodel(opt,dat,N);
            % initialize trajectory model
            this.YZ=spt.naiveYZfromX(dat);
        end
    end    
end
