function ind=sortModel(this,ind)
% ind=sortModel(ind)
% sort YZShmm.YSmodel according to ind (default: sort(lambda*))
if(this.numStates==1)
    return
end
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
    if(isfield(this.P,'KL'))
        if(isfield(this.P.KL,'a') && numel(this.P.KL.a)==this.numStates)
            this.P.KL.a=this.P.KL.a(ind);
        end
        if(isfield(this.P.KL,'B') && numel(this.P.KL.B)==this.numStates)
            this.P.KL.B=this.P.KL.B(ind);
        end
        if(isfield(this.P.KL,'lambda') && numel(this.P.KL.lambda)==this.numStates)
            this.P.KL.lambda=this.P.KL.lambda(ind);
        end
    end
    if(isfield(this.P,'lnP0'))
        if(isfield(this.P.lnP0,'a') && numel(this.P.lnP0.a)==this.numStates)
            this.P.lnP0.a=this.P.lnP0.a(ind);
        end
        if(isfield(this.P.lnP0,'B') && numel(this.P.lnP0.B)==this.numStates)
            this.P.lnP0.B=this.P.lnP0.B(ind);
        end
        if(isfield(this.P.lnP0,'lambda') && numel(this.P.lnP0.lambda)==this.numStates)
            this.P.lnP0.lambda=this.P.lnP0.lambda(ind);
        end        
    end
    this.S.wA=this.S.wA(ind,ind);
    this.S.pst=this.S.pst(:,ind);
end

