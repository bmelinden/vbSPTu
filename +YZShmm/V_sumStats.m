function [nv,cv]=V_sumStats(YZ,S,dat)
% [nv,cv]=YZShmm.V_sumStats(YZ,S,dat)
% compute summary statistics for model parameter updates
% nv,cv : count parameters for localization variance variables. These
%         are divided accodring to coordinate dimensiuon (row index) and
%         hidden state (column index), and thus need to be integrated out
%         to use with simpler models.

%% start of actual code
dim=size(YZ.muY,2);
N=size(S.pst,2);

% average localization error
ot=isfinite(dat.x(:,1)); % index to all measured positions
ot(YZ.i1)=false; % should be redundant

nv=zeros(dim,N);
cv=zeros(dim,N);
for m=1:dim
    nv(m,:)=0.5*dim*sum(S.pst(ot,:),1);
    cv(m,:)=0.5*sum((sum((dat.x(ot,:)-YZ.muZ(ot,:)).^2+YZ.varZ(ot,:)...
        ,2)*ones(1,N)).*S.pst(ot,:),1);
end

