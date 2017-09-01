function P=getParameters(this,iType)
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
end
