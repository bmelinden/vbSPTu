function [W,sMaxP,sVit]=converge(W,dat,varargin)
% [W,sMaxP,sVit]=converge(W,dat)
% Run VB EM iterations on the diffusive HMM W and data dat, until
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
% W     : EM6 HMM model struct, e.g., created by vbYZdXt.init_P_dat
% dat   : EM6 data struct, e.g., from vbYZdXt.preprocess
% optional arguments in the form 'name', value
% Nwarmup   : number of initial iterations where model parameters are kept
%             constant in order to 'burn in' the states and hidden path.
%             Default 5.
% maxIter   : maximum number of iterations (past Nwarmup). Default 5000.
% lnLrelTol : relative convergence criteria for (lnL(n)-lnL(n-1))/|lnL(n)|.
%             Default 1e-8;
% parTol    : convergence criteria for parameters lambda (relative), A, p0
%             (absolute). Default 1e-3;
% Dsort     : sort model in order of increasing diffusion constants.
%             Default=false.
% display   : Level of output. 0: no output. 1 (default): print convergence
%             message. 2: print convergence every iteration.
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
sortModel=false;

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
    %%% debug
    W1=W;W2=W1;W3=W2; % save some old steps
    if(sortModel)
        % sort in order of increasing diffusion constant
        W=vbYZdXt.sortModel(W);
    end

    % iterate
    W=vbYZdXt.hiddenStateUpdate(W,dat);
    dlnLrel=(W.lnL-lnL0)/abs(W.lnL);
    lnL0=W.lnL;
    W=vbYZdXt.diffusionPathUpdate(W,dat);
    
    if(r>Nwarmup)
        W=vbYZdXt.parameterUpdate(W,dat);
        if(exist('P0','var'))
            P1=vbYZdXt.parameterEstimate(W);
            dLam=max(abs(P1.lambda(:)-P0.lambda(:))./P1.lambda(:));
            dA=max(abs(P1.A(:)-P0.A(:)));
            dp0=max(abs(P1.p0(:)-P0.p0(:)));
            dParam=max([ dLam dA dp0]);
            if(r>(Nwarmup+2))
                if(dParam<parTol && ~converged_par)
                    converged_par=true;
                    EMexit.stopcondition='parTol';
                end
            end
        end
        % parameter convergence
        P0=vbYZdXt.parameterEstimate(W);
    end
    
    % check for nan/inf and save if necessary
    if( ~isfinite(W.YZ.mean_lnqyz) || ~isfinite(W.YZ.mean_lnpxz) || ~isfinite(W.YZ.Fs_yz) || ...
            ~isfinite(W.S.lnZ) || ~isfinite(sum(W.S.wA(:))) || ...
            ~isfinite(sum(W.P.KL_a(:))) ||~isfinite(sum(W.P.KL_B(:))))
        errFile=['vbYZdXt_naninf_err' int2str(ceil(1e9*rand)) '.mat'];
        save(errFile)
        error(['NaN/Inf in model fields! Saving workspace to ' errFile])
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
    [W,sMaxP]=vbYZdXt.hiddenStateUpdate(W,dat);
end
if(nargout>=3) % compute Viterbi path, with a small offset to avoid infinities
    [W,sMaxP,sVit]=vbYZdXt.hiddenStateUpdate(W,dat);
end
