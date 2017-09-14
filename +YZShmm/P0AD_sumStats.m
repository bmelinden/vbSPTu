function [wPi,wa,wB,n,c]=P0AD_sumStats(YZ,S,tau,R,wBstruct)
% [wPi,wa,wB,n,c]=YZShmm.P0AD_sumStats(YZ,S,tau,R,wBstruct)
% compute parameters for model parameter updates
% wPi = 
% wa    : counts up transitions (column 1) and non-transitions (column 2)
% wB    : transition count matrix. sum(wB(k,:)) = wa(k,1) I think
% n,c   : count parameters for lambda variable

% wd    : last state occupancy count, for deatch rate estimate

%% start of actual code
beta=tau*(1-tau)-R;
dim=size(YZ.muY,2);
N=size(S.pst,2);
%% parameter count parameters
% figure out which transitions are allowed
if(~exist('wBstruct','var') || isempty(wBstruct))
    % by default, assume all transitions are allowed
    wBstruct=ones(N,N)-eye(N);
end

% initial state probabilities
wPi=sum(S.pst(YZ.i0,:),1);
% transition probabilities
wB=S.wA.*(1-eye(N)).*(wBstruct>0);
% dwell probabilities
wa=[sum(wB,2) diag(S.wA)];

% step length variance
dYZ2=sum(...
    [diff(YZ.muY).^2 ;zeros(1,dim)] ...
    +1/beta*(YZ.muZ-(1-tau)*YZ.muY-tau*YZ.muY([2:end end],:)).^2 ...
    +(1+(1-tau)^2/beta)*YZ.varY ...
    +(1+    tau^2/beta)*YZ.varY([2:end end],:) ...
    +1/beta*YZ.varZ...
    +2*R/beta*YZ.covYtYtp1...
    -2*(1-tau)/beta*YZ.covYtZt...
    -2*tau/beta*YZ.covYtp1Zt...
    ,2);
c=0.5*sum((dYZ2*ones(1,N)).*S.pst,1);
n=dim*sum(S.pst,1);

% bleaching/detatchment/death rate
% wd = [#detatchments #non-detachments], detatchment happen at t=T
% wd=[sum(S.pst(YZ.i1-1,:),1) sum(S.pst,1)-sum(S.pst(YZ.i1-1,:),1)];

