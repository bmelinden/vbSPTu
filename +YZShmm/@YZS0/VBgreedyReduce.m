function [Wbest,WNbest,lnLsearch,Nsearch,Psearch]=VBgreedyReduce(this,dat,opt,display)
% [Wbest,WNbest,lnLsearch,Nsearch,Wsearch]=VBgreedyReduce(this,dat,opt,display)
% Perform a greedy search for smaller models with larger VB evidence by
% systematically pruning the states of the starting class. 

if(~exist('display','var'))
    display=0;
end
if(~exist('dat','var') || isempty(dat))
    dat=spt.preprocess(opt);
end
% start by VB-converging the start model
titer=tic;
Wbest=this.clone(); % this will be the currently best model
Wbest.converge(dat,'iType','vb','display',0);

WNbest={};
WNbest{Wbest.numStates}=Wbest.clone();
%% greedy search
% search log
lnLsearch=Wbest.lnL;
Nsearch  =Wbest.numStates;
Psearch  =Wbest.getParameters('iType','vb','data',dat); % log search parameters
while(true) % try successive removal of low-occupancy states
    improved=false;
    [~,h]=sort(Wbest.getParameters('iType','vb','data',dat).pOcc);
    % to two prune states in order of increasing occupancy
    for k=1:length(h)
        % try to remove states, if more than one state exists
        if(Wbest.numStates>1)
            Wtmp=Wbest.removeState(h(k),opt);
            Wtmp.Siter(dat,'vb');
            Wtmp.Piter(dat,'vb');
            
            % attempt 1: just remove a state and converge
            Wtmp.converge(dat,'iType','vb','display',display,...
                'SYPwarmup',[0 0 0],...
                'maxIter',opt.conv.maxIter,'lnLTol',opt.conv.lnLTol,'parTol',opt.conv.parTol);
            Wtmp.sortModel();
            lnLsearch(end+1)=Wtmp.lnL;
            Nsearch(end+1)  =Wtmp.numStates;
            Psearch(end+1)  =Wtmp.getParameters('iType','vb','data',dat); % log search parameters
            % keep track of best model at each visited size
            if(isempty(WNbest{Wtmp.numStates}) || Wtmp.lnL > WNbest{Wtmp.numStates}.lnL)
                WNbest{Wtmp.numStates}=Wtmp.clone();
            end
            if(Wtmp.lnL>Wbest.lnL) % then this helped, and we should go on
                improved=true;
                if(display>1)
                    fprintf('Removing state %d of %d helped, dlnL/|lnL| = %.2e.\n', ...
                        h(k),Wbest.numStates,Wtmp.modelDiff(Wbest));
                end
                Wbest=Wtmp.clone();
                break % start over and try to improve the new Wbest
            else
                if(display>1)
                    fprintf('Removing state %d of %d did not help, dlnL/|lnL| = %.2e.\n', ...
                        h(k),Wbest.numStates,Wtmp.modelDiff(Wbest));
                end
            end
            
            % if this did not help, try again some other stuff that only
            % makes sense if reduced model has >1 state
            if(Wbest.numStates>2) % this only makes sense if reduced models have >1 state
                % add some extra transitions
                tx0=tic;
                Wtmp=Wbest.removeState(h(k),opt);
                % interpolate transition parameters close to the prior
                nwa0=sum(Wtmp.P0.wa(:));
                nwa =sum(Wtmp.P.wa(:) )-nwa0;
                nwB0=sum(Wtmp.P0.wB(:));
                nwB =sum(Wtmp.P.wB(:) )-nwB0;
                Wtmp.P.wa=(1+0.1*nwa/nwa0)*Wtmp.P0.wa+0.9*Wtmp.P.wa;
                Wtmp.P.wB=(1+0.1*nwB/nwB0)*Wtmp.P0.wB+0.9*Wtmp.P.wB;
                Wtmp.Piter(dat,'vb');
                Wtmp.Siter(dat,'vb');
                
                Wtmp.converge(dat,'iType','vb','display',display,...
                    'SYPwarmup',[0 0 0],...
                    'maxIter',opt.conv.maxIter,'lnLTol',opt.conv.lnLTol,'parTol',opt.conv.parTol);
                
                Wtmp.sortModel();
                lnLsearch(end+1)=Wtmp.lnL;
                Nsearch(end+1)  =Wtmp.numStates;
                Psearch(end+1)  =Wtmp.getParameters('iType','vb','data',dat); % log search parameters
                % keep track of best model at each visited size
                if(isempty(WNbest{Wtmp.numStates}) || Wtmp.lnL > WNbest{Wtmp.numStates}.lnL)
                    WNbest{Wtmp.numStates}=Wtmp.clone();
                end
                if(Wtmp.lnL>Wbest.lnL)
                    if(display>1)
                        fprintf('Removing state %d of %d w trans. interpolation helped, dlnL/|lnL| = %.2e, t = %.1f s.\n', ...
                            h(k),Wbest.numStates,Wtmp.modelDiff(Wbest),toc(tx0));
                    end
                    Wbest=Wtmp.clone();
                    improved=true;
                    break % go on to try an dimprove the new model instead
                else
                    if(display>1)
                        fprintf('Removing state %d of %d w trans. interpolation did not help, dlnL/|lnL| = %.2e, t = %.1f s.\n', ...
                            h(k),Wbest.numStates,Wtmp.modelDiff(Wbest),toc(tx0));
                    end
                end
            end
        end
    end
    % if we get this far withouth improvement, we are done
    if(~improved)
        break
    end
end
if(display>0)
    fprintf('VBgreedyReduce finished: %d -> %d states.\n',this.numStates,Wbest.numStates);
end
