function [dlnLrel,dPmax,dPmaxName,dsMax]=modelDiff(this,that)
% [dlnLrel,dPmax,dPmaxName,dsMax]=W1.modelDiff(W2)
%
% Compute convergence characteristics by comparing two model W1 and W2:
% Relative difference in log likelihood, and a largest parameter
% difference, and which parameter it is. The parameter difference is
% measured  by relative difference, except for variables constrainted to
% [0,1], where absolute difference is used instead. Relative differences
% are computed as 2*(x2-x1)/|x1+x2|
%
% W1,W2: YZShmm.YZS0 objects
%
% dlnLrel : relative log likelihood difference, dlnL/|lnL|
% dPmax   : max parameter difference  |dP/P|, or just |dP| for variables
%           that are alredy normalized to the interval [0,1].
% dPmaxName : name of parameter reported by dPmax
% dsMax   :   max|W1.S.pst(:)-W2.S.pst(:)| 
%           = max(t,j)|W1.S.pst(t,j)-W2.S.pst(t,j)|

[dlnLrel,dPmax,dPmaxName,dsMax]=modelDiff@YZShmm.YZS0(this,that);

if(nargout>1)
    dnv=2*(this.P.nv-that.P.nv)./(this.P.nv+that.P.nv);
    dcv=2*(this.P.cv-that.P.cv)./(this.P.cv+that.P.cv);
    dParam=[dPmax dnv dcv];
    dPname={dPmaxName,'nv','cv'};
    [dPmax,ii]=max(dParam);
    dPmaxName=dPname{ii};
end
