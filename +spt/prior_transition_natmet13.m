function [wa,wB]=prior_transition_natmet13(N,dwellStepMean,dwellStrength)
% [wa,wB]=prior_transition_natmet13(N,dwellStepMean,rowStrength)
% transition prior used in the nat. meth. (2013) vbSPT paper. 
% 
% This is a prior on the transition matrix directly, which means that
% wa(j,1)=sum(wB(j,:)) is enforced. The prior is specified in terms of a
% mean dwell time and an overall row strength (same for all states).
%
% N         : number of states
% dwellStepMean : prior mean dwell time [timesteps]
% dwellStrength : prior strength (number of pseudocounts) per state
% ML 2016-09-09

% transition matrix
A0=1;
if(N>1)
    A0=(1-1/dwellStepMean)*eye(N)+1/dwellStepMean/(N-1)*(ones(N,N)-eye(N));
end
wA =dwellStrength*A0;           % each row gets prior strength An

wB=wA-diag(diag(wA));
wa=[sum(wB,2) diag(wA)];
