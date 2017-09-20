function setParamMLE(this,varargin)
% MLEParameters('param1',value1,'param2',value2,...)
% set MLE parameter values
% set maximum likelihood values of rate&diffusion model parameters.
% Parameter-value pairs:
%
% p0,D,A: parameter mode values.
% npc   : number of pseudo-counts (default 1e5), setting it
%         only affects arguments later in the parameter-value
%         list.
npc=1e5;

% initial parameters
for k=1:2:numel(varargin)
    param=varargin{k};
    value=varargin{k+1};
    switch lower(param)
        case 'p0'
            p0=reshape(value,1,this.numStates);
            this.P.wPi=p0*npc;
        case 'a'
            A=value;
            wA=npc*A;
            wB=wA-diag(diag(wA));
            wa=[sum(wB,2) diag(wA)];
            this.P.wa=wa;
            this.P.wB=wB;
            if(this.numStates==1)
                this.P.wa=[0 npc];
                this.P.wB=0;
            end
        case 'd'
            D=reshape(value,1,this.numStates);
            this.P.n=npc/this.numStates*ones(1,this.numStates);
            this.P.c=2*this.sample.timestep*D.*this.P.n;
        case 'npc'
            npc=reshape(value,1,1);
        otherwise
            error(['Parameter ' param ' not recognized.'])
    end
end
end
