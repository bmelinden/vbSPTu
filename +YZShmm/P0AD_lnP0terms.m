function [lnP0_pi,lnP0_a,lnP0_B,lnP0_lambda]=P0AD_lnP0terms(P,P0)
% [lnP0_pi,lnP0_a,lnP0_B,lnP0_lambda]=YZShmm.P0AD_lnP0terms(P,P0);
% MAP log-prior terms for core parameters (p0, A, lambda) of the
% YZShmm.YZS0 class, sing the a,B- parameterization of the transition
% matrix A. 
% Input: parameter and prior fields P,P0, where the following subfields are
% used: wPi, wa, wB, n,c. 
%
% ML 2017-09-22
N=numel(P.wPi); % number of states
%% MAP parameters
lnp0=log(rowNormalize(P.wPi-1));
a=rowNormalize(P.wa-1);
B1=ones(N,N)-eye(N);
I1=eye(N);
B=rowNormalize(P.wB-B1);
Lambda = P.c./(P.n+1);
%% log(prior) terms
% 'omitnan' in the last term because 0*log(0)=nan in matlab, but we
% want the limit log(0^0)=log(1)=0
try
    lnP0_pi=    gammaln(sum(P0.wPi,2))-sum(gammaln(P0.wPi),2)+sum(lnp0.*(P0.wPi-1),'omitnan'); % p0-log prior
    lnP0_a =gammaln(sum(P0.wa ,2))-sum(gammaln(P0.wa) ,2)+sum(log(a).*(P0.wa-1),2,'omitnan');
    % special construct so that the diagonal B-terms do not contribute,
    lnP0_B =gammaln(sum(P0.wB, 2))-sum(gammaln(P0.wB+1-B1),2)+sum(log(B+I1).*(P0.wB-B1),2,'omitnan');
catch me
    % ignore 'omitnan' on older versions of matlab
   if(strcmp(me.identifier,'MATLAB:sum:unknownFlag'))
    lnP0_pi=    gammaln(sum(P0.wPi,2))-sum(gammaln(P0.wPi),2)+sum(lnp0.*(P0.wPi-1)); % p0-log prior
    lnP0_a =gammaln(sum(P0.wa ,2))-sum(gammaln(P0.wa) ,2)+sum(log(a).*(P0.wa-1),2);
    % special construct so that the diagonal B-terms do not contribute,
    lnP0_B =gammaln(sum(P0.wB, 2))-sum(gammaln(P0.wB+1-B1),2)+sum(log(B+I1).*(P0.wB-B1),2);
   else
       retrow(me)
   end    
end
lnP0_lambda=P0.n.*log(P0.c)-gammaln(P0.n)-(P0.n-1).*log(Lambda)-P0.c./Lambda;
%% control for finite log-prior terms
if( ~isfinite(sum(lnP0_pi)) || ~isfinite(sum(lnP0_a)) || ~isfinite(sum(lnP0_B)) || ~isfinite(sum(lnP0_lambda)) )
   error('non-finte log-prior terms in P0AD_lnP0terms') 
end

    
