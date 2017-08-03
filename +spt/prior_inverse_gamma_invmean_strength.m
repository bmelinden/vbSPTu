function [n,c]=prior_inverse_gamma_invmean_strength(N,imean,strength)
% [n,c]=prior_inverse_gamma_invmean_strength(N,mode,strength)
% Compute the coefficients of an inverse gamma prior for the diffusion step
% variance (lambda), specified using double-inverse mean value and total
% strength (number of pseudo-counts) per state. This means that Each
% emission variable gets same strength independent of model size.
% This construction menas that c = n * 1/<1/x> .
%
% N         : number of states to construct
% imean     : (prior inverse mean value)^(1), i.e., 1/<1/x>.
% strength  : number of pseudocounts (>0)
%
% ML 2016-09-05

if(strength<=0)
   error('Inverse gamma only defined when strength > 0.')
end
n=strength*ones(1,N);
c=imean*n; 
end

