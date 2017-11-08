function P=getParameters(this,dat,iType)
% P=YZShmm.YZS0.getParameters(this,dat,iType)
% Compute some useful estimates, as subfields of the struct P
% p0    : initial state probability
% A     : tranition matrix
% D     : diffusion constant (=lambda/2/dt)
% pOcc  : average state occupancy, pOcc(k) = <s(t)==k>
% pT    : state occupancy at endpoint of trajectories, pT(k) = <s(T)==k>
% RMS   : RMS(d,s) is the average RMS localization error in for state s, in
%         dimension d. Only if data is given.
%
% input 
% dat   : data struct, from spt.preprocess
% iType : type of parameter estimate to use {'mle','map','vb'}.


P=getParameters@YZShmm.YZS0(this,dat,iType);

if( exist('dat','var'))
    % estimate state-wise uncertainty
    P.RMSerr=zeros(this.sample.dim,this.numStates);
    for s=1:this.numStates
        for d=1:this.sample.dim
            ind= isfinite(dat.v(:,d));
            ind(this.YZ.i1)=false;
            vs=sum(this.S.pst(ind,s).*dat.v(ind,d))/sum(this.S.pst(ind,s));
            P.RMSerr(d,s)=sqrt(vs);
        end
    end
end
end
