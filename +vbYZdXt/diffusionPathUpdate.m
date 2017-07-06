function W=diffusionPathUpdate(W,dat)
% [W,WS]=diffusionPathUpdate(W,dat)
% one round of VB diffusion path update in a diffusive HMM with point_wise
% localization uncertainties. Actual computing is done in
% spt.diffusionPathUpdate 

W.YZ=spt.diffusionPathUpdate(dat,W.S,W.shutterMean,W.blurCoeff,W.P.n./W.P.c);
