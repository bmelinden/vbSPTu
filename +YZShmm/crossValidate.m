function H=crossValidate(W0,X,varargin)
% H=YZShmm.crossValidate(W0,X,varargin)
% Estimate predictive performance using point-estiamted crossvalidation or
% variational pseudo-Bayes factors. In particular, a set of validation and
% training data sets xv(i),xt(i), i=1,...,K is generated, and for each set
% and each model W0{m}, the predictive log-likelihood is computed
% H(i,m) = N/Nv(i)*log(P(xv(i)|xt(i),W0(m)),
% where N,Nv(i) are the number of positions in the total and validation
% data sets, respectively. Thus, H is rescaled to the full data set size.
%
% W0    : YZShmm model or cell vector of models (converged)
% X     : data
% further parameter/value pairs:
% iType : {'mle','map','vb','vbQ'} sets the type of iterations, as well as the
%         predictive performance measure to estimate. {'mle','map'} gives
%         point-estimate-based cross-validation, while 'vb' and 'vbQ' give
%         estimated pseudo-Bayes factors. For 'vb', the bayes factor is
%         estimated using the difference of lower bounds, while 'vbQ'
%         predicts using the training set variational posterior (less
%         principled, but close to actual predictive practice, and avoids a
%         possible cancellations between large training and full datya
%         sets).
%         We recommend 'vbQ' as a robust default choice.
% numTrj/numPos/fracPos : size of validation data set. numTrj specifies the
%         number of trajectories to include, numPos specifies the number of
%         positions (including missing positions) to include, and numFrac
%         specifies the fraction of positions (including missing data) to
%         include. The validation sets are always in whoel trajectories.
%         For numPos/fracPos, trajectories are drawn without replacement
%         until the validation set size is >= than the specification.
% restarts  : number of performance estimates to perform, each one using
%             randomly selected validation data sets, to evaluate. Default:
%             number of trajectories.
% displayLevel : amount of computational details to write to the command
%                line. 0: none (default). >0: increasingly more

tStart=tic;
displayLevel=0;
restarts=numel(X.i0);

% additional input parameters
parNames={'iType','numTrj','numPos','fracPos','displayLevel','restarts'};
for k=1:2:numel(varargin)
    if(isempty(find(strcmp(varargin{k},parNames),1)))
        error(['Parameter ' varargin{k} ' not recognized.'])
    end
    eval([varargin{k} '=varargin{ ' int2str(k+1) '};'])
end
% check partition parameters
if( exist('numTrj','var') && ~exist('numPos','var') && ~exist('fracPos','var'))
    numTrj=numTrj;numPos=[];fracPos=[];
    if(numTrj<1 || numTrj>=numel(X.T))
        error('Need 1 <= numTrj < number of trajectories.')
    end
elseif( ~exist('numTrj','var') && exist('numPos','var') && ~exist('fracPos','var'))
    doNumTrj=false;
    numTrj=[];numPos=numPos;fracPos=[];
    if( numPos <1 || numPos > sum(X.T)-max(X.T))
       error('Need 1 <= numPos <= total number of positions < max(trjLength).') 
    end
    elseif( ~exist('numTrj','var') && ~exist('numPos','var') && exist('fracPos','var'))
    doNumTrj=false;
    numTrj=[];numPos=[];fracPos=fracPos;
    if( fracPos <=0 || fracPos >= 1)
       error('Need 0 < fracPos < 1.') 
    end
else
    error('Must have one (and only one) of numTrj/numPos/fracPos.')
end

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
Hiter=cell(1,restarts);
% dirty fix to make parfor remember iType (is this a parfor bug?).
iType=iType;
% loop over data partitions
parfor iter=1:restarts
%%%for iter=1:restarts
    Hiter{iter}=zeros(1,numel(W0));
    iiVal=[];
    % partition data set and models
    if(~isempty(numTrj))
        iiVal=randperm(numel(X.i0),numTrj);
    elseif(~isempty(numPos))
        iiVal= randperm(numel(X.i0));
        Tii=cumsum(X.T(iiVal));
        iiVal=iiVal(1:find(Tii>=numPos,1));
    elseif(~isempty(fracPos))
        iiVal= randperm(numel(X.i0));
        Tii=cumsum(X.T(iiVal));
        iiVal=iiVal(1:find( Tii/Tii(end)>=fracPos,1));        
    else
        error('Size of validation set (numTrj/numPos/fracPos) not specified.')
    end
    if(isempty(iiVal))
        error(['Empty validation set in iteration ' int2str(iter)]);
    end
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
                case 'map'
                    % converge training set. Since q(S) and q(Y,Z) is
                    % taken from the full model, start with parameter update
                    Wt.converge(Xt,'iType','map','PSYwarmup',[-1 0 0],'displayLevel',dispL);
                    % transfer training parameters
                    Wv.P=Wt.P;
                    % converge validation set with fixed parameters
                    Wv.converge(Xv,'iType','map','PSYfixed',1,'displayLevel',dispL);
                    % sum up log-prior terms
                    lnP0=0;
                    pn=fieldnames(Wv.P.lnP0);
                    for k=1:numel(pn)
                        lnP0=lnP0+sum(Wv.P.lnP0.(pn{k}));
                    end
                    Hiter{iter}(m)=(Tt+Tv)/Tv*(Wv.lnL-lnP0);
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
        disp(['Finished round ' int2str(iter) ' of ' iType '-crossvalidation.'])
    end
end
% read off Hiter entries
for iter=1:restarts
    for m=1:numel(W0)
        H(iter,m)=Hiter{iter}(m);
    end
end
if(displayLevel>=1)
    HH=H-max(H,[],2)*ones(1,size(H,2)); % subtract off correlated variance
    [~,Nmax]=max(mean(HH,1));
    disp([datestr(now) ' : ' iType ' crossvalidation ended with ' int2str(Nmax) ...
        ' states. Total run time ' num2str(toc(tStart)/60,2) ' min.'])
end
