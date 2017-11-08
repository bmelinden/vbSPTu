function [R,opt,dat]=vbuSPTdisplay(runinput)
% [R,opt,dat]=YZShmm.vbuSPTdisplay(runinput)
%
% Display the results of YZShmm.vbuSPTanalysis in a standardized way

% get a runinput file is not given
if(~exist('runinput','var') || isempty(runinput))
    
    [filename, pathname, filterindex] = uigetfile( ...
        {'*.m','(*.m)'}, ...
        'Pick a runinput file', 'runinput.m');
    if(filterindex<=0 && ~exist(fullfile(pathname,filename),'file') )
        disp('Runinput file not found, or no runinput file selected.')
        return
    end
    runinput=fullfile(pathname,filename);
end
        
% read options
opt=spt.readRuninputFile(runinput);        
        
% read analysis results
R=spt.readResult(opt);

% read data
dat=spt.preprocess(runinput);

% display rough analysis and data parameters
disp('------------------------------------------------------------')
disp(['model    : ' opt.model.class ', ' int2str(sum(dat.T-1)) ' steps, ' ...
    int2str(R.Wbest.numStates) ' states, ' int2str(R.Wbest.sample.dim) 'd.'])
disp(['runinput : ' opt.runinputfile ' in ' opt.runinputroot])
disp(['results  : ' opt.output.outputFile ' in ' opt.runinputroot])
disp('------------------------------------------------------------')
    
% display model parameters
if(opt.modelSearch.MLEparam)
    disp('MLE parameters : ')
else
    disp('VB parameters : ')
end
Pest=R.Pbest;
vars=fieldnames(Pest);
vars=setdiff(vars,'dwellSteps');
if(isfield(R,'PbestBSstd'))
    dPest=R.PbestBSstd;
    displayStruct(Pest,'dP',dPest,'scale',{'D',1e-6},... %,'units',{'D','um2/s','RMS','nm','dwellTime','s'},...
        'fieldName',vars,'numFormat','6.2f')
else
    displayStruct(Pest,'scale',{'D',1e-6},... %,'units',{'D','um2/s','RMS','nm','dwellTime','s'},...
        'fieldName',vars,'numFormat','6.2f')
end
disp('------------------------------------------------------------')
    
    % plot model selection
    
    
    
    1;
    
end
