function [W,WS]=diffusionPathUpdate(W,dat)
% [W,WS]=diffusionPathUpdate(W,dat)
% one round of diffusion path update in a diffusive HMM, with possibly
% missing position data. This code extends the EMhmm diffusion path update
% to the variational formulation using q(Y,Z) for later incorporation into
% the vbUSPT package. The diffusion path update is independent of
% detachment rates, so this function simply calls
% mleYZdXt.diffusionPathUpdate 
%
% WS: optional output, workspace at end of the function
%

switch nargout
    case 0
        return
    case 1
        W=mleYZdXt.diffusionPathUpdate(W,dat);
    case 2
        [W,WS]=mleYZdXt.diffusionPathUpdate(W,dat);
    otherwise
        error('wrong number of output arguments.')
end
