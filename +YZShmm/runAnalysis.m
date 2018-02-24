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
% R       : a struct with the results of the analysis, which is also
%             saved to the file specified in opt.output.outputFile. Fields:
% 
% 	opt         : the options struct produced from runinput
%   X           : preprocessed data
% --- selected model 
%   model   : selected model, by the variational Bayes (VB) or pseudo-Bayes
%             factor (PBF) criterion, depending on opt.modelSearch.PBF. If
%             opt.modelSearch.MLEparam=true, R.model is a converged maximum
%             likelihood estimate (otherwise variational Bayes).
%   N       : number of states in R.model.
% 	P       : estimated parameters in R.model (VB or MLE).
% --- VB model search results from YZShmm.modelSearch
%   R.VB.model     : The best VB models of all sized encountered during the VB
%                 model search, up to opt.modelSearch.maxHidden
%   R.VB.lnL     : log evidence lower bounds of R.VB.model.
%   R.VB.search.IINlnL    : Iteration, init guess number, model size, and lnL- value for each model
%                 encountered during the greedy search. 
%   R.VB.search.param        : Model parameters for each entry in R.VB.search.IINlnL
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
%	VB_lnLbs    : relative VB log evidence lower bound for the R.VB.model
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
uSPTlicense('runAnalysis')
tAnalysis=tic;
%% get options and initiate results
opt=spt.readRuninputFile(runinput);
R=struct;
R.opt=opt;
%% read data
X=spt.preprocess(opt);
%% test model object
classFun=eval(['@' R.opt.model.class]);
W=classFun(2,opt,X);
W.Siter(X,'vb');
clear W classFun;
[a,b,c]=fileparts(R.opt.output.outputFile)
R.diaryFile=fullfile(a,[b '.log']);
diary(R.diaryFile)
save(R.opt.output.outputFile,'-struct','R');
%% VB model search
R.VB=struct;
[R.model,R.VB.model,R.VB.lnL,R.VB.search.IINlnL,R.VB.search.param]=YZShmm.modelSearch('opt',opt,'data',X,'displayLevel',2);
% note: by definition, R.VB.model{k}.numStates==k.
% display result of VB model selection
R.VB.dlnL=R.VB.lnL-max(R.VB.lnL);
R.VB.numStates=R.model.numStates;
R.VB.param=R.model.getParameters(X,'vb');
R.param=R.model.getParameters(X,'vb');
R.numStates=R.model.numStates;
save(R.opt.output.outputFile,'-struct','R');
%% pseudo-Bayes factor model selection
if(R.opt.modelSearch.PBF)
    % compute pseudo-Bayes factors
    R.PBF=struct; 
    disp('starting pseudo-Bayes factor cross-validation.')
    %R.PBF.H=YZShmm.LOOCV(R.VB.model,X,'iType','vbq','displayLevel',1);
    %R.PBF.H=YZShmm.crossValidate(R.VB.model,X,'iType','vbq','numPos',R.opt.modelSearch.PBFnumPos,'restarts',R.opt.modelSearch.PBFrestarts,'displayLevel',1);
    R.PBF.H=YZShmm.crossValidate(R.VB.model,X,'iType','vbq','fracPos',R.opt.modelSearch.PBFfracPos,'restarts',R.opt.modelSearch.PBFrestarts,'displayLevel',1);
    [~,R.PBF.numStates]=max(mean(R.PBF.H,1));
    R.PBF.dlnL=mean(R.PBF.H-R.PBF.H(:,R.PBF.numStates)*ones(1,size(R.PBF.H,2)),1);
    R.PBF.dlnLstdErr=std(R.PBF.H-R.PBF.H(:,R.PBF.numStates)*ones(1,size(R.PBF.H,2)),[],1)/sqrt(size(R.PBF.H,1));
    % transfer PBF model selection to main model
    R.model=R.VB.model{R.PBF.numStates}.clone();
    R.param=R.model.getParameters(X,'vb');
    R.numStates=R.model.numStates;
    save(R.opt.output.outputFile,'-struct','R');
end
%% MLE parameters for best model
if(R.opt.modelSearch.MLEparam)
    disp('converging maximum likelihood estimates')
    R.model.converge(X,'iType','mle');
    R.param=R.model.getParameters(X,'mle');
    R.model.comment=[R.model.comment '; MLE converged.'];
end
save(R.opt.output.outputFile,'-struct','R');
%% bootstrap model parameters in the best model
if(R.opt.bootstrap.bestParam)
    if(R.opt.modelSearch.MLEparam)
        [R.bootstrap.param,~,R.bootstrap.paramStdErr]=YZShmm.bootstrap(R.model,X,'mle',R.opt.bootstrap.bootstrapNum);
    else
        [R.bootstrap.param,~,R.bootstrap.paramStdErr]=YZShmm.bootstrap(R.model,X,'vb',R.opt.bootstrap.bootstrapNum);
    end
end
save(R.opt.output.outputFile,'-struct','R');
%% bootstrap model selection
if(R.opt.bootstrap.modelSelection)
    if(R.opt.modelSearch.PBF)
        % simple bootstrap of cross-validation max-mean values
        lnLbs=bootstrp(R.opt.bootstrap.bootstrapNum,@(x)(mean(x,1)),R.PBF.H);
        [~,R.PBF.bootstrap.numStates]=max(lnLbs,[],2);
        R.PBF.bootstrap.dlnL=lnLbs-lnLbs(:,R.PBF.numStates)*ones(1,size(lnLbs,2));
        R.PBF.bootstrap.dlnLstdErr=std(R.PBF.bootstrap.dlnL,[],1);
    end
    % bootstrap VB model selection
    disp('Bootstrapping VB model selection')
    [R.VB.bootstrap.param,R.VB.bootstrap.paramMean,R.VB.bootstrap.paramStdErr,~,R.VB.bootstrap.lnL]=YZShmm.bootstrap(R.VB.model,X,'vb',R.opt.bootstrap.bootstrapNum,'Dsort',true,'displayLevel',1);
    [~,R.VB.bootstrap.numStates]=max(R.VB.bootstrap.lnL,[],2);
    R.VB.bootstrap.dlnL=R.VB.bootstrap.lnL-R.VB.bootstrap.lnL(:,R.VB.numStates)*ones(1,R.opt.modelSearch.maxHidden);
    R.VB.bootstrap.dlnLstdErr=std(R.VB.bootstrap.dlnL,[],1);
end
%% write results to file
fprintf('YZShmm.runAnalysis finished in %.1f min, with N=%d ',toc(tAnalysis)/60,R.numStates)
if(R.opt.modelSearch.PBF)
    fprintf(' (PBF, N_VB=%d).\n',R.VB.numStates);
else
    fprintf(' (VB).\n');    
end
clear ans tAnalysis
save(R.opt.output.outputFile,'-struct','R');
disp(['Wrote analysis results to ' R.opt.output.outputFile]);

