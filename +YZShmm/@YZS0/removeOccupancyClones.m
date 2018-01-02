function [W,rmStates]=removeOccupancyClones(this,data,opt,iType,dsMaxThreshold)
% [W,rmStates]=YZS0.removeOccupancyClones(this,data,opt,iType,dsMaxThreshold)
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
% iType     : type of iterations to apply ('mle','map','vb')
% dsMaxThreshold : maximum state occpuance difference (for single time
%                  points) that defines occupancy clones: States s1,s2 are
%                  occupancy clones (to be removed) if
%	max(abs(this.S.s(:,s1)-this.S.s(:,s2))) < dsMaxThreshold
%                  default: 1e-10

% ML 2017-12-28

if(~exist('dsMaxThreshold','var') || isempty(dsMaxThreshold))
    dsMaxThreshold=1e-10;
end

rmStates=[];
W=this.clone();
% special case 1: single state model have not occupancy clones
if(this.numStates==1)
   return 
end
warning('Need to implement dS convergence to control dSmax criterion.')

% next, remove occupancy clones, which are assumed to be effectively
% empty states: 
while(W.numStates>1)
    for s0=1:W.numStates
        dsMax=ones(1,W.numStates);
        for s1=1:W.numStates
            dsMax(s1)=max(abs(W.S.pst(:,s1)-W.S.pst(:,s0)));
        end
        i0=find(dsMax<dsMaxThreshold);
        if(numel(i0)==W.numStates)
            warning(['Terminating removeOccupancyClones with only identical states (N=' int2str(W.numStates) ').'])
            return
        end
        if(numel(i0)>1) % then remove all states, including h(1)
            i0=-sort(-i0); % remove highest state numbers first
            for ii=1:numel(i0)
                W=W.removeState(i0(ii),opt);
                rmStates(end+1)=i0(ii);
            end
            W.converge(data,'iType',iType,'displayLevel',0,'PSYwarmup',[-1 -2 0]);
            break
        end
    end
    if(s0==W.numStates) % then no states where removed
        break
    end
    % otherwise, restart the search for occupancy clones
end
%disp(['removed ' int2str(numel(rmStates)) ' from original ' int2str(this.numStates) ' model.'])
end
