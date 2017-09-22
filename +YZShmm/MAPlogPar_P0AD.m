function [lnp0,lnQ,iLambda,lnLambda]=MAPlogPar_P0AD(wPi,wa,wB,c,n)
% [lnp0,lnQ,iLambda,lnLambda]=YZShmm.MAPlogPar_P0AD(wPi,wa,wB,c,n)
% compute core log(MAP parameters) p0,A,lambda, using the
% a,B-representation of the transition matrix A, for the YZShmm.YZS0 model
% class 
%
% ML 2017-09-22

N=numel(wPi);
% initial state probability
lnp0=log(rowNormalize(wPi-1));
% transition matrix
a=rowNormalize(wa-1);
B1=ones(N,N)-eye(N);
B=rowNormalize(wB-B1);
lnQ =log(diag(a(:,2))+diag(a(:,1))*B);
% step length variance
Lambda = c./(n+1);
iLambda =1./Lambda;
lnLambda=log(Lambda);

if(~isreal(lnQ))
    error('Imaginary log-transition matrix. Possibly because the last Piter was not an MAP update.')
end
