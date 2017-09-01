function [sMaxP,sVit]=converge(this,dat,varargin)
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
% iType     : kind of iterations {'mle','map','vb'}. Default: mle
% SYPwarmup : omit a number of initial S/YZ/P iterations in order to burn
%             in other variable. Default [0 0 5] (keeps parameters
%             constant for the first 5 iterations). Note that convergence
%             is measured against changes in S and P.
% maxIter   : maximum number of iterations. Default 5000.
% minIter   : minimum number of iterations. Default 5;
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
parTol=1e-4;
SYPwarmup=[0 0 5];
maxIter=5000;
minIter=3;
showConv_lnL=false;
showExit=true;
sortModel=false;
iType='mle';
% parameter interpretations
nv=1;
while(nv <= length(varargin))
   pname=lower(varargin{nv});
   if(~ischar(pname))
       error(['optinal arguments must be name/value pairs.'])
   end
   pval=varargin{nv+1};
   nv=nv+2;
    
   if(strcmp(pname,'sypwarmup'))
      SYPwarmup=pval;
   elseif(strcmp(pname,'maxiter'))
      maxIter=pval;      
   elseif(strcmp(pname,'miniter'))
      minIter=pval;      
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
% some parameter checks
SYPwarmup=SYPwarmup-min(SYPwarmup); % no point withholding all

% construct convergence report
EMexit=struct;
EMexit.stopcondition='maxiter';
% convergence iterations

EMtimer=tic;

converged_lnL=0;
converged_par=0;
dPmax=inf;
dlnLrel=inf;
W1=this.clone();
for r=1:(SYPwarmup+maxIter)
    W2=W1.clone();W1=this.clone(); % save some old steps
    if(sortModel)
        % sort in order of increasing diffusion constant
        this.sortModel();
    end

    % iterate
    if(r>SYPwarmup(2))
        this.YZiter(dat,iType);
    end
    if(r>SYPwarmup(2))
        this.Siter( dat,iType);
    end
    if(r>SYPwarmup(3))
        this.Piter( dat,iType);
    end
    
    % check for nan/inf and save if necessary
    if( ~isfinite(this.YZ.mean_lnqyz) || ~isfinite(this.YZ.mean_lnpxz) || ...
         ~isempty(find(~isfinite(this.YZ.muZ),1)) ||    ~isempty(find(~isfinite(this.YZ.muY),1)) ||    ....
            ~isfinite(this.S.lnZ) || ~isfinite(sum(this.S.wA(:))) || ...
            ~isfinite(sum(this.P.KL_a(:))) ||~isfinite(sum(this.P.KL_B(:))))
        errFile=['YZShmm_' class(W) '_naninf_err' int2str(ceil(1e9*rand)) '.mat'];
        save(errFile)
        error(['NaN/Inf in model fields! Saving workspace to ' errFile])
    end
    
    % check convergence
    [dlnLrel,dPmax,dPmaxName]=this.modelDiff(W1);
    if(dPmax<parTol)
        converged_par=converged_par+1;
    else
        converged_par=0;
    end
    if(dlnLrel<lnLrelTol)
        converged_lnL=converged_lnL+1;
    else
        converged_lnL=0;
    end
    
    if(showConv_lnL)
        disp(['it ' int2str(r) ', dlnL = ' num2str(dlnLrel,4) ', dPar = ' num2str(dPmax,4) ])
    end
    
    if(r>minIter && converged_lnL>2 && converged_par>2)
        % determine which converged last
        if(converged_lnL>converged_par)
            EMexit.stopcondition=dPmaxName;
        else
            EMexit.stopcondition='lnLrelTol';
        end
        break 
    end
    EMexit.stopcondition='maxIter';
end
EMexit.time=toc(EMtimer);
% add convergence report to model struct
EMexit.numiter=r;
EMexit.dlnLrel=dlnLrel;
EMexit.dP=dPmax;
EMexit.dPname=dPmaxName;
this.convergence=EMexit;
if(showExit)
    disp(this.convergence)
end

%% path estimates
if(nargout>=1) % compute sequence of most likely states
    [W,sMaxP]=vbYZdXt.hiddenStateUpdate(W,dat);
end
if(nargout>=2) % compute Viterbi path, with a small offset to avoid infinities
    [W,sMaxP,sVit]=vbYZdXt.hiddenStateUpdate(W,dat);
end
