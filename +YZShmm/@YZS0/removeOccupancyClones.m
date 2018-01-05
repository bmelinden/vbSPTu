function [W,rmStates]=removeOccupancyClones(this,data,opt,iType,dsMaxThreshold,plotFig)
% [W,rmStates]=YZS0.removeOccupancyClones(this,data,opt,iType,dsMaxThreshold,plotFig)
% iteratively removes all states where the mutual maximum difference in
% hidden state occupancy is below the threshold dsMaxThreshold. The reduced
% model is returned as output, while the original model is unchanged.
% Rationale: the most likely reason why two diffusive states are so similar
% is that they are effectively unoccupied, but the occupancy may still be
% non-zero due to prior distributions and missing data.
%
% W         : new model
% rmStates  : states that were removed
% data      : preprocessed data struct
% opt       : option struct
% iType     : type of iterations to apply ('mle','vb')
% dsMaxThreshold : maximum state occpuance difference (for single time
%                  points) that defines occupancy clones: States s1,s2 are
%                  occupancy clones (to be removed) if
%	max(abs(this.S.s(:,s1)-this.S.s(:,s2))) < dsMaxThreshold
%                  default: this.conv.dsTol
% If set, conv.dsTol is also decreased to dsMaxThreshold if necessary.
% plotFig   : if >0, this triggers visualization of the state clusters in
%             the original model in figure(plotFig). (default=0, no
%             visualization).

% ML 2017-12-28
rmStates=[];
if(~exist('dsMaxThreshold','var') || isempty(dsMaxThreshold))
    dsMaxThreshold=this.conv.dsTol;
else
    this.conv.dsTol=min([dsMaxThreshold this.conv.dsTol opt.conv.dsTol]);
    opt.conv.dsTol=this.conv.dsTol;
    this.converge(data,'iType',iType);
end
if(~exist('display','var'))
    plotFig=0;
end
displayed=false;
W=this.clone();
% special case 1: single state model have not occupancy clones
if(this.numStates==1)
   return 
end

% next, remove occupancy clones, which are assumed to be effectively
% empty states: 
while(W.numStates>1)
    % compute occupancy distances
    dsMax=inf(W.numStates,W.numStates);
    for s0=1:W.numStates
        for s1=[1:s0-1 s0+1:W.numStates]
            dsMax(s0,s1)=max(abs(W.S.pst(:,s1)-W.S.pst(:,s0)));
        end
    end
    % plot state differences on the frist round of iterations
    if(plotFig>0 && ~displayed)
       figure(plotFig) 
       clf
       imagesc(log10(dsMax))
       axis equal
       axis tight
       colorbar
       title('log10( max_{ijt} |p(s_{t}=i) - p(s{t}=j)| )')
       displayed=true;
    end
    % find clone-state cluster containing the smallest distance
    dsMin=min(dsMax(dsMax>-1));
    [r,~]=find(dsMax==dsMin,1);
    i0=union(r,find(dsMax(r,:)<dsMaxThreshold)); % include the r, since dsMax(r,r)=+inf 
    % check for patological case: all states identical
    if(numel(i0)==W.numStates)
        warning(['Terminating removeOccupancyClones with only identical states (N=' int2str(W.numStates) ').'])
        return
    end
    if(numel(i0)>1) % then a cluster was detected, and should be removed
        % remove highest state numbers first, to not screw up numbering
        i0=-sort(-i0); 
        for ii=1:numel(i0)
            W=W.removeState(i0(ii),opt);
            rmStates(end+1)=i0(ii);
        end
        % reconverge and start over
        W.converge(data,'iType',iType,'displayLevel',0,'PSYwarmup',[-1 -2 0]);
        continue
    end
    % if we got this far, no more clone states where removed, and we are
    % done
    break
end
%disp(['removed ' int2str(numel(rmStates)) ' from original ' int2str(this.numStates) ' model.'])
