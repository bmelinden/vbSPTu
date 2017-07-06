function W=sortModel(W,ind)
% sort VB model according to ind (default: sort(<lambda>)
if(~exist('ind','var') || numel(ind)~=W.numStates)
   [~,ind]=sort(W.P.c./(W.P.n-1)); 
end
if(prod(ind==sort(ind))==0) % then ind makes a difference
    W.P0.n=W.P0.n(ind);
    W.P0.c=W.P0.c(ind);
    W.P0.wPi=W.P0.wPi(ind);
    W.P0.wa=W.P0.wa(ind,:);
    W.P0.wB=W.P0.wB(ind,ind);
    
    W.P.n=W.P.n(ind);
    W.P.c=W.P.c(ind);
    W.P.wPi=W.P.wPi(ind);
    W.P.wa=W.P.wa(ind,:);
    W.P.wB=W.P.wB(ind,ind);
    W.P.aggregate=W.P.aggregate(ind);
    W.P.KL_a=W.P.KL_a(ind);
    W.P.KL_B=W.P.KL_B(ind);
    W.P.KL_lambda=W.P.KL_lambda(ind);
    
    W.S.wA=W.S.wA(ind,ind);
    W.S.pst=W.S.pst(:,ind);
end

