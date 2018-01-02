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
dlnLrel = (this.lnL-that.lnL)./abs(this.lnL+that.lnL)*2;

if(nargout>1)
    if(this.numStates==that.numStates)
        dwPi= max(abs( rowNormalize(this.P.wPi)-rowNormalize(that.P.wPi)));
        dwa = max(max(abs( rowNormalize(this.P.wa)-rowNormalize(that.P.wa))));
        dwB = max(max(abs( rowNormalize(this.P.wB)-rowNormalize(that.P.wB))));
        dn = max(abs((this.P.n-that.P.n)./(this.P.n+that.P.n)*2));
        dc = max(abs((this.P.c-that.P.c)./(this.P.c+that.P.c)*2));
        
        dParam=[dwPi dwa dwB dn dc];
        dPname={'wPi','wa','wB','n','c'};
        
        dPname=dPname(isfinite(dParam));
        dParam=dParam(isfinite(dParam));
        
        [dPmax,ii]=max(dParam);
        dPmaxName=dPname{ii};
        
        dsMax=max(abs(this.S.pst(:)-that.S.pst(:)));
    else
        warning('modelDiff cannot compare parameters with different domensionality.')
        dPmax=NaN;
        dPmaxName=NaN;
    end
end
