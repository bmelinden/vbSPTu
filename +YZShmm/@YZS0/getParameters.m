function P=getParameters(this,varargin)
% P=YZShmm.YZS0.getParameters(this,dat,iType)
% Return a struct with some useful estimates:
% p0    : initial state probability
% A     : tranition matrix
% D     : diffusion constant (=lambda/2/dt)
% pOcc  : average state occupancy, pOcc(k) = <s(t)==k>
% pT    : state occupancy at endpoint of trajectories, pT(k) = <s(T)==k>
%
% input parameter-value pairs
% 'data' ,dat   : data struct, from spt.preprocess (actually not used here)
% 'iType',iType : type of parameter estimate to use {'mle','map','vb'}. 

for k=1:2:numel(varargin)
   eval([varargin{k} '= varargin{' int2str(k+1) '};'])
end

switch lower(iType)
    case 'mle'
        % assumes model is converged with MLE
        P.p0=rowNormalize(this.P.wPi);
        P.A=rowNormalize(diag(this.P.wa(:,2))+this.P.wB);
        lambda=this.P.c./this.P.n;
    case 'map'
        % assumes model is MAP-converged
        P.p0=rowNormalize(this.P.wPi-1);
        a=rowNormalize(this.P.wa-1);
        B1=ones(this.numStates,this.numStates)-eye(this.numStates);
        B=rowNormalize(this.P.wB-B1);
        P.A=diag(a(:,2))+diag(a(:,1))*B;
        lambda=this.P.c./(this.P.n+1);
    case 'vb'
        % assumes model is VB-converged
        P.p0=rowNormalize(this.P.wPi);
        a=rowNormalize(this.P.wa);
        B=rowNormalize(this.P.wB);
        P.A=diag(a(:,2))+diag(a(:,1))*B;
        lambda=this.P.c./(this.P.n-1);
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
P.D=lambda/2/this.sample.timestep;
P.pOcc=rowNormalize(sum(this.S.pst,1));
P.pT  =rowNormalize(sum(this.S.pst(this.YZ.i1-1,:),1));
end
