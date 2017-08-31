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
% W     : YZSmodel object
% dat   : data struct, e.g., from spt.preprocess
% optional arguments in the form 'name', value
% iType     : kind of iterations {'mle','map','vb'}.
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
   pname=lower(varargin{nv});
   if(~ischar(pname))
       error(['optinal arguments must be name/value pairs.'])
   end
   pval=varargin{nv+1};
   nv=nv+2;
    
   if(strcmp(pname,'nwarmup'))
      Nwarmup=pval;
   elseif(strcmp(pname,'maxiter'))
      maxIter=pval;      
   elseif(strcmp(pname,'lnlreltol'))
      lnLrelTol=pval;      
   elseif(strcmp(pname,'partol'))
      parTol=pval;      
   elseif(strcmp(pname,'dsort'))
      sortModel=pval;    
   elseif(strcmp(pname,'itype'))
      iType=pval;    
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
dPmax=inf;
dlnLrel=inf;
W1=W.clone();
for r=1:(Nwarmup+maxIter)
    %%% debug
    W2=W1.clone();W1=W.clone(); % save some old steps
    if(sortModel)
        % sort in order of increasing diffusion constant
        W.sortModel();
    end

    % iterate
    W.YZiter(dat);   
    W.Siter(dat);
    if(r>Nwarmup)
        W.Piter(dat);
        [dlnLrel,dPmax,maxParName]=W.modelDiff(W1);
        if(r>(Nwarmup+2))
            if(dPmax<parTol && ~converged_par)
                converged_par=true;
                EMexit.stopcondition=maxParName;
            end
        end
    end
    %%% got this far!!!
    
    % check for nan/inf and save if necessary
    if( ~isfinite(W.YZ.mean_lnqyz) || ~isfinite(W.YZ.mean_lnpxz) || ...
         ~isempty(find(~isfinite(W.YZ.muZ),1)) ||    ~isempty(find(~isfinite(W.YZ.muY),1)) ||    ....
            ~isfinite(W.S.lnZ) || ~isfinite(sum(W.S.wA(:))) || ...
            ~isfinite(sum(W.P.KL_a(:))) ||~isfinite(sum(W.P.KL_B(:))))
        errFile=['vbYZdXt_naninf_err' int2str(ceil(1e9*rand)) '.mat'];
        save(errFile)
        error(['NaN/Inf in model fields! Saving workspace to ' errFile])
    end
    
    
    if(showConv_lnL)
        disp(['it ' int2str(r) ', dlnL = ' num2str(dlnLrel,4) ', dPar = ' num2str(dPmax,4) ])
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
