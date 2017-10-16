function [Wbest,WbestN,dlnL,INlnL,P,YZmv]=VBmodelSearchVariableSize(varargin)
% [Wbest,WbestN,dlnL,INlnL,P,YZmv]=YZShmm.VBmodelSearchVariableSize('P1',P1,...)
%
% Input parameters are given as parameter-value pairs on the form
% 'parameter',parameter (case sensitive):
% opt   : options struct or runinputfile name
% optional additional arguments, take precedence over the corresponding
% options in the opt struct in applicable cases:
% classFun    : YZhmm model constructor handle (e.g. @YZShmm.dXt).
%               Default: opt.model
% data  : data struct from spt.preprocess.
%         Default: read from from opt.trj.inputfile
% YZww  : list of window widths (radii) for q(Y,Z) moving average diffusion
%         filter, positive integers. Default: opt.modelSearch.YZww
% restarts : number of independent restarts. restarts=0 only computes
%         moving average q(Y,Z) distributions.
%         Default opt.modelSearch.restarts
% qYZ0  : precomputed q(Y,Z) distribution(s) to include as initial guesses,
%         either as a single YZ subfield, or as a cell vector of YZ
%         subfields. Default {} (no pre-computed YZ distributions used).
% Winit : cell vector of converged models to include in the comparison
%         (e.g., result of an earlier model search).
% displayLevel : display level. Default 1.
%
% output: 
% Wbest : the best converged model
% WbestN: best converged models of each size ( or a struct with field
%         lnL=-inf, if the search did not get to small enough model sizes).
% dlnL  : The highest lnL-values for each model size, relative to the
%         overall best value. dlnL=nan for model sizes not encountered.
% INlnL : Iteration-, model size, and lnL- value for each model encountered
%         during the greedy search. 
% P     : Parameter struct (using the getParameters method) for each model
%         encountered during the greedy search.
% 
% YZmv   : moving averages YZ structs (to make it possible to reuse them). 

%% parameters and defaults
% get options first
kOpt=2*find(strcmp('opt',varargin(1:2:end)),1);
opt=varargin{kOpt};
opt=spt.getOptions(opt);
% default values
restarts=opt.modelSearch.restarts;
classFun=eval(['@' opt.model]);
maxHidden  =opt.modelSearch.maxHidden;
if(isfield(opt.modelSearch,'VBinitHidden'))
    VBinitHidden = opt.modelSearch.VBinitHidden;
else
   warning('Missing  opt.modelSearch.VBinitHidden, using opt.modelSearch.maxHidden instead.')
   VBinitHidden=maxHidden;
end
YZww=opt.modelSearch.YZww;
data=[];
qYZ0={};
Winit={};
displayLevel=1;
% additional input parameters
parNames={'opt','classFun','data','YZww','qYZ0','displayLevel','restarts','Winit'};
for k=1:2:numel(varargin)
    if(isempty(find(strcmp(varargin{k},parNames),1)))
        error(['Parameter ' varargin{k} ' not recognized.'])
    end
    eval([varargin{k} '=varargin{ ' int2str(k+1) '};'])
end
if(~iscell(qYZ0))
    qYZ0={qYZ0};
end

% start message
tstart=tic;
% display some starting information
uSPTlicense(mfilename)
disp('----------')
disp(['Restarts     : ' int2str(restarts )])
disp(['Max states   : ' int2str(maxHidden)])
disp(['Init states  : ' int2str(VBinitHidden)])

if(isempty(data))
    data=spt.preprocess(opt);
    disp(['runinput file: ' opt.runinputfile])
    disp(['input  file  : ' opt.trj.inputfile])
end
disp(['Num. trj     : ' int2str(numel(data.T))])
disp(['Num. steps   : ' int2str(sum(  data.T-1))])
disp([ datestr(now) ' : Starting VB greedy model search.'])
disp('----------')

% test parameters
W=classFun(maxHidden,opt,data);
W.YZiter(data,'vb');
clear W;
% pre-compute moving average initial guesses
[~,YZmv]=YZShmm.modelSearchFixedSize('classFun',classFun,'N0',1,'opt',opt,...
    'data',data,'iType','vb','YZww',YZww,'displayLevel',0,'restarts',1);
