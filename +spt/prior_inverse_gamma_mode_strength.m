function [n,c]=prior_inverse_gamma_mode_strength(N,mode,strength)
% [n,c]=prior_inverse_gamma_mode_strength(N,mode,strength)
% Compute the coefficients of an inverse gamma prior for the diffusion step
% variance (lambda), specified using the mode value and total strength
% (number of pseudo-counts) per state. Each emission variable gets same
% strength independent of model size.
%
% N         : number of states to construct
% mode      : prior mode value
% strength  : number of pseudocounts (>0)
%
% ML 2016-09-05

if(strength<=0)
   error('Inverse gamma mode only defined when strength > 0.')
end
n=strength*ones(1,N);
c=mode*(n+1); 
end

