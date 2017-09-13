function [Wbest,WbestN,dlnL,INlnL,P,YZmv]=VBmodelSearchVariableSize(varargin)
% [Wbest,WbestN,dlnL,INlnL,P,YZmv]=VBmodelSearchVariableSize(opt,'P1',P1,...)
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
restart=opt.modelSearch.restarts;
classFun=opt.model;
maxHidden  =opt.modelSearch.maxHidden;
YZww=opt.modelSearch.YZww;
Pwarmup=opt.modelSearch.Pwarmup;
data=[];
qYZ0={};
displayLevel=1;
% additional input parameters
parNames={'opt','classFun','data','YZww','qYZ0','displayLevel','restarts'};
for k=1:2:numel(varargin)
    if(isempty(find(strcmp(varargin{k},parNames),1)))
        error(['Parameter ' varargin{k} ' not recognized.'])
    end
    eval([varargin{k} '=varargin{ ' int2str(k+1) '};'])
end
% test parameters
W=classFun(maxHidden,opt,data);
W.YZiter(data,'vb');
clear W;

% start message
tstart=tic;
uSPTlicense(mfilename)
disp('----------')
disp([ datestr(now) ' : Starting VB greedy model search.'])
if(isempty(data))
    data=spt.preprocess(opt);
    disp(['runinput file: ' opt.runinputfile])
    disp(['input  file  : ' opt.inputfile])
end
disp('----------')
% pre-compute moving average initial guesses
[~,YZmv]=YZShmm.modelSearchFixedSize('classFun',classFun,'N0',1,'opt',opt,'data',data,'iType','vb','YZww',YZww,'displayLevel',0);
qYZ0={qYZ0{:},YZmv{:}};
%% greedy search 
Witer  =cell(1,restart); % save all models generated in each run
Niter  =cell(1,restart); % save all models generated in each run
lnLiter=cell(1,restart); % save all models generated in each run
Piter  =cell(1,restart); % save all models generated in each run
% setup distributed computation toolbox
if(opt.compute.parallelize_config)
    delete(gcp('nocreate'))
    eval(opt.compute.parallel_start)
end
parfor iter=1:restart   
%%%for iter=1:Nrestart %%% debug without parfor
    % Greedy search strategy is probably more efficient than to start over
    % at each model size. We simply start with a large model, and
    % systematically remove the least occupied statate until things start
    % to get worse.
    titer=tic;
    W0=YZShmm.modelSearchFixedSize(classFun,maxHidden,opt,data,'vb',[],1,qYZ0,0); % one random parameter set
    Witer{iter}={};
    [WbestIter,Witer{iter}]=W0.VBgreedyReduce(data,opt,displayLevel-1);
    
    if(displayLevel>=2)
        disp(['Iter ' int2str(iter) '. Finished greedy search in '  num2str(toc(titer)) ' s, with ' int2str(WbestIter.numStates) ' states.'] )
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
for iter=1:restart
    for k=1:length(Witer{iter})
        w=Witer{iter}{k}; % remember: models < handle class
        if(~isempty(w))
            w.sortModel();
            INlnL(end+1,1:3)=[iter w.numStates w.lnL];
            if(isempty(P))
                P=w.getParameters('data',data,'iType','vb');
            else
                P(end+1)=w.getParameters('data',data,'iType','vb');
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
    disp(['Best model size: ' int2str(Wbest.numStates) ', from iteration ' int2str(bestIter) '.'])
end
return
%%% got this far!!!


%% bootstrapping

if(opt.bootstrapNum>0)
bootstrap = VB3_bsResult(opt, 'HMM_analysis');
res.bootstrap=bootstrap;

% save again after bootstrapping
save(opt.outputfile,'-struct','res');
end

% End parallel computing
if(opt.parallelize_config)
    eval(opt.parallel_end)
end

disp([datestr(now) ' : Finished ' opt.runinputfile '. Total run time ' num2str(toc(tstart)/60) ' min.'])
diary off
end


