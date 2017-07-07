function W=parameterUpdate(W,~)
% A parameter update iteration (MLE) on a diffusive YZdXt HMM, including
% handling missing data 

%% start of actual code

tau=W.shutterMean;
R=W.blurCoeff;
beta=tau*(1-tau)-R;

%% parameter update
W.P.A=rowNormalize(W.S.wA);
W.P.p0=rowNormalize(sum(W.S.pst(W.YZ.i0,:),1));

% check for unoccupied rows
wAemptyRows=find((sum(W.S.wA,2)==0))';
if(~isempty(wAemptyRows)) % a very non-invasive regularization, no new transitions
   W.P.A=rowNormalize(W.S.wA+10*eps*eye(W.numStates));
   W.P.p0=rowNormalize(sum(W.S.pst(W.YZ.i0,:),1)+10*eps);
   %warning(['State(s) ' int2str(wAemptyRows) ' unoccupied, MLEparameterUpdate adding 10*eps pseudocounts to avoid NaNs'])
end

% index to all hidden states, including missing data 
indS=1:W.YZ.i1(end);
indS(W.YZ.i1)=0;
indS=indS(indS>0); 

sumDim_dY2_dYZ2=sum(...
    (W.YZ.muY(indS+1,:)-W.YZ.muY(indS,:)).^2 ...
    +1/beta*(W.YZ.muZ(indS,:)-(1-tau)*W.YZ.muY(indS,:)-tau*W.YZ.muY(indS+1,:)).^2 ...
    +(1+(1-tau)^2/beta)*W.YZ.varY(indS,:) ...
    +(1+tau^2/beta)*W.YZ.varY(indS+1,:) ...
    +1/beta*W.YZ.varZ(indS,:)...
    +2*R/beta*W.YZ.covYtYtp1(indS,:)...
    -2*(1-tau)/beta*W.YZ.covYtZt(indS,:)...
    -2*tau/beta*W.YZ.covYtp1Zt(indS,:)...
    ,2);
c=zeros(1,W.numStates);
for k=1:W.numStates
    c(k)=0.5*sum(W.S.pst(indS,k).*sumDim_dY2_dYZ2);
end
n=W.dim*sum(W.S.pst(indS,:),1); 

% new for YZhmm: analytical maximum for diffusion step variance!
W.P.lambda=c./n;

% deal with unoccupied states
iNull=find(n==0);
if(~isempty(iNull))
    W.P.lambda(iNull)=1e100; % ridiculously large value to put these constants last in ordered models
    warning(['YZhmm generated unoccupied states : ' int2str(iNull) ])
end


