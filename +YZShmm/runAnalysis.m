function R=runAnalysis(runinput)
% R=YZShmm.runAnalysis(runinput)
% Run an uSPT HMM analysis pipeline based on options struct parameters or
% runinput file.
%
% runinput  : name of runinput file, or option struct. The runinput file
%             can be produced by the usptGUI, or written by hand. See
%             comments in the example runinput file YZSruninput.m for a
%             description of the various options.
%
% res       : a struct with the results of the analysis, which is also
%             saved to the file specified in opt.output.outputFile. Fields:
% 
%  	runinput    : the runinput input 
% 	opt         : the options struct produced by runinput
%   X           : preprocessed data
% --- selected model 
%   W       : selected model, by the variational Bayes (VB) or
%                 pseudo-Bayes factor (PBF) criterion, depending on
%                 opt.modelSearch.PBF. If opt.modelSearch.MLEparam=true,
%                 W is a converged maximum likelihood estimate
%                 (otherwise variational Bayes).
%   N       : number of states in W.
% 	P       : estimated parameters in W (VB or MLE).
% --- VB model search results from YZShmm.VBmodelSearchVariableSize
%   R.VB.WN     : The best VB models of all sized encountered during the VB
%                 model search, up to opt.modelSearch.maxHidden
%   R.VB.lnL     : log evidence lower bounds of R.VB.WN.
%   R.VB.INlnL    : Iteration-, model size, and lnL- value for each model
%                 encountered during the greedy search. 
%   R.VB.P        : Model parameters for each entry in R.VB.INlnL
% --- Pseudo-Bayes factor (PBF) results
%   R.PBF.H       : raw PBF from cross-validation, rescaled to the whole data
%                 set size. 
%   R.PBF.dlnL    : Mean PBF over all cross-validation instances, and offset
%                 relative to the best model
%   R.PBF.dlnLstdErr: standard error (standard deviation / sqrt(number of
%                 cross-validations) ) for R.PBF.dlnL.
% --- bootstrap parameters: bootstrap resampling is done by at the
%                 trajectory level so that the resampled data sets have the
%                 same number of trajectories (but not necessarily the
%                 exact same number of positions) as the original data X.
%   PBS     : bootstrap parameters for W (VB or MLE, depending on
%                 opt.modelSearch.MLEparam), organized so that
%                 PBS.XXX(:,:,j) is the estimated parameters from
%                 bootstrap sample j.
%   PBSstd  : bootstrap standard deviation of the estimated parameters,
%                 can be used as an estimate of parameter standard error.
% --- bootstrap model selection
%	VB_lnLbs    : relative VB log evidence lower bound for the R.VB.WN
%                 models for each bootstrap sample.
%  VB_dlnLstdErr: bootstrap standard error of relative VB log evidence
%   NVBbs       : VB-selected number of states for each bootstrap sample.
%
%   R.PBF.Hbs     : rescaled PBF. Here, bootstrapping is instead done
%                 directly on R.PBF.H without reconverging any model on
%                 bootstrapped trajectories.
%   R.PBF.Nbs      : number of states selected by the bootstrapped PBF (max
%                    N on each row of R.PBF.Hbs).
%
% The distributions of NVBbs and NPBFbs can be used to estimated the
% statistical uncertainty in the model selection.
%
% ML 2017-10-16

%% print copyright message
warning('need to print license information here!')

