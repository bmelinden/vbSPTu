function res=runAnalysis(runinput)
% res=YZShmm.runAnalysis(runinput)
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
%   Wbest       : selected model, by the variational Bayes (VB) or
%                 pseudo-Bayes factor (PBF) criterion, depending on
%                 opt.modelSearch.PBF. If opt.modelSearch.MLEparam=true,
%                 Wbest is a converged maximum likelihood estimate
%                 (otherwise variational Bayes).
%   Nbest       : number of states in Wbest.
% 	Pbest       : estimated parameters in Wbest (VB or MLE).
% --- VB model search results from YZShmm.VBmodelSearchVariableSize
%   VBbestN     : The best VB models of all sized encountered during the VB
%                 model search, up to opt.modelSearch.maxHidden
%   VB_dlnL     : log evidence lower bounds of VBbestN, relative to the
%                 best model
%   VB_INlnL    : Iteration-, model size, and lnL- value for each model
%                 encountered during the greedy search. 
%   VB_P        : Model parameters for each entry in VB_INlnL
% --- Pseudo-Bayes factor (PBF) results
%   PBF_H       : raw PBF from cross-validation, rescaled to the whole data
%                 set size. 
%   PBF_dlnL    : Mean PBF over all cross-validation instances, and offset
%                 relative to the best model
%   PBF_dlnLstdErr: standard error (standard deviation / sqrt(number of
%                 cross-validations) ) for PBF_dlnL.
% --- bootstrap parameters: bootstrap resampling is done by at the
%                 trajectory level so that the resampled data sets have the
%                 same number of trajectories (but not necessarily the
%                 exact same number of positions) as the original data X.
%   PbestBS     : bootstrap parameters for Wbest (VB or MLE, depending on
%                 opt.modelSearch.MLEparam), organized so that
%                 PbestBS.XXX(:,:,j) is the estimated parameters from
%                 bootstrap sample j.
%   PbestBSstd  : bootstrap standard deviation of the estimated parameters,
%                 can be used as an estimate of parameter standard error.
% --- bootstrap model selection
%	VB_lnLbs    : relative VB log evidence lower bound for the VBbestN
%                 models for each bootstrap sample.
%  VB_dlnLstdErr: bootstrap standard error of relative VB log evidence
%   NVBbs       : VB-selected number of states for each bootstrap sample.
%
%   PBF_Hbs     : rescaled PBF. Here, bootstrapping is instead done
%                 directly on PBF_H without reconverging any model on
%                 bootstrapped trajectories.
%   NPBFbs      : number of states selected by the cross-validated PBF.
%
% The distributions of NVBbs and NPBFbs can be used to estimated the
% statistical uncertainty in the model selection.
%
% ML 2017-10-16

%% print copyright message
warning('need to print license information here!')

tAnalysis=tic;
%% get options
opt=spt.readRuninputFile(runinput);
%% read data
X=spt.preprocess(opt);
%% test model object
classFun=eval(['@' opt.model.class]);
W=classFun(2,opt,X);
W.Siter(X,'vb');
clear W classFun;
save(opt.output.outputFile);
%% VB model search
[Wbest,VBbestN,VB_dlnL,VB_INlnL,VB_P]=YZShmm.VBmodelSearchVariableSize('opt',opt,'data',X,'displayLevel',2);
% note: by definition, VBbestN{k}.numStates==k.
% display result of VB model selection
Nbest=Wbest.numStates;
save(opt.output.outputFile);
%% pseudo-Bayes factor model selection
if(opt.modelSearch.PBF)
    disp('starting pseudo-Bayes factor cross-validation.')
    %PBF_H=YZShmm.LOOCV(VBbestN,X,'iType','vbq','displayLevel',1);
    PBF_H=YZShmm.crossValidate(VBbestN,X,'iType','vbq','Kpos',opt.modelSearch.PBFnumPos,'restarts',opt.modelSearch.PBFrestarts,'displayLevel',1);
    [~,Nbest]=max(mean(PBF_H,1));
    PBF_dlnL=mean(PBF_H-PBF_H(:,Nbest)*ones(1,size(PBF_H,2)),1);
    PBF_dlnLstdErr=std(PBF_H-PBF_H(:,Nbest)*ones(1,size(PBF_H,2)),[],1)/sqrt(size(PBF_H,1));
    Wbest=VBbestN{Nbest}.clone();
    save(opt.output.outputFile);
end
%% MLE parameters for best model
if(opt.modelSearch.MLEparam)
    Wbest.converge(X,'iType','mle');    
    Pbest=Wbest.getParameters(X,'mle');
else
    Pbest=Wbest.getParameters(X,'iType','vb');
end
save(opt.output.outputFile);
%% bootstrap model parameters in the best model
if(opt.bootstrap.bestParam)
    if(opt.modelSearch.MLEparam)
        [PbestBS,~,PbestBSstd]=YZShmm.bootstrap(Wbest,X,'mle',opt.bootstrap.bootstrapNum);
    else        
        [PbestBS,~,PbestBSstd]=YZShmm.bootstrap(Wbest,X,'vb',opt.bootstrap.bootstrapNum);
    end    
end
save(opt.output.outputFile);
%% bootstrap model selection
if(opt.bootstrap.modelSelection)
    if(opt.modelSearch.PBF)
        % simple bootstrap of cross-validation max-mean values
        PBF_Hbs=bootstrp(opt.bootstrap.bootstrapNum,@(x)(mean(x,1)),PBF_H);
        [~,NPBFbs]=max(PBF_Hbs,[],2);
    end
    % bootstrap VB model selection
    [~,~,~,~,VB_lnLbs]=YZShmm.bootstrap(VBbestN,X,'vb',opt.bootstrap.bootstrapNum,'Dsort',true,'displayLevel',1);
    [~,NVBbs]=max(VB_lnLbs,[],2);
    VB_dlnLbs=VB_lnLbs-VB_lnLbs(:,Nbest)*ones(1,opt.modelSearch.maxHidden);
    VB_dlnLstdErr=std(VB_dlnLbs,[],1);
end
%% write results to file
fprintf('YZShmm.runAnalysis finished in %.1f min, with N=%d ',toc(tAnalysis)/60,Nbest)
if(opt.modelSearch.PBF)
    [~,NVB]=max(VB_dlnL);
    fprintf(' (PBF, VB gave N=%d).\n',NVB);
    clear NVB;
else
    fprintf(' (VB).\n');    
end
clear ans tAnalysis
save(opt.output.outputFile);
disp(['Wrote analysis results to ' opt.output.outputFile]);

% save output to struct
vv=whos;
res=struct;
for m=1:length(vv)
    res.(vv(m).name)=eval(vv(m).name);    
end

