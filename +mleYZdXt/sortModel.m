function W=sortModel(W,ind)
% sort VB model according to ind (default: sort(<lambda>)
if(~exist('ind','var') || numel(ind)~=W.numStates)
   [~,ind]=sort(W.P.lambda); 
end
if(prod(ind==sort(ind))==0) % then ind makes a difference
    
    W.P.lambda=W.P.lambda(ind);
    W.P.A=W.P.A(ind,ind);
    W.P.p0=W.P.p0(ind);
    
    W.S.wA=W.S.wA(ind,ind);
    W.S.pst=W.S.pst(:,ind);
end

