function res=vbuSPTanalysis(runinput)
% res=YZShmm.vbuSPTanalysis(runinput)
% Run an uSPT HMM analysis pipeline based on options struct parameters or
% runinput file.

%% print copyright message

%% get options
opt=spt.getOptions(runinput);
%% read data
X=spt.preprocess(opt);
%% test model object
classFun=eval(['@' opt.model]);
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
    disp('starting pseudo-Bayes factor cross-validation...')
    PBF_H=YZShmm.LOOCV(VBbestN,X,'iType','vbq','displayLevel',1);
    [~,Nbest]=max(mean(PBF_H,1));
    PBF_dlnL=mean(PBF_H-PBF_H(:,Nbest)*ones(1,size(PBF_H,2)),1);
    PpBF_dlnLstdErr=std(PBF_H-PBF_H(:,Nbest)*ones(1,size(PBF_H,2)),[],1)/sqrt(size(PBF_H,1));
    Wbest=VBbestN{Nbest}.clone();
    disp('... done.')
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
    [~,~,~,~,VB_lnLbs]=bootstrap(VBbestN,X,'vb',opt.bootstrap.bootstrapNum,'Dsort',true,'displayLevel',1);
    %%% got this far!!!
    [~,NVBbs]=max(VB_lnLbs,[],2);
end
%% write results to file
save(opt.output.outputFile);
res=load(opt.output.outputFile);
