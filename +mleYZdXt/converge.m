function [W,sMaxP,sVit]=converge(W,dat,varargin)
% [W,sMaxP,sVit]=converge(W,dat,...)
% Run MLE EM iterations on the diffusive HMM W and data dat, until
% convergence, using a YZdXt HMM model.
%
% Output:
% W     : converged HMM model
% sMaxP : trajectory of most likely states 
% sVit  : most likely trajectory of hidden states (from Viterbi algorithm)
% sMaxP and sVit are a little expensive, and only computed if asked for by
% output arguments.
%
% Input :
% W     : EM6 HMM model struct, e.g., created by mleYZdXt.init_P_dat
% dat   : EM6 data struct, e.g., from mleYZdXt.preprocess
% optional arguments in the form 'name', value
% Nwarmup   : number of initial iterations where model parameters are kept
%             constant in order to 'burn in' the states and hidden path.
%             These iterations are always performed, and not tested for
%             convergence. Default 5. 
% maxIter   : maximum number of iterations (past Nwarmup). Default 5000.
% lnLrelTol : relative convergence criteria for (lnL(n)-lnL(n-1))/|lnL(n)|.
%             Default 1e-8;
% parTol    : convergence criteria for parameters lambda (relative), A, p0
%             (absolute). Default 1e-3;
% Dsort     : sort model in order of increasing diffusion constants.
%             Default=true.
% display   : Level of output. 0: no output. 1 (default): print convergence
%             message. 2: print convergence every iteration.
% Pupdate   : if true (default), include parameter updates in the
%             iterations, if false, keep parameters constant.
%
% 2016-06-28 : researched convergence problems, and found one that was due
% to one state becoming completely unoccopied, which in turn induces NaNs
% in the transition matrix, and from there to the whole model.
% 2017-06-27: started modifying to fit in the YZhmm package instead. Very
% small differences

%% start of actual code


% default parameter values
lnLrelTol=1e-8;
parTol=1e-3;
Nwarmup=5;
maxIter=5000;
showConv_lnL=false;
showExit=true;
sortModel=true;
Pupdate=true;

% parameter interpretations
nv=1;
while(nv <= length(varargin))
   pname=varargin{nv};
   if(~ischar(pname))
       error(['optinal arguments must be name/value pairs.'])
   end
   pval=varargin{nv+1};
   nv=nv+2;
    
   if(strcmp(pname,'Nwarmup'))
      Nwarmup=pval;
   elseif(strcmp(pname,'maxIter'))
      maxIter=pval;      
   elseif(strcmp(pname,'lnLrelTol'))
      lnLrelTol=pval;      
   elseif(strcmp(pname,'parTol'))
      parTol=pval;      
   elseif(strcmp(pname,'Dsort'))
      sortModel=pval;    
   elseif(strcmp(pname,'display'))
      n=pval;
      switch n
          case 0
              showConv_lnL=false;
              showExit=false;
          case 1
              showConv_lnL=false;
              showExit=true;
          case 2
              showConv_lnL=true;
              showExit=true;
          otherwise
              error(['Did not understand display ' int2str(n)])
      end
   elseif(strcmp(pname,'Pupdate'))
       Pupdate=pval;
   else
       error(['Unrecognized option ' pname ])
   end   
end

% construct convergence report
EMexit=struct;
EMexit.stopcondition='maxiter';
% convergence iterations
lnL0=-inf;

EMtimer=tic;

converged_lnL=0;
converged_par=false;
dParam=inf;
dlnLrel=inf;
for r=1:(Nwarmup+maxIter)
    if(sortModel)
        % sort in order of increasing diffusion constant
        [~,ind]=sort(W.P.lambda);
        if(prod(ind==sort(ind))==0) % the resort the model
            W.P.lambda=W.P.lambda(ind);
            W.P.p0=W.P.p0(ind);
            W.P.A=W.P.A(ind,ind);
            W.S.pst=W.S.pst(:,ind);
            W.S.wA=W.S.wA(ind,ind);
        end
    end

    % iterate
    W=mleYZdXt.hiddenStateUpdate(W,dat);
    dlnLrel=(W.lnL-lnL0)/abs(W.lnL);
    lnL0=W.lnL;
    W=mleYZdXt.diffusionPathUpdate(W,dat);
        
    if(r>Nwarmup)
        if(Pupdate)
            W=mleYZdXt.parameterUpdate(W,dat);
        end
        if(exist('lam0','var'))
            dLam=max(abs(W.P.lambda-lam0)./W.P.lambda);
            dA=max(abs(W.P.A(:)-A0(:)));
            dp0=max(abs(W.P.p0-p00));
            dParam=max([ dLam dA dp0]);
            if(r>(Nwarmup+2))
                if(dParam<parTol && ~converged_par)
                    converged_par=true;
                    EMexit.stopcondition='parTol';
                end
            end
        end
        
        % parameter convergence
        lam0=W.P.lambda;
        A0=W.P.A;
        p00=W.P.p0;
        
        if(~isfinite(W.lnL))
           warning('NaN/Inf log likelihood in mleYZdxT.converge')
           EMexit.stopcondition='lnLnotFinite';
           break
        end        
    end
    
    if(showConv_lnL)
        disp(['it ' int2str(r) ', dlnL = ' num2str(dlnLrel,4) ', dPar = ' num2str(dParam,4) ])
    end
    if(r>(Nwarmup+2) && abs(dlnLrel)<lnLrelTol && converged_lnL<4)
        converged_lnL=converged_lnL+1;
        EMexit.stopcondition='lnLrelTol';
    else
        converged_lnL=0;
    end
    if(converged_lnL>=4 && converged_par)
        break
    else
        EMexit.stopcondition='maxIter';	  
    end
end
EMexit.time=toc(EMtimer);
% add convergence report to model struct
EMexit.numiter=r;
EMexit.dlnLrel=dlnLrel;
W.EMexit=EMexit;
if(showExit)
    disp(W.EMexit)
end

%% path estimates
if(nargout>=2) % compute sequence of most likely states
    [W,sMaxP]=mleYZdXt.hiddenStateUpdate(W,dat);
end
if(nargout>=3) % compute Viterbi path, with a small offset to avoid infinities
    [W,sMaxP,sVit]=mleYZdXt.hiddenStateUpdate(W,dat);
end
