function ind=sortModel(this,ind)
% ind=sortModel(ind)
% sort YZShmm.YSmodel according to ind (default: sort(lambda*))
if(~exist('ind','var') || numel(ind)~=this.numStates)
   [~,ind]=sort(this.P.c./(this.P.n+1));  % sort on MAP values
end
if(prod(ind==sort(ind))==0) % then ind makes a difference
    this.P0.wPi=this.P0.wPi(ind);
    this.P0.wa=this.P0.wa(ind,:);
    this.P0.wB=this.P0.wB(ind,ind);
    this.P0.n=this.P0.n(ind);
    this.P0.c=this.P0.c(ind);
    
    this.P.wPi=this.P.wPi(ind);
    this.P.wa=this.P.wa(ind,:);
    this.P.wB=this.P.wB(ind,ind);
    this.P.n=this.P.n(ind);
    this.P.c=this.P.c(ind);
    %this.P.aggregate=this.P.aggregate(ind);
    if(isfield(this.P,'KL_a') && numel(this.P.KL_a)==this.numStates)
        this.P.KL_a=this.P.KL_a(ind);
    end
    if(isfield(this.P,'KL_B') && numel(this.P.KL_B)==this.numStates)    
        this.P.KL_B=this.P.KL_B(ind);
    end
    if(isfield(this.P,'KL_lambda') && numel(this.P.KL_lambda)==this.numStates)  
        this.P.KL_lambda=this.P.KL_lambda(ind);
    end
    this.S.wA=this.S.wA(ind,ind);
    this.S.pst=this.S.pst(:,ind);
end

