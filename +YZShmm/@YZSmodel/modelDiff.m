function [dlnLrel,dPmax,maxParName]=modelDiff(this,that)
% modelDiff(this,that)
% compare a model with another model, and compute convergence
% characteristics

dlnLrel = (this.lnL-that.lnL)./(this.lnL+that.lnL)*2;

dwPi= max(abs( rowNormalize(this.P.wPi)-rowNormalize(that.P.wPi)));
dwa = max(max(abs( rowNormalize(this.P.wa)-rowNormalize(that.P.wa))));
dwB = max(max(abs( rowNormalize(this.P.wB)-rowNormalize(that.P.wB))));
dn = max(abs((this.P.n-that.P.n)./(this.P.n+that.P.n)*2));
dc = max(abs((this.P.c-that.P.c)./(this.P.c+that.P.c)*2));

dParam=[dwPi dwa dwB dn dc];
[dPmax,ii]=max(dParam);
dPname={'wPi','wa','wB','n','c'};
maxParName=dPname{ii};
