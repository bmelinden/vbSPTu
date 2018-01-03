function H=LOOCV(W0,X,varargin)
% H=YZShmm.LOOCV(W0,X,varargin)
% Estimate predictive performance using leave-one-out cross-validation with
% either point-estimated parameters or variational pseudo-Bayes factors.
% Individual trajectories are used as validation sets, and for each set
% and each model W0{m}, the predictive log-likelihood is computed
% H(i,m) = N/Nv(i)*log(P(xv(i)|xt(i),W0(m)),
% where N,Nv(i) are the number of positions in the total and validation
% data sets, respectively. Thus, H is rescaled to the full data set size.
%
% W0    : YZShmm model or cell vector of models (converged)
% X     : data
% further parameter/value pairs:
% iType : {'mle','vb','vbQ'} sets the type of iterations, as well as the
%         predictive performance measure to estimate. 'mle' gives
%         point-estimate-based cross-validation, while 'vb' and 'vbQ' give
%         estimated pseudo-Bayes factors. For 'vb', the bayes factor is
%         estimated using the difference of lower bounds, while 'vbQ'
%         predicts using the training set variational posterior (less
%         principled, but close to actual predictive practice, and avoids a
%         possible cancellations between large training and full datya
%         sets).
% maxTrj: limit the number of validation sets. Default = number of
%         trajectories. The validation sets are done in random order, so
%         setting maxTrj<number of trajectories is not repeatable.
%         maxTrj>number of trajectories is interpreted as = number of
%         trajectories.
% displayLevel : amount of computational details to write to the command
%                line. 0: none (default). >0: increasingly more

tStart=tic;
displayLevel=0;
maxTrj=numel(X.i0);

% additional input parameters
parNames={'iType','maxTrj','displayLevel'};
for k=1:2:numel(varargin)
    if(isempty(find(strcmp(varargin{k},parNames),1)))
        error(['Parameter ' varargin{k} ' not recognized.'])
    end
    eval([varargin{k} '=varargin{ ' int2str(k+1) '};'])
end
% check partition parameters
maxTrj=min(numel(X.i0),maxTrj); % avoid duplicate validation sets
iType=iType;% dirty fix to make parfor remember iType (is this a parfor bug?).

% put W0 in cell vector if not already 
if(~iscell(W0) )
    if(~iscell(W0))
        Winput=W0;
        W0=cell(size(Winput));
        for k=1:numel(Winput)
            W0{k}=Winput(k);
        end
    end
    clear Winput;
end
% set up Hiter
Hiter=cell(1,maxTrj);

% loop over data partitions
iiLOV=sort(randperm(numel(X.i0),maxTrj)); % validation in random order

parfor iter=1:maxTrj
%%%for iter=1:maxTrj
    Hiter{iter}=zeros(1,numel(W0));
    % partition data set and models
    iiVal=iiLOV(iter);
    % loop over models
    dispL=displayLevel-2;
    for m=1:numel(W0)
        if(~isa(W0{m},'YZShmm.YZS0'))
            Hiter{iter}(m)=-inf;
        else
            [Wv,Xv,Wt,Xt]=W0{m}.splitModelAndData(X,iiVal);
            Tt=sum(Xt.T); % positions in training set
            Tv=sum(Xv.T); % positions in validation set
            % computed H
            switch lower(iType)
                case 'mle'
                    % converge training set. Since q(S) and q(Y,Z) is
                    % taken from the full model, start with parameter update
                    Wt.converge(Xt,'iType','mle','PSYwarmup',[-1 0 0],'displayLevel',dispL);
                    % transfer training parameters
                    Wv.P=Wt.P;
                    % converge validation set with fixed parameters
                    Wv.converge(Xv,'iType','mle','PSYfixed',1,'displayLevel',dispL);
                    Hiter{iter}(m)=(Tt+Tv)/Tv*Wv.lnL;
                case 'vb'
                    % converge training and full set. Since q(S) and q(Y,Z) is
                    % taken from the full model, start with parameter update
                    Wt.converge(Xt,'iType','vb','PSYwarmup',[-1 0 0],'displayLevel',dispL);
                    W0{m}.converge(X,'iType','vb','PSYwarmup',[0 0 0],'displayLevel',dispL,'miniter',2);
                    % validation score as lower bound difference
                    Hiter{iter}(m)=(Tt+Tv)/Tv*(W0{m}.lnL-Wt.lnL);
                case 'vbq'
                    % converge training set
                    Wt.converge(Xt,'iType','vb','PSYwarmup',[-1 0 0],'displayLevel',dispL);
                    % parameter posterior -> validation prior
                    Wv.P0=Wt.P;
                    Wv.converge(Xv,'iType','vb','PSYwarmup',[-1 0 0 ],'displayLevel',dispL);
                    % validation score as lower bound difference
                    Hiter{iter}(m)=(Tt+Tv)/Tv*Wv.lnL;
            end
        end
    end
    if(displayLevel>1)
        disp(['Finished round ' int2str(iter) ' of ' iType '-LOOCV.'])
    end
end
% read off Hiter entries
for iter=1:maxTrj
    for m=1:numel(W0)
        H(iter,m)=Hiter{iter}(m);
    end
end
if(displayLevel>=1)
    HH=H-max(H,[],2)*ones(1,size(H,2)); % subtract off correlated variance
    [~,Nmax]=max(mean(HH,1));
    disp([datestr(now) ' : ' iType ' LOOCV ended with ' int2str(Nmax) ...
        ' states. Total run time ' num2str(toc(tStart)/60,2) ' min.'])
end
