function [Wbest,WNbest,lnLsearch,Nsearch,Psearch]=greedyReduce(this,data,opt,displayLevel,iType)
% [Wbest,WNbest,lnLsearch,Nsearch,Psearch]=greedyReduce(this,dat,opt,displayLevel,iType)
% Perform a greedy search for smaller models by systematically 
% 1) removing 'clone states' with equal hidden state occupancies (
% 2) pruning the remaining states one by one using a greedy width-first
% search on each model size. (I.e., for every model size N, the best model
% of size N-1 is used as an input for the next round of pruning).
% The search only involves comparisons of models of equal size, and hence
% should work for VB and MLE iterations. (However, VB iterations are both
% faster and numerically more robust).
%
% dat   : preprocessed data struct. If empty, data is generated using
%         information in the options struct opt.
% opt	: options struct. This is used to 1) generate data if needed, and
%         2) to generate priors in the new, smaller, models.
% displayLevel : amount of logging information to display (default 1).
% iType : type of iterations ('vb' or 'mle'). Default: 'vb'
%
% Wbest     : best model found in the greedy search
% WNbest    : best model of each size found in the greedy search
% lnLsearch : lnL for each model in the search (including suboptimal ones)
% Nsearch   : size of each model in the search 
% Psearch   : Parameter estimate struct for each nmodel in the search

% VBgreedyReduce2 : greedy search that considers all state-removals for
% each model size, and reduces models all the way down to N=1 states.
% greedyReduce : quickly remove least-occupied state if it seems to be
% effectively unoccupied, based on comparing hidden state occupancies with
% other states.
% greedyReduce : a more comprehensive removal on effectively unoccupied
% states, by looking for clusters with identical hidden state occupancy.
% 2018-01-02: renamve to greedyReduce

if(~exist('displayLevel','var'))
    displayLevel=1;
end
if(~exist('data','var') || isempty(data))
    data=spt.preprocess(opt);
end
if(~exist('iType','var') || isempty(data))
    iType='vb';
end
dsMaxThreshold=1e-10; % log-occupancy differences below this will be considered insignidicant

% start by converging the start model
Wcurr=this.clone(); % this will be the currently best model
Wcurr.converge(data,'iType',iType,'displayLevel',0);
n0=Wcurr.numStates;
[Wcurr,sClones]=Wcurr.removeOccupancyClones(data,opt,iType,dsMaxThreshold);
if(displayLevel>1 && ~isempty(sClones))
    fprintf('Removed %d unoccupied states from initial %d-state model.\n',numel(sClones),n0)
end

