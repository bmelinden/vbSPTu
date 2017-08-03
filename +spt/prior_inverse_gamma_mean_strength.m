function [n,c]=prior_inverse_gamma_mean_strength(N,average,strength)
% [n,c]=prior_inverse_gamma_mean_strength(N,average,strength)
% Compute the coefficients of an inverse gamma prior for the diffusion step
% variance (lambda), specified using the mean value and total strength
% (number of pseudo-counts) per state. Each emission variable gets same
% strength independent of model size.
%
% N         : number of states to construct
% average   : prior average value
% strength  : number of pseudocounts (>1)
%
% ML 2016-09-05

if(strength<=1)
   error('Inverse gamma average only defined when strength > 1.')
end
n=strength*ones(1,N);
c=average*(n-1); 

end

