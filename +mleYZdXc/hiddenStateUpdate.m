function W=hiddenStateUpdate(W,dat)
% hiddenStateUpdate(W,dat) = YZdXt.hiddenStateUpdate(W,dat);
% the mle hidden state update for the YZdxc HMM (constant localization
% error) is the same as for the model with estimated point-wise
% localization errors. 

W=mleYZdXt.hiddenStateUpdate(W,dat);
