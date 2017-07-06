function [iLambda,lnLambda,lnp0,lnQ]=effectiveParameters(W)
% [iLambda,lnLambda,lnp0,lnQ]=vbAverageParameters(W)
% varational parameter averages needed for VB updates
%
% iLambda : <1/lambda=W.P.n./W.P.c
% lnLambda: <ln(lambda)>=log(W.P.c)-psi(W.P.n)
% lnp0  : <ln(pi)>=psi(W.P.wPi)-psi(sum(W.P.wPi))
% lnQ   : lnQ(i,i) = <ln(1-a(i))> 
%         lnQ(i,j) = <ln(a(i))>  + <lnB(i,j)>, i~=j


% step length variance
iLambda =W.P.n./W.P.c; % <1/lambda>
lnLambda=log(W.P.c)-psi(W.P.n); % < ln(lambda)>

lnp0=psi(W.P.wPi)-psi(sum(W.P.wPi)); % <ln(pi)>

% state change probabilities, <ln(a)>, <ln(1-a)>
wa0=sum(W.P.wa,2);
lna  =psi(W.P.wa(:,1))-psi(wa0);
ln1ma=psi(W.P.wa(:,2))-psi(wa0);

% conditional jump probabilities, <lnB>, with zeros on the diagonal
I=eye(W.numStates); % N*N identity matrix
wB0=sum(W.P.wB,2)*ones(1,W.numStates);
lnBd0  = psi(W.P.wB+I)-psi(wB0);
lnBd0=lnBd0-diag(diag(lnBd0));

lnQ=diag(ln1ma)+(lna*ones(1,W.numStates)-diag(lna))+lnBd0; % <ln A> or ln A
