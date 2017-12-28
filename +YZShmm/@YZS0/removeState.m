function W=removeState(this,s,opt)
% produce a new (cloned) model object with reduced dimensionality by
% removing state s from a model.

N=this.numStates;
if(s<0 || s>N )
    error(['state ' int2str(s) ' cannot be removed from ' int2str(N) '-state model.'])
end
if(N==1)
    error('cannot remove the last state.')
else
    % We have >=1 state remaining
    sk=[1:s-1 s+1:N]; % states to keep

    W=this.createModel(N-1,opt);
    W.comment=this.comment;
    
    W.YZ=this.YZ;
    W.P.n=this.P.n(sk);
    W.P.c=this.P.c(sk);
    if(N==2) % then a single state remains
        W.S.pst=ones(size(this.S.pst,1),1);
        W.S.pst(W.YZ.i1,1)=0;
        W.S.wA=sum(W.S.pst);
        W.P.wPi=numel(W.YZ.i0);
    elseif(N>2)
        % then we have >1 state in the remaining model, and need to take
        % care of transition model as well

        W.S.pst=this.S.pst(:,sk);
        W.S.wA=this.S.wA(sk,sk);
        
        W.P.wPi=this.P.wPi(sk);
        W.P.wa =this.P.wa(sk,:);
        % transfer observed transitions
        W.P.wB=this.P.wB(sk,sk);
        % add some extra weight, to reroute removed transition weights, and
        % ensure that transition counts are not set to exactly zero
        W.P.wB=W.P.wB+eps*(1-eye(size(W.P.wB)));        
        toS=this.P.wB(sk,s);
        frS=this.P.wB(s,sk);
        tofrS=((toS/sum(toS))*(frS/sum(frS)))*(sum(frS)+sum(toS)).*(1-eye(N-1));
        if(isempty(find(~isfinite(tofrS(:)),1)))
            W.P.wB=W.P.wB+tofrS;
        end
    end
end

