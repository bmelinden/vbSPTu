function [n,c]=prior_inverse_gamma_median_strength(N,median,strength)
% [n,c]=prior_inverse_gamma_median_strength(N,median,strength)
% Compute the coefficients of an inverse gamma prior for the diffusion step
% variance (lambda), specified using the median value and total strength
% (number of pseudo-counts) per state. Each emission variable gets same
% strength independent of model size.
%
% N         : number of states to construct
% median    : prior median value (scalar)
% strength  : number of pseudocounts (>0, scalar)
%
% ML 2017-10-12

if(strength<=0)
   error('Inverse gamma model only defined when strength > 0.')
end
n=strength;
c=median*(n+1); 

mmFun=@(cc)(gaminv(0.5,n,cc));
fOpt=optimset(optimset('fsolve'),'Display','none');
%%%disp('Computing inverse gamma parameters for given median value:')
[c,~,exitFlag]=fsolve(@(x)(mmFun(x)-median),c,fOpt);
if(exitFlag<=0)
   error('Something went wrong in computing the prior median value. Check prior parameters.')
end
n=n*ones(1,N);
c=c*ones(1,N);
%%%disp('---')

end

