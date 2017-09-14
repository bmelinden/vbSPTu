        function setMLE_P0ADV(this,p0,A,D,v,npc)
            % setMLEParameters(p0,D,A,v,npc)
            % set maximum likelihood values of rate&diffusion model parameters.
            % p0,D,A: parameter mode values.
            % v     : localization error variance
            % npc   : number of pseudo-counts (default 1e5)
            
            if(~exist('npc','var'))
                npc=1e5;
            end
            this.setMLE_P0AD(p0,A,D,npc);            
            this.P.nv=npc;
            this.P.cv=v*npc;
        end
