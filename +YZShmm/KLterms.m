function [KL_pi,KL_a,KL_B,KL_lambda,KL_d]=KLterms(P,P0)
%% KUllback-Laibler terms
% KL divergence of transition probabilities of s(t), new
% parameterization
N=numel(P.wPi);

%% KL_pi
u0Pi=sum(P0.wPi);
w0Pi=sum(P.wPi );
KL_pi=gammaln(w0Pi)-gammaln(u0Pi)...
    +sum((gammaln(P0.wPi)-gammaln(P.wPi))...
    +(P.wPi-P0.wPi).*(psi(P.wPi)-psi(w0Pi)));
if(~isfinite(sum(KL_pi)))
    error('vbYZdXt: KL_pi not finite')
end
clear u0Pi w0Pi ind;
%% KL_a
KL_a=zeros(N,1);
if(N>1) % a is only defined if N>1
    wa0=sum( P.wa,2);
    ua0=sum(P0.wa,2);
    KL_a=gammaln(wa0)-gammaln(ua0)...
        -(wa0-ua0).*psi(wa0)-(...
        gammaln(P.wa(:,1))-gammaln(P0.wa(:,1))...
        -(P.wa(:,1)-P0.wa(:,1)).*psi(P.wa(:,1))...
        +gammaln(P.wa(:,2))-gammaln(P0.wa(:,2))...
        -(P.wa(:,2)-P0.wa(:,2)).*psi(P.wa(:,2)));
end
if(~isfinite(sum(KL_a)))
    %%% debug
    P0.wa
    P.wa
    S.wA
    error('vbYZdXt: KL_a not finite')
end
clear wa0 ua0;
%% KL_B
KL_B=zeros(N,1);
if(N>1) % B is only defined for N>1
    for k=1:N
        ind=find((P0.wB(k,:)>0).*((1:N)~=k)); % only include non-zero and non-diagonal elements
        wB0=sum(P.wB(k,ind));
        uB0=sum(P0.wB(k,ind));
        KL_B(k)=gammaln(wB0)-gammaln(uB0)-(wB0-uB0)*psi(wB0)...
            +sum((P.wB(k,ind)-P0.wB(k,ind)).*psi(P.wB(k,ind))...
            -gammaln(P.wB(k,ind))+gammaln(P0.wB(k,ind)));
    end
end
if(~isfinite(sum(KL_B)))
    %%% debug
    P0.wB
    P.wB
    S.wA
    error('vbYZdXt: KL_B not finite')
end
clear wA0 uA0 ind;
%% KL lambda
KL_lambda= P0.n.*log(P.c./P0.c)...
    -P.n.*(1-P0.c./P.c)...
    -gammaln(P.n)+gammaln(P0.n)...
    +(P.n-P0.n).*psi(P.n);
% remove duplicate terms in each aggregate
%for a=1:max(P.aggregate)
%    ind=find(a==P.aggregate);
%    KL_lambda(ind(2:end))=0;
%end
if(~isfinite(sum(KL_lambda)))
    error('vbYZdXt: KL_lambda not finite')
end
%% KL_d
if(isfield(P0,'wd') && nargout >= 5)
    wd0=sum( P.wd,2);
    ud0=sum(P0.wd,2);
    KL_d=gammaln(wd0)-gammaln(ud0)...
        -(wd0-ud0).*psi(wd0)-(...
        gammaln(P.wd(:,1))-gammaln(P0.wd(:,1))...
        -(P.wd(:,1)-P0.wd(:,1)).*psi(P.wd(:,1))...
        +gammaln(P.wd(:,2))-gammaln(P0.wd(:,2))...
        -(P.wd(:,2)-P0.wd(:,2)).*psi(P.wd(:,2)));
    if(~isfinite(sum(KL_a)))
        %%% debug
        P0.wd
        P.wd
        error('vbYZdXt: KL_d not finite')
    end
    clear wd0 ud0;
end
