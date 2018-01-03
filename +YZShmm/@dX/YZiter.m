function YZiter(this,dat,iType)
% YZiter(dat,iType)
% one update of the q(Y,Z) distribution, 
% dat : preprocessed data
% iType : type of learning, one of {'mle','vb'}.

switch lower(iType)
    case 'mle'
        Lambda = this.P.c./this.P.n;
        iLambda =1./Lambda;
        v=this.P.cv./this.P.nv;
        iV=1./v;
    case 'vb'
        [~,~,iLambda,~]=YZShmm.VBmeanLogParam(this.P.wPi,this.P.wa,this.P.wB,this.P.n,this.P.c);
        % localization variances length variance
        iV  =this.P.nv./this.P.cv;         % <1/v>
        %lnVs=log(this.P.cv)-psi(this.P.nv).*ones(1,this.numStates); % < ln(v)>
    otherwise
        error(['iType= ' iType ' not known. Use {mle,vb}.'] )
end
tau=this.sample.shutterMean;
Rcoeff  =this.sample.blurCoeff;
this.YZ=YZShmm.diffusionPathUpdate(dat,this.S,tau,Rcoeff,iLambda,iV);

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
