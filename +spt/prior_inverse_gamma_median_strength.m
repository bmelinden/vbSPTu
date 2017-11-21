function [n,c]=prior_inverse_gamma_median_strength(N,xMedian,strength)
% [n,c]=prior_inverse_gamma_median_strength(N,median,strength)
% Compute the coefficients of an inverse gamma prior for the diffusion step
% variance (lambda), specified using the median value and total strength
% (number of pseudo-counts) per state. Each emission variable gets same
% strength independent of model size.
%
% To generate random numbers from the resulting distribution, one can use
% rr=1./gamrnd(n,1./c);
%
% N         : number of states to construct
% median    : prior median value (scalar)
% strength  : number of pseudocounts (>0, scalar)
%b=logspace(
% ML 2017-10-12

if(strength<=0)
   error('Inverse gamma model only defined when strength > 0.')
end
n=strength;

% normalized median of gamma distribution
um=gammaincinv(0.5,n,'upper');
c=xMedian*um*ones(1,N);
n=n*ones(1,N);

if(false) % verify numerically
    rr=1./gamrnd(n,1/c*ones(1,1e6)); % 
    % Matlab gamma distribution: the parameter 
    % gamrnd(a,b) ~ wikipedia's gamma distribution with shape parameter=n,
    % scale parameter = b, rate parameter = 1/b
    numMedian=median(1./rr);
    
    figure(1)
    clf
    hold on
    [a,b]=hist(rr,10000);
    plot(b,a/sum(a)/mean(diff(b)),'r','linew',2)
    
    b=linspace(b(1),b(end),1e4);
    plot(b,exp(n*log(c)-gammaln(n)-(n+1)*log(b)-c./b),'b')
    legend('random numbers','target density')
end

