function [lnLsearch,Nsearch,Psearch]=VBgreedyReduce(this,dat,opt,displayLevel)
% [lnLsearch,Nsearch,Wsearch]=VBgreedyReduce(this,dat,opt,displayLevel)

if(~exist('displayLevel','var'))
    displayLevel=0;
end
saveWsearch=false;
if(nargout>=3)
    saveWsearch=true;
end

% start by VB-converging the start model
titer=tic;
this.converge(dat,'iType','vb','display',0);

%% greedy search
% search log
lnLsearch=this.lnL;
Nsearch=this.numStates;
Psearch=this.P;

while(true) % try successive removal of low-occupancy states
    improved=false;
    [~,h]=sort(this.getParameters('vb').pOcc); % prune states in order of increasing occupancy
    for k=1:length(h)
        % try to remove states, if more than one state exists
        if(this.numStates>1)
            wTMP=this.clone();
            wTMP.removeState(h(k));
            %%% got this far!!!
            
            
            
            
            
            wTMP.VBconverge(dat,'displayLevel',displayLevel,'maxIter',opt.maxIter,'relTolF',opt.relTolF,'tolPar',opt.tolPar);
            wTMP.sortModel();
            Psearch(end+1)=wTMP.copy();Psearch(end).compress();

            if(wTMP.F>w0.F) % then this helped, and we should go on
                w0=wTMP.copy;
                improved=true;
                break % start over and try to improve the new w0
            end
            
            % if this did not help, try again with some added transitions
            if(w0.numStates>2) % this only makes sense if reduced models have >1 state
                tx0=tic;
                wTMP=w0.copy();
                wTMP.removeState(h(k));
                od=ceil(max(max(max(wTMP.P.wB-wTMP.P0.wB)),1e-2/(wTMP.numStates-1)*sum(wTMP.S.wA(:))));
                wTMP.P.wB=wTMP.P.wB+od*(1-eye(wTMP.numStates));
                wa=[sum(wTMP.P.wB,2) diag(wTMP.S.wA)];
                wTMP.P.wa=wTMP.P0.wa+wa;
                wTMP.Siter();
                wTMP.YZiter(dat);
                wTMP.VBconverge(dat,'displayLevel',displayLevel,'maxIter',opt.maxIter,'relTolF',opt.relTolF,'tolPar',opt.tolPar);
                wTMP.sortModel();
                Psearch(end+1)=wTMP.copy();Psearch(end).compress();
                if(wTMP.F>w0.F)
                    fprintf('Adding  %d extra transitions to %d-state model helped, dF/|F| = %.2e, t = %.1f s.\n', ...
                        od,wTMP.numStates, (wTMP.F-w0.F)/abs(wTMP.F),toc(tx0));
                    w0=wTMP.copy();
                    improved=true;
                    break % go on to try an dimprove the new model instead
                end
            end
        end
    end
    % if we get this far withouth improvement, we are done
    if(~improved)
        break
    end
end
lnLsearch=zeros(1,numel(Psearch));
Nsearch=zeros(1,numel(Psearch));
for ii=1:numel(Psearch)
   lnLsearch(ii)=Psearch(ii).F; 
   Nsearch(ii)=Psearch(ii).numStates;
end

%disp(['greedyReduction finished search in '  num2str(toc(titer)) ' s, with ' int2str(this.numStates) ' states.'] )

