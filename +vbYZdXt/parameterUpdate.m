function W=parameterUpdate(W,~)
% A VB parameter update iteration of a diffusive YZdXt HMM.

%% start of actual code
tau=W.shutterMean;
R=W.blurCoeff;
beta=tau*(1-tau)-R;
N=W.numStates;
dim=W.dim;
%% parameter update
% initial state probabilities
wPi=sum(W.S.pst(W.YZ.i0,:),1);
% transition probabilities
wB=W.S.wA.*(1-eye(N)).*(W.P0.wB>0);
% dwell probabilities
wa=[sum(wB,2) diag(W.S.wA)];
% VB parameter update
W.P.wPi=W.P0.wPi+wPi;
W.P.wB=W.P0.wB+wB;
W.P.wa=W.P0.wa+wa;

% step length variance
dYZ2=sum(...
        [diff(W.YZ.muY).^2 ;zeros(1,dim)] ...
        +1/beta*(W.YZ.muZ-(1-tau)*W.YZ.muY-tau*W.YZ.muY([2:end end],:)).^2 ...
        +(1+(1-tau)^2/beta)*W.YZ.varY ...
        +(1+    tau^2/beta)*W.YZ.varY([2:end end],:) ...
        +1/beta*W.YZ.varZ...
        +2*R/beta*W.YZ.covYtYtp1...
        -2*(1-tau)/beta*W.YZ.covYtZt...
        -2*tau/beta*W.YZ.covYtp1Zt...
        ,2);
c=0.5*sum((dYZ2*ones(1,3)).*W.S.pst,1);
n=dim*sum(W.S.pst,1);
W.P.n=W.P0.n+n;
W.P.c=W.P0.c+c;
%% update lower bound contributions
% KL divergence of transition probabilities of s(t), new
% parameterization
KL_a=zeros(N,1);
if(N>1) % a is only defined if N>1
    wa0=sum( W.P.wa,2);
    ua0=sum(W.P0.wa,2);
    KL_a=gammaln(wa0)-gammaln(ua0)...
        -(wa0-ua0).*psi(wa0)-(...
        gammaln(W.P.wa(:,1))-gammaln(W.P0.wa(:,1))...
        -(W.P.wa(:,1)-W.P0.wa(:,1)).*psi(W.P.wa(:,1))...
        +gammaln(W.P.wa(:,2))-gammaln(W.P0.wa(:,2))...
        -(W.P.wa(:,2)-W.P0.wa(:,2)).*psi(W.P.wa(:,2)));
end
if(~isfinite(sum(KL_a)))
    error('vbYZdXt: KL_a not finite')
end
W.P.KL_a=KL_a;
clear wa0 ua0 KL_a;

% jump probabilities
KL_B=zeros(N,1);
if(N>1) % B is only defined for N>1
    for k=1:N
        ind=find((W.P0.wB(k,:)>0).*((1:N)~=k)); % only include non-zero and non-diagonal elements
        wB0=sum(W.P.wB(k,ind));
        uB0=sum(W.P0.wB(k,ind));
        KL_B(k)=gammaln(wB0)-gammaln(uB0)-(wB0-uB0)*psi(wB0)...
            +sum((W.P.wB(k,ind)-W.P0.wB(k,ind)).*psi(W.P.wB(k,ind))...
            -gammaln(W.P.wB(k,ind))+gammaln(W.P0.wB(k,ind)));
    end
end
if(~isfinite(sum(KL_B)))
    error('vbYZdXt: KL_B not finite')
end
W.P.KL_B=KL_B;
clear wA0 uA0 ind KL_B;

% KL divergence of initial state probability
u0Pi=sum(W.P0.wPi);
w0Pi=sum(W.P.wPi );
KL_pi=gammaln(w0Pi)-gammaln(u0Pi)...
    +sum((gammaln(W.P0.wPi)-gammaln(W.P.wPi))...
    +(W.P.wPi-W.P0.wPi).*(psi(W.P.wPi)-psi(w0Pi)));
if(~isfinite(sum(KL_pi)))
    error('vbYZdXt: KL_pi not finite')
end
W.P.KL_pi=KL_pi;
clear u0Pi w0Pi ind KL_pi;

% KL divergence of step variances
W.P.KL_lambda= W.P0.n.*log(W.P.c./W.P0.c)...
    -W.P.n.*(1-W.P0.c./W.P.c)...
    -gammaln(W.P.n)+gammaln(W.P0.n)...
    +(W.P.n-W.P0.n).*psi(W.P.n);
% remove duplicate terms in each aggregate
for a=1:max(W.P.aggregate)
    ind=find(a==W.P.aggregate);
    W.P.KL_lambda(ind(2:end))=0;
end
if(~isfinite(sum(W.P.KL_lambda)))
    error('vbYZdXt: KL_lambda not finite')
end