qYZ0=[qYZ0,YZmv];
%% greedy search 
WbestNiter  =cell(1,restarts); % best model of each size in each run
Niter  =cell(1,restarts); % from all models generated in each run
lnLiter=cell(1,restarts); % from all models generated in each run
Piter  =cell(1,restarts); % from all models generated in each run
parfor iter=1:restarts   
%%%for iter=1:restarts %%% debug without parfor
    % Greedy search strategy is probably more efficient than to start over
    % at each model size. We simply start with a large model, and
    % systematically remove the least occupied statate until things start
    % to get worse.
    titer=tic;
    W0=YZShmm.modelSearchFixedSize('classFun',classFun,'N0',VBinitHidden,'opt',opt,...
        'data',data,'iType','vb','qYZ0',qYZ0,'YZww',[],'displayLevel',displayLevel-2,'restarts',1);
    WbestNiter{iter}={};
    % [Wbest,WNbest,lnLsearch,Nsearch,Wsearch]=VBgreedyReduce(this,dat,opt,displayLevel)
    [WbestIter,WbestNiter{iter},lnLiter{iter},Niter{iter},Piter{iter}]=...
        W0.VBgreedyReduce(data,opt,displayLevel-2);
    % remove model sizes > maxHidden but <= initHidden
    WN=inf(size(WbestNiter{iter}));
    for wn=1:numel(WN)
        if(~isempty(WbestNiter{iter}{wn}))
            WN(wn)=WbestNiter{iter}{wn}.numStates;
        end
    end
    WbestNiter{iter}=WbestNiter{iter}(WN<=maxHidden);
    % warning if maxHidden is too small
    if(WbestIter.numStates>=maxHidden)
        warning(['Greedy VB search found ' int2str(WbestIter.numState) ' >= maxHidden. maxHidden = ' int2str(maxHidden) ' probably too small.'])
    end
    
    if(displayLevel>=2)
        disp(['VBmodelSearch iter ' int2str(iter) ' finished in '  ...
            num2str(toc(titer)) ' s, with ' int2str(WbestIter.numStates) ...
            ' states from ' WbestIter.comment] )
    end
end
%% collect best models for all sizes
INlnL=[];
P=[];
Wbest=struct('lnL',-inf);
WbestN=cell(1,maxHidden);
dlnL=nan(1,maxHidden);
for k=1:maxHidden
    WbestN{k}=struct('lnL',-inf);
end
bestIter=0;
if(~isempty(Winit))
    % put initial guesses in a cell vector if not in that form already
    if(~iscell(Winit))
        Winit0=Winit;
        Winit=cell(size(Winit0));
        for k=1:numel(Winit0)
            Winit{k}=Winit0(k);
        end
    end
    clear Winit0;
    % converge Winit (just in case)
    for k=1:numel(Winit)
        try
            w=Winit{k};
            w.converge( data,'iType','vb','PSYwarmup',[-1 0 0 ],'displayLevel',displayLevel-1);
        catch me
            if(this.conv.saveErr)
                errFile=[class(this) '_Winit_err' int2str(ceil(1e9*rand)) '.mat'];
                save(errFile)
                warning(['Error while converging initial model ' int2str(k) '. Skipping that model, but saving workspace to ' errFile])
            else
                warning(['Error while converging initial model ' int2str(k) '. Skipping that model. Set model field conv.saveErr=true to write debug information to file.'])
                continue
            end
        end
        if(w.lnL>Wbest.lnL)
            Wbest=w.clone();
        end
        
    end

end
% some history of all models encountered during search
for iter=1:restarts
    INlnL=[INlnL; iter*ones(size(Niter{iter})) Niter{iter} lnLiter{iter}];
    P    =[P; Piter{iter}];
    for k=1:length(WbestNiter{iter})
        w=WbestNiter{iter}{k}; % remember: models < handle class
        if(~isempty(w))
            w.sortModel();
            if(isempty(P))
                P=w.getParameters(data,'vb');
            else
                P(end+1)=w.getParameters(data,'vb');
            end
            if(w.lnL>Wbest.lnL)
                Wbest=w.clone();
                bestIter=iter;
            end
            if(isempty(WbestN{w.numStates}) || w.lnL>WbestN{w.numStates}.lnL)
                WbestN{w.numStates}=w.clone();
                dlnL(w.numStates)=w.lnL;
            end
        end
    end
end
dlnL=dlnL-max(dlnL);
if(displayLevel>=1)
    if(bestIter>0)
        disp([datestr(now) ' : VBmodelSearch converged with ' int2str(Wbest.numStates) ' states, from iter ' int2str(bestIter) '. Total run time ' num2str(toc(tstart)/60,2) ' min.'])
    else
        disp([datestr(now) ' : VBmodelSearch converged, but did not improve upon the Winit model with ' int2str(Wbest.numStates) ' states.'])
    end
end

