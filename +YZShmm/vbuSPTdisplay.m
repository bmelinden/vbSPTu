function [R,opt,dat]=vbuSPTdisplay(runinput,varargin)
% [R,opt,dat]=YZShmm.vbuSPTdisplay(runinput,p1,v1,p2,v2,...)
%
% Display the results of YZShmm.vbuSPTanalysis in a standardized way
% 
% runinput : 1) name of runinput file, or
%            2) options struct, or
%            3) [] (in which case a runinput GUI asks for a runinput file)
% p1,v1,p2,v2,...
% Optional parameter-value pairs passed on to the displayStruct function,
% as applied to the estimated model parameters. 
% 
% Example: convert D from nm^"/S to um^2/s, and display units of D, RMNerr
% and dwellTime:
% ...,'scale',{'D',1e-6},'units',{'D','um2/s','RMSerr','nm','dwellTime','s'}) 

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
    displayStruct(Pest,'dP',dPest,'fieldName',vars,'numFormat','6.2f',varargin{:})
else
    displayStruct(Pest,'scale','fieldName',vars,'numFormat','6.2f',varargin{:})
end
disp('------------------------------------------------------------')
    
    % plot model selection
    
    
    
    1;
    
end
