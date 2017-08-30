function [lnp0,lnQ,iLambda,lnLambda]=VBmeanLogRateDiff(wPi,wa,wB,n,c)
% [lnp0,lnQ,iLambda,lnLambda]=VBlogSparameters(wPi,wa,wB,n,c)
% varational parameter log-averages needed for VB updates of hidden states
%
% iLambda : <1/lambda=n./c
% lnLambda: <ln(lambda)>=log(c)-psi(n)
% lnp0  : <ln(pi)>=psi(wPi)-psi(sum(wPi))
% lnQ   : lnQ(i,i) = <ln(1-a(i))> 
%         lnQ(i,j) = <ln(a(i))>  + <lnB(i,j)>, i~=j
%         <ln(1-a)> = psi(wa(:,2)) - psi(sum(wa,2)); (VB)
%         <ln(a)>   = psi(wa(:,1)) - psi(sum(wa,2)); (VB)
%         <ln(B)>   = psi(wB) - psi(sum(wB,2));      (VB)



% initial state probability
lnp0=psi(wPi)-psi(sum(wPi)); % <ln(pi)>

% state change probabilities, <ln(a)>, <ln(1-a)>
wa0=sum(wa,2);
lna  =psi(wa(:,1))-psi(wa0);
ln1ma=psi(wa(:,2))-psi(wa0);

% conditional jump probabilities, <lnB>, with zeros on the diagonal
I=eye(W.numStates); % N*N identity matrix
wB0=sum(wB,2)*ones(1,W.numStates);
lnBd0  = psi(wB+I)-psi(wB0);
lnBd0=lnBd0-diag(diag(lnBd0));

lnQ=diag(ln1ma)+(lna*ones(1,W.numStates)-diag(lna))+lnBd0; % <ln A> or ln A

% step length variance
iLambda =n./c; % <1/lambda>
lnLambda=log(c)-psi(n); % < ln(lambda)>
