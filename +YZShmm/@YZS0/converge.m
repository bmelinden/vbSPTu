function [sMaxP,sVit]=converge(this,dat,varargin)
% [sMaxP,sVit]=converge(dat,'iType',iType,'param1',value1,...) 
%
% Run EM iterations of type iType (see below) on the model object with data
% dat, until convergence. Iterations are performed in order
% Piter->Siter->YZiter, until convergence.
%
% Output:
% W     : converged HMM model
% sMaxP : trajectory of most likely states 
% sVit  : most likely trajectory of hidden states (from Viterbi algorithm)
% sMaxP and sVit are a little expensive, and only computed if asked for by
% output arguments.
%
% Input :
% dat   : data struct, e.g., from spt.preprocess
% optional arguments in the form 'name', value
% iType     : kind of iterations {'mle','map','vb'}. Default: mle
% SYPwarmup : omit a number of initial S/YZ/P iterations in order to burn
%             in other variable. Default [0 0 5] (keeps parameters
%             constant for the first 5 iterations). Note that convergence
%             is measured against changes in S and P.
% SYPfixed  : omit S/YZ/P-iterations, i.e., keep one part of the model
%             fixed. 1/2/3 -> omit S/YZ/P iterations. 0 (default): omit
%             nothing. Convergnce criteria are not applied to
%             distributions that are not updated. Note that keeping more
%             than one distribution fixed corresponds to a single iteration
%             of the non-fixed distribution, and is not implemented here.
% maxIter   : maximum number of iterations. Default: object setting.
% lnLTol    : relative convergence criteria for (lnL(n)-lnL(n-1))/|lnL(n)|.
%             Default: object setting.
% parTol    : convergence criteria for parameters lambda (relative), A, p0
%             (absolute). Default: object setting.
% minIter   : minimum number of iterations. Default 5;
% Dsort     : sort model in order of increasing diffusion constants.
%             Default=false.
% displayLevel   : Level of output. 0: no output. 1 (default): print convergence
%             message. 2: print convergence every iteration.
%
% 2016-06-28 : researched convergence problems, and found one that was due
% to one state becoming completely unoccopied, which in turn induces NaNs
% in the transition matrix, and from there to the whole model.
% 2017-06-27: started modifying to fit in the YZShmm package instead. Very
% small differences

%% start of actual code

% default parameter values
maxIter=this.conv.maxIter;
lnLTol=this.conv.lnLTol;
parTol=this.conv.parTol;
SYPwarmup=[0 0 5];
SYPfixed=0;
minIter=5;
showConv_lnL=false;
showExit=true;
sortModel=false;
iType='mle';
% parameter interpretations
nv=1;
while(nv <= length(varargin))
   pname=lower(varargin{nv});
   if(~ischar(pname))
       error('optinal arguments must be name/value pairs.')
   end
   pval=varargin{nv+1};
   nv=nv+2;    
   if(strcmp(pname,'sypwarmup'))
      SYPwarmup=pval;
   elseif(strcmp(pname,'sypfixed'))
      SYPfixed=pval;
   elseif(strcmp(pname,'maxiter'))
      maxIter=pval;      
   elseif(strcmp(pname,'miniter'))
      minIter=pval;      
   elseif(strcmp(pname,'lnltol'))
      lnLTol=pval;      
   elseif(strcmp(pname,'partol'))
      parTol=pval;      
   elseif(strcmp(pname,'dsort'))
      sortModel=pval;    
   elseif(strcmp(pname,'itype'))
      iType=pval;    
   elseif(strcmp(pname,'displaylevel'))
      n=pval;
      showExit=(n>=1);
      showConv_lnL=(n>=2);
   else
       error(['Unrecognized option ' pname ])
   end   
end
% some parameter checks
SYPwarmup=SYPwarmup-min(SYPwarmup); % no point withholding all

% construct convergence report
EMexit=struct;
EMexit.stopcondition='maxiter';
EMexit.iType=iType;
% convergence iterations

EMtimer=tic;

converged_lnL=0;
converged_par=0;
dPmax=inf;
dlnLrel=inf;
W1=this.clone();
for r=1:+maxIter
    W2=W1.clone();W1=this.clone(); % save some old steps
    if(sortModel)
        % sort in order of increasing diffusion constant
        this.sortModel();
    end

    % iterate
    if(r>SYPwarmup(3) && SYPfixed~=3)
        this.Piter( dat,iType);
    end
    if(r>SYPwarmup(1)  && SYPfixed~=1)
        this.Siter( dat,iType);
    end
    if(r>SYPwarmup(2)  && SYPfixed~=2)
        this.YZiter(dat,iType);
    end    
    % check for nan/inf and save if necessary
    if( ~isfinite(this.YZ.mean_lnqyz) || ~isfinite(this.YZ.mean_lnpxz) || ...
         ~isempty(find(~isfinite(this.YZ.muZ),1)) ||    ~isempty(find(~isfinite(this.YZ.muY),1)) ||    ....
            ~isfinite(this.S.lnZ) || ~isfinite(sum(this.S.wA(:))) || ...
            ~isfinite(sum(this.P.KL_a(:))) ||~isfinite(sum(this.P.KL_B(:))))
        errFile=[class(this) '_naninf_err' int2str(ceil(1e9*rand)) '.mat'];
        save(errFile)
        error(['NaN/Inf in model fields! Saving workspace to ' errFile])
    end
    
    % check convergence
    [dlnLrel,dPmax,dPmaxName]=this.modelDiff(W1);
    if( (dPmax<parTol && SYPwarmup(3)<r) || SYPfixed==3 )
        converged_par=converged_par+1;
    else
        converged_par=0;
    end
    if(dlnLrel<lnLTol  || SYPfixed==1)
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
            EMexit.stopcondition='lnLTol';
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
this.EMexit=EMexit;
if(showExit)
    disp(this.EMexit)
end

%% path estimates
if(nargout>=1) % compute sequence of most likely states
    [W,sMaxP]=vbYZdXt.hiddenStateUpdate(W,dat);
end
if(nargout>=2) % compute Viterbi path, with a small offset to avoid infinities
    [W,sMaxP,sVit]=vbYZdXt.hiddenStateUpdate(W,dat);
end
