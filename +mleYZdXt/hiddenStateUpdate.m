function [W,sMaxP,sVit,WS]=hiddenStateUpdate(W,dat)
% [W,sMaxP,sVit,WS]=hiddenStateUpdate(W,dat)
% one round of hidden state EM iteration (maximum likelihood) in a
% diffusive HMM, with possibly missing position data 
%
% sMAxP and sVit are only computed if asked for by output arguments.
% WS : struct containing the whole workspace at the end of the function
% call. Expensive, computed only when asked for.

% v1: modified from EMhmm version, checked correctness (not perfect, but
% good enough to blame on model differences...).
% v2: optimized computing lnH by getting rid of the trj loop


%% start of actual code
tau=W.shutterMean;
R=W.blurCoeff;
beta=tau*(1-tau)-R;
%% assemble point-wise weights
T=W.YZ.i1(end);
lnH=-W.dim*ones(T,1)*log(W.P.lambda);
lnH(W.YZ.i0,:)=lnH(W.YZ.i0,:)+ones(length(W.YZ.i0),1)*log(W.P.p0);
lnH=lnH-sum(...
        [diff(W.YZ.muY).^2 ;zeros(1,W.dim)] ...
        +1/beta*(W.YZ.muZ-(1-tau)*W.YZ.muY-tau*W.YZ.muY([2:end end],:)).^2 ...
        +(1+(1-tau)^2/beta)*W.YZ.varY ...
        +(1+    tau^2/beta)*W.YZ.varY([2:end end],:) ...
        +1/beta*W.YZ.varZ...
        +2*R/beta*W.YZ.covYtYtp1...
        -2*(1-tau)/beta*W.YZ.covYtZt...
        -2*tau/beta*W.YZ.covYtp1Zt...
        ,2)/2*(1./W.P.lambda);
lnH(W.YZ.i1,:)=0;
lnHmax=max(lnH,[],2);
lnH=lnH-lnHmax*ones(1,W.numStates);
H=exp(lnH);
H(W.YZ.i1,:)=0;
%% forward-backward iteration
%[ln3,wA3,ps3]=HMM_multiForwardBackward_g1(W.P.A,H,dat.i1);
[lnZ,W.S.wA,W.S.pst]=HMM_multiForwardBackward_startend(W.P.A,H,dat.i0,dat.i1);
W.S.lnZ=lnZ+sum(lnHmax);

%% likelihood lower bound after s
W.lnL=W.S.lnZ+W.YZ.Fs_yz;
%% path estimates
if(nargout>=2) % compute sequence of most likely states
    [~,sMaxP]=max(W.S.pst,[],2);
    sMaxP(W.YZ.i1)=0;
end
if(nargout>=3) % compute Viterbi path, with a small offset to avoid infinities
    sVit=HMM_multiViterbi_log_startend(log(W.P.A+1e-50),log(H+1e-50),W.YZ.i0,W.YZ.i1-1);
end
if(nargout>=4)
   fname=['foo_' int2str(ceil(1e5*rand)) '.mat'];
   save(fname);
   WS=load(fname);
   delete(fname);
end
