function P=getParameters(this,dat,iType)
% P=YZShmm.YZS0.getParameters(this,dat,iType)
% Return a struct with some useful estimates:
% lnL   : log likelihood
% p0    : initial state probability
% A     : tranition matrix
% D     : diffusion constant (=lambda/2/dt)
% pOcc  : average state occupancy, pOcc(k) = <s(t)==k>
% pT    : state occupancy at endpoint of trajectories, pT(k) = <s(T)==k>
%
% input parameters
% dat   : data struct, from spt.preprocess (actually not used here)
% iType : type of parameter estimate to use {'mle','map','vb'}. 
%
% NOTE: No iterations are performed, so unless the model has been converged
% with the correct iType, the estimates may not be correct.

P=getParameters@YZShmm.YZS0(this,dat,iType);
switch lower(iType)
    case 'mle'
        v=this.P.cv/this.P.nv;
    case 'map'
        v=this.P.cv/(this.P.nv+1);        
    case 'vb'
        v=this.P.cv/(this.P.nv-1);        
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb}.'] )
end
P.RMSerr=sqrt(v)*ones(1,this.numStates);
P.v=v;