% set up output, starting with the largest model without state clones
lnLbest=-inf(1,Wcurr.numStates); % overall best log likelihood
WNbest=cell(1,Wcurr.numStates);
WNbest{Wcurr.numStates}=Wcurr.clone();
lnLbest(Wcurr.numStates)=Wcurr.lnL;
%% greedy search
% search log
lnLsearch=Wcurr.lnL;
Nsearch  =Wcurr.numStates;
Psearch  =Wcurr.getParameters(data,iType); % log search parameters
rmSearch=nan;
% models in play:
% Wcurr: the current model, which we are trying to reduce
% Wtmp : current candidate model under investigation
% Wnext: best model (so far) of size Wcurr-1
Wnext=Wcurr;
while(Wnext.numStates>1) % successive search down to 1-state model
    Wcurr=Wnext.clone(); % update reference model for this iteration  
    [~,h]=sort(Wcurr.getParameters(data,iType).pOcc);
    % then search for the best model with one less state
    Wnext=[];
    lastRemoved=nan;    
    % try to prune states in order of increasing occupancy: this should be
    % OK, since we have removed 
    for k=1:length(h)
        Wtmp=Wcurr.removeState(h(k),opt);
        % attempt 1: just remove a state and converge
        try
            % do hidden states and parameters first after state removal
            Wtmp.Siter(data,iType);
            Wtmp.Piter(data,iType);            
            Wtmp.converge(data,'iType',iType,'displayLevel',displayLevel-2,...
                'maxIter',opt.conv.maxIter,'lnLTol',opt.conv.lnLTol,'parTol',opt.conv.parTol);
            Wtmp.sortModel();
        catch me
            if(opt.conv.saveErr)
                errFile=['greedyReduce_err' int2str(ceil(1e9*rand)) '.mat'];
                save(errFile)
                error(['greedyReduce encountered an error. Saving workspace to ' errFile])
            else
                error('greedyReduce encountered an error. Set opt.conv.saveErr=true to save workspace to file.')
            end
        end
        
        % save first converged model of this size
        if(isempty(Wnext))
            Wnext=Wtmp.clone();
            lastRemoved=h(k);
            if(displayLevel>1 && ~isempty(Wnext))
                fprintf('    Start N=%3d                      : removing state %d (%9.1e steps) of %d.\n', ...
                    Wcurr.numStates,h(k),sum(Wcurr.S.pst(:,h(k))),Wcurr.numStates);
            end
        elseif(Wtmp.lnL>Wnext.lnL) % keep track of best reduced model (Wnext)
            if(displayLevel>1 && ~isempty(Wnext))
                fprintf('    Improved, dlnL/|lnL| = %10.2e: removing state %d (%9.1e steps) of %d.\n', ...
                    Wtmp.modelDiff(Wnext),h(k),sum(Wcurr.S.pst(:,h(k))),Wcurr.numStates);
            end
            Wnext=Wtmp.clone();
            lastRemoved=h(k);
        elseif(displayLevel>1)
            fprintf('Not improved, dlnL/|lnL| = %10.2e: removing state %d (%9.1e steps) of %d.\n', ...
                Wtmp.modelDiff(Wnext),h(k),sum(Wcurr.S.pst(:,h(k))),Wcurr.numStates);
        end
        % attempt 2: reconverge with some added transition counts
        % add some extra transitions
        Wtmp=Wcurr.removeState(h(k),opt);
        try
            if(Wtmp.numStates>1)
                Wtmp.Siter(data,iType);
                Wtmp.Piter(data,iType);
                % interpolate transition parameters closer to the prior
                nwa0=sum(Wtmp.P0.wa(:));
                nwa =sum(Wtmp.P.wa(:) )-nwa0;
                nwB0=sum(Wtmp.P0.wB(:));
                nwB =sum(Wtmp.P.wB(:) )-nwB0;
                Wtmp.P.wa=(1+0.1*nwa/nwa0)*Wtmp.P0.wa+0.9*Wtmp.P.wa;
                Wtmp.P.wB=(1+0.1*nwB/nwB0)*Wtmp.P0.wB+0.9*Wtmp.P.wB;
                
                % propagate the manipulated parameters before converging
                Wtmp.Siter(data,iType);
                Wtmp.YZiter(data,iType);
            end
            Wtmp.converge(data,'iType',iType,'displayLevel',displayLevel-2,...
                'maxIter',opt.conv.maxIter,'lnLTol',opt.conv.lnLTol,'parTol',opt.conv.parTol);
            Wtmp.sortModel();
        catch me
            if(opt.conv.saveErr)
                errFile=['greedyReduce_err' int2str(ceil(1e9*rand)) '.mat'];
                save(errFile)
                error(['greedyReduce encountered an error. Saving workspace to ' errFile])
            else
                error('greedyReduce encountered an error. Set opt.conv.saveErr=true to save workspace to file.')
            end
        end
        
        if(Wtmp.lnL>Wnext.lnL)
            if(displayLevel>1)% && ~isempty(Wnext)
                fprintf('    Improved, dlnL/|lnL| = %10.2e: removing state %d (%9.1e steps) of %d, +trans.counts.\n', ...
                    Wtmp.modelDiff(Wnext),h(k),sum(Wcurr.S.pst(:,h(k))),Wcurr.numStates);
            end
            Wnext=Wtmp.clone();
            lastRemoved=h(k);
        elseif(displayLevel>1)
            fprintf('Not improved, dlnL/|lnL| = %10.2e: removing state %d (%9.1e steps) of %d, +trans.counts .\n', ...
                Wtmp.modelDiff(Wnext),h(k),sum(Wcurr.S.pst(:,h(k))),Wcurr.numStates);
        end
    end
    % remove occupancy clones again, in case they turn up during the
    % pruning process 
    n0=Wnext.numStates;
    [Wnext,sClones]=Wnext.removeOccupancyClones(data,opt,iType,dsMaxThreshold);
    if(displayLevel>1 && ~isempty(sClones))
        fprintf('Removed %d unoccupied states from final %d-state model.\n',numel(sClones),n0)
    end

    % keep track of best model at each visited size
    if(isempty(WNbest{Wnext.numStates}) || Wnext.lnL > WNbest{Wnext.numStates}.lnL)
        WNbest{Wnext.numStates}=Wnext.clone();
        lnLbest(Wnext.numStates)=Wnext.lnL;
    end
    
    % save iteration history for best model of each size
    lnLsearch(end+1)=Wnext.lnL;
    Nsearch(end+1)  =Wnext.numStates;
    Psearch(end+1)  =Wnext.getParameters(data,iType); % log search parameters
    rmSearch(end+1)=lastRemoved;
end

% choose model with highes log likelihood
[~,b]=max(lnLbest);
Wbest=WNbest{b}.clone();

if(displayLevel>0)
    fprintf('greedyReduce finished: %d -> %d states.\n',this.numStates,Wbest.numStates);
end
