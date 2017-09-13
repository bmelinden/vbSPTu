function YZiter(this,dat,iType)
% YZiter(dat,iType)
% one update of the q(Y,Z) distribution, 
% dat : preprocessed data
% iType : type of learning, one of {'mle','map','vb','none'}. ('none' makes
% the iterations do nothing).

switch lower(iType)
    % for now, I assume that the difference btw MAP/MLE is
    % in computing the parameter counts (i.e., adding
    % prior pseudocounts or not in the P subfields).
    case 'mle'
        Lambda = this.P.c./this.P.n;
        iLambda =1./Lambda;
    case 'map'
        Lambda = this.P.c./(this.P.n+1);
        iLambda =1./Lambda;
    case 'vb'
        [~,~,iLambda,~]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
    case 'none'
        return
    otherwise
        error(['iType= ' iType ' not known. Use {mle,map,vb,none}.'] )
end
tau=this.sample.shutterMean;
Rcoeff  =this.sample.blurCoeff;
this.YZ=YZShmm.diffusionPathUpdate(dat,this.S,tau,Rcoeff,iLambda);

% [YZ,funWS]=diffusionPathUpdate(dat,S,tau,R,iLambda,iV)
% one round of diffusion path update in a diffusive HMM, with possibly
% missing position data. This function handles either point-wise
% localization errors (variances dat.V), or uniform or state-dependent
% errors (if iV is given).
%
% dat   : preprocessed data field.
% S     : W.S, variational hidden state distribution struct
% tau   : W.shutterMean
% R     : W.blurCoeff
% iLambda : <1/lambda= W.P.n./W.P.c   (VB), or 1./W.P.lambda (MLE)
% iV    :   <1./v>   = W.P.nv./W.P.cv (VB), or 1./W.P.v      (MLE)
%
% YZ   : updated variational trajectory distribution struct

end
