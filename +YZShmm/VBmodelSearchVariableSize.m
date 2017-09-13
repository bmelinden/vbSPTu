function [Wbest,WbestN,dlnL,INlnL,P,YZmv]=VBmodelSearchVariableSize(opt,X,YZ0,displayLevel)
%
% classFun : YZhmm model constructor handle (e.g. @YZShmm.dXt)
% opt   : options struct or runinputfile name
% --- optional ---
% X     : data struct from spt.preprocess (default: read from opt)
% YZ0   : precomputed q(Y,Z) distribution(s) to include as initial guesses,
%         either as a single YZ subfield, or as a cell vector of YZ
%         subfields. Default {} (no pre-computed YZ distributions used). 
% displayLevel : display level, ~as for vbYZdXt.converge, default 0.
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
% YZmv      : moving averages YZ structs (to make it possible to reuse
%             them). 

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VB3_HMManalysis, runs data analysis in the vbSPT package
% =========================================================================
% 
% Copyright (C) 2013 Martin Lindén and Fredrik Persson
% 
% E-mail: bmelinden@gmail.com, freddie.persson@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or any later
% version.   
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
%  Additional permission under GNU GPL version 3 section 7
%  
%  If you modify this Program, or any covered work, by linking or combining it
%  with Matlab or any Matlab toolbox, the licensors of this Program grant you 
%  additional permission to convey the resulting work.
%
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <http://www.gnu.org/licenses/>.
%% start of actual code
tstart=tic;
opt=spt.getOptions(opt); % convert runinput file to opt struct if necessary
uSPTlicense(mfilename)
disp('----------')
disp([ datestr(now) ' : Starting VB greedy model search to find best model.'])
%disp(['runinput file: ' opt.runinputfile])
%disp(['input  file  : ' opt.inputfile])
%disp(['trj field    : ' opt.trajectoryfield])
disp('----------')
%% interpret analysis parameters
maxHidden  =opt.modelSearch.maxHidden;
YZww=opt.modelSearch.YZww;
Pwu =opt.modelSearch.Pwarmup;
Nrestart=opt.modelSearch.restarts;
classFun=opt.model;

if(~exist('X','var') || isempty(X))
    X=spt.preprocess(opt);
    opt.trj.inputfile='n.a.'
end
if(~exist('YZ0','var') || isempty(YZ0))
    YZ0={};
end
if(~exist('displayLevel','var') || isempty(displayLevel))
    displayLevel=0;
end
% test non-opptional parameters
W=classFun(maxHidden,opt,X);
W.YZiter(X,'vb');
clear W;
% pre-compute moving average initial guesses
[~,~,~,~,~,YZmv]=YZShmm.modelSearchFixedSize(classFun,1,opt,X,'vb',YZww,0, {},0);
YZ0={YZ0{:},YZmv{:}};
%% greedy search 
Witer  =cell(1,Nrestart); % save all models generated in each run
Niter  =cell(1,Nrestart); % save all models generated in each run
lnLiter=cell(1,Nrestart); % save all models generated in each run
Piter  =cell(1,Nrestart); % save all models generated in each run
% setup distributed computation toolbox
if(opt.compute.parallelize_config)
    delete(gcp('nocreate'))
    eval(opt.compute.parallel_start)
end
parfor iter=1:Nrestart   
%%%for iter=1:Nrestart %%% debug without parfor
    % Greedy search strategy is probably more efficient than to start over
    % at each model size. We simply start with a large model, and
    % systematically remove the least occupied statate until things start
    % to get worse.
    titer=tic;
    [W0,~]=YZShmm.modelSearchFixedSize(classFun,maxHidden,opt,X,'vb',[],1,YZ0,0); % one random parameter set
    Witer{iter}={};
    [WbestIter,Witer{iter},lnLiter{iter},Niter{iter},Piter{iter}]=W0.VBgreedyReduce(X,opt,displayLevel-1);
    
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
for iter=1:Nrestart
    for k=1:length(Witer{iter})
        w=Witer{iter}{k}; % remember: models < handle class
        if(~isempty(w))
            w.sortModel();
            INlnL(end+1,1:3)=[iter w.numStates w.lnL];
            if(isempty(P))
                P=w.getParameters('data',X,'iType','vb');
            else
                P(end+1)=w.getParameters('data',X,'iType','vb');
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