tAnalysis=tic;
%% get options and initiate results
opt=spt.readRuninputFile(runinput);
R=struct;
R.opt=opt;
%% read data
X=spt.preprocess(opt);
%% test model object
classFun=eval(['@' opt.model.class]);
W=classFun(2,opt,X);
W.Siter(X,'vb');
clear W classFun;
save(opt.output.outputFile,'-struct','R');
%% VB model search
R.VB=struct;
[R.W,R.VB.WN,R.VB.lnL,R.VB.search.INlnL,R.VB.search.P]=YZShmm.VBmodelSearchVariableSize('opt',opt,'data',X,'displayLevel',2);
% note: by definition, R.VB.WN{k}.numStates==k.
% display result of VB model selection
R.VB.dlnL=R.VB.lnL-max(R.VB.lnL);
R.VB.N=R.W.numStates;
R.P=R.W.getParameters(X,'vb');
R.N=R.W.numStates;
save(opt.output.outputFile,'-struct','R');
%% pseudo-Bayes factor model selection
if(opt.modelSearch.PBF)
    R.PBF=struct; %%% need to be followed up
    disp('starting pseudo-Bayes factor cross-validation.')
    %R.PBF.H=YZShmm.LOOCV(R.VB.WN,X,'iType','vbq','displayLevel',1);
    R.PBF.H=YZShmm.crossValidate(R.VB.WN,X,'iType','vbq','numPos',opt.modelSearch.PBFnumPos,'restarts',opt.modelSearch.PBFrestarts,'displayLevel',1);
    [~,R.PBF.N]=max(mean(R.PBF.H,1));
    R.PBF.dlnL=mean(R.PBF.H-R.PBF.H(:,R.PBF.N)*ones(1,size(R.PBF.H,2)),1);
    R.PBF.dlnLstdErr=std(R.PBF.H-R.PBF.H(:,R.PBF.N)*ones(1,size(R.PBF.H,2)),[],1)/sqrt(size(R.PBF.H,1));
    W=R.VB.WN{R.PBF.N}.clone();
    R.P=R.W.getParameters(X,'vb');
    R.N=R.W.numStates;
    save(opt.output.outputFile,'-struct','R');
end
%% (MLE parameters for best model
if(opt.modelSearch.MLEparam)
    R.W.converge(X,'iType','mle');
    R.P=R.W.getParameters(X,'mle');
    R.W.comment=[R.W.comment '; MLE converged.'];
end
save(opt.output.outputFile,'-struct','R');
%% bootstrap model parameters in the best model
if(opt.bootstrap.bestParam)
    if(opt.modelSearch.MLEparam)
        [R.bootstrap.P,R.bootstrap.Pmean,R.bootstrap.PstdErr]=YZShmm.bootstrap(R.W,X,'mle',opt.bootstrap.bootstrapNum);
    elseif(opt.modelSearch.PBF)
        [R.bootstrap.P,~,R.bootstrap.PstdErr]=YZShmm.bootstrap(R.W,X,'vb',opt.bootstrap.bootstrapNum);
    else
        [R.bootstrap.P,~,R.bootstrap.PstdErr]=YZShmm.bootstrap(R.W,X,'vb',opt.bootstrap.bootstrapNum);
    end
end
save(opt.output.outputFile,'-struct','R');
%% bootstrap model selection
if(opt.bootstrap.modelSelection)
    if(opt.modelSearch.PBF)
        % simple bootstrap of cross-validation max-mean values
        R.PBF.bootstrap.H=bootstrp(opt.bootstrap.bootstrapNum,@(x)(mean(x,1)),R.PBF.H);
        [~,R.PBF.bootstrap.N]=max(R.PBF.bootstrap.H,[],2);
    end
    % bootstrap VB model selection
    disp('Bootstrapping VB model selection')
    [R.VB.bootstrap.P,R.VB.bootstrap.Pmean,R.VB.bootstrap.PstdErr,~,R.VB.bootstrap.lnL]=YZShmm.bootstrap(R.VB.WN,X,'vb',opt.bootstrap.bootstrapNum,'Dsort',true,'displayLevel',1);
    [~,R.VB.bootstrap.N]=max(R.VB.bootstrap.lnL,[],2);
    dlnLbs=R.VB.bootstrap.lnL-R.VB.bootstrap.lnL(:,R.VB.N)*ones(1,opt.modelSearch.maxHidden);
    R.VB.bootstrap.dlnLstdErr=std(dlnLbs,[],1);
end
%% write results to file
fprintf('YZShmm.runAnalysis finished in %.1f min, with N=%d ',toc(tAnalysis)/60,R.N)
if(opt.modelSearch.PBF)
    fprintf(' (PBF, N(VB)=%d).\n',R.VB.N);
else
    fprintf(' (VB).\n');    
end
clear ans tAnalysis
save(opt.output.outputFile,'-struct','R');
disp(['Wrote analysis results to ' opt.output.outputFile]);

