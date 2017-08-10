function P=randomParameters(N,dt,Drange,wA,w0)
% P=randomParameters(N,dt,Drange,wA,w0)
% random initialization of HMM parameters P.lambda, P.A, P.p0
%
% N     : 1) number of hidden states, in which case the struct P is created
%            from scratch
%         2) an existing parameter struct, in which case the number of
%            states is length(P.lambda), and the fields lambda, A, p0 are
%            overwritten, and other fields left intact.
% dt    : time step. Default 1.
% Drange: range of diffusion constant values. The diffusion constants are
%         selected randomly in this range, with log(D) uniformly
%         distributed. P.lambda=2*dt*D. Default [1e4 1e7].
% wA    : pseudocounts for transition matrix
%         A(k,:) ~ Dirichlet(wA(k,:)). Default wA=ones(N,N)+3*eye(N).
% w0    : pseudocounts for initial state probabilities
%         p0 ~ Dirichlet(w0). Default w0=ones(1,N).

if(isstruct(N))
    P=N;
    N=length(P.lambda);
else
    P=struct;
end

% default values
if(~exist('Drange') || isempty(Drange))
    Drange=[1e4 1e7];
end
if(~exist('wA') || isempty(wA))
    wA=ones(N,N)+3*eye(N);
end
if(~exist('w0') || isempty(w0))
    w0=ones(1,N);
end

% step variance
logDrange=sort(log(Drange));
P.lambda=2*dt*exp(logDrange(1)+sort(rand(1,N))*diff(logDrange));
P.A=dirrnd(wA);
P.p0=dirrnd(w0);
