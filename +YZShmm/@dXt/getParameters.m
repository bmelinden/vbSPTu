function P=getParameters(this,varargin)
% P=YZShmm.YZS0.getParameters(this,...)
% Compute some useful estimates, as subfields of the struct P
% p0    : initial state probability
% A     : tranition matrix
% D     : diffusion constant (=lambda/2/dt)
% pOcc  : average state occupancy, pOcc(k) = <s(t)==k>
% pT    : state occupancy at endpoint of trajectories, pT(k) = <s(T)==k>
% RMS   : RMS(d,s) is the average RMS localization error in for state s, in
%         dimension d. Only if data is given.
%
% 'data' ,dat   : data struct, from spt.preprocess
% 'iType',iType : type of parameter estimate to use {'mle','map','vb'}.

for k=1:2:numel(varargin)
    eval([varargin{k} '= varargin{' int2str(k+1) '};'])
end

P=getParameters@YZShmm.YZS0(this,varargin{:});

if( exist('data','var'))
    % estimate state-wise uncertainty
    P.RMS=zeros(this.sample.dim,this.numStates);
    for s=1:this.numStates
        for d=1:this.sample.dim
            ind= isfinite(data.v(:,d));
            ind(this.YZ.i1)=false;
            vs=sum(this.S.pst(ind,s).*data.v(ind,d))/sum(this.S.pst(ind,s));
            P.RMS(d,s)=sqrt(vs);
        end
    end
end
end
