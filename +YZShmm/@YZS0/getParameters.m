function P=getParameters(this,~,iType)
% P=YZShmm.YZS0.getParameters(this,~,iType)
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

P=struct;
P.lnL=this.lnL;
switch lower(iType)
    case 'mle'
        % assumes model is converged with MLE
        P.p0=rowNormalize(this.P.wPi);
        P.A=rowNormalize(diag(this.P.wa(:,2))+this.P.wB);
        lambda=this.P.c./this.P.n;
        dwellSteps = reshape(sum(this.P.wa,2)./this.P.wa(:,1),1,this.numStates);
    case 'map'
        % assumes model is MAP-converged
        P.p0=rowNormalize(this.P.wPi-1);
        a=rowNormalize(this.P.wa-1);
        B1=ones(this.numStates,this.numStates)-eye(this.numStates);
        B=rowNormalize(this.P.wB-B1);
        P.A=diag(a(:,2))+diag(a(:,1))*B;
        lambda=this.P.c./(this.P.n+1);
        dwellSteps =reshape(1./a(:,1),1,this.numStates);
    case 'vb'
        % assumes model is VB-converged
        P.p0=rowNormalize(this.P.wPi);
        a=rowNormalize(this.P.wa);
        B=rowNormalize(this.P.wB);
        P.A=diag(a(:,2))+diag(a(:,1))*B;
        lambda=this.P.c./(this.P.n-1);
        dwellSteps =reshape(1./a(:,1),1,this.numStates);
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
P.D=lambda/2/this.sample.timestep;
P.pOcc=rowNormalize(sum(this.S.pst,1));
P.pT  =rowNormalize(sum(this.S.pst(this.YZ.i1-1,:),1));
P.dwellTime=dwellSteps*this.sample.timestep;
% put dwellSteps last
P.dwellSteps=dwellSteps;
end
