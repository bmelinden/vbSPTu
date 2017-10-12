function [n,c]=prior_inverse_gamma_median_strength(N,median,strength)
% [n,c]=prior_inverse_gamma_median_strength(N,median,strength)
% Compute the coefficients of an inverse gamma prior for the diffusion step
% variance (lambda), specified using the median value and total strength
% (number of pseudo-counts) per state. Each emission variable gets same
% strength independent of model size.
%
% N         : number of states to construct
% median    : prior median value
% strength  : number of pseudocounts (>0)
%
% ML 2017-10-12

if(strength<=0)
   error('Inverse gamma model only defined when strength > 0.')
end
n=strength*ones(1,N);
c=median*(n+1); 

mmFun=@(cc)(gaminv(0.5,n,cc));
disp('Computing inverse gamma parameters for given median value:')
c=fsolve(@(x)(mmFun(x)-median),c);
disp('---')

end

