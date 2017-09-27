function multiConverge_Dcomm(W,X,iType,Dcomm)
% multiConverge(W,X,iType,Dcomm)
% Simultaneously converge a set of models while enforcing common values for
% some of their diffusion constants.
% 
% W     : cell vector of YZShmm models
% X     : cell vector of corresponding data sets
% iType : type of iterations, {'mle','map','vb'}
% Dcomm : defining the set of common diffusion constants, with each row
% defining the shared constants of each model. Example
% Dcomm =[1 2; 2 3; 1 3] defines two D-const. common to three models. Group
% one (column one) consists of states 1,2,and 1 in models 1,2, and
% 3,respectively, while group 2 consists of states 2,3, and 3.
% 
% optional parameters: 'parameter1', value1,... TBA

disp('-')
maxIter=1000;
minIter=3;
lnLTol=1e-9;
parTol=1e-3;
converged_lnL=0;
converged_par=0;
NMX=numel(W);

% minimal models for convergence reference
for k=1:NMX
    W0(k)=struct('P',W(k).P,'lnL',W(k).lnL,'numStates',W(k).numStates);
end


for ii=1:maxIter
    % save reference values
    for k=1:NMX
        W0(k).P=W(k).P;
        W0(k).lnL=W(k).lnL;
    end
    
    % common 
    c=zeros(size(Dcomm));
    n=zeros(size(Dcomm));
    lnL0=[W(:).lnL];
    for k=1:NMX
       W(k).YZiter(X(k),iType);        
       W(k).Piter(X(k) ,iType); 
    end
    
    % extract statistics for the common diffusion constants
    for k=1:NMX
        switch lower(iType)
            case 'mle'
                n(k,:)=W(k).P.n(Dcomm(k,:));
                c(k,:)=W(k).P.c(Dcomm(k,:));
            case 'map'
                % only share counts from the data
                n(k,:)=W(k).P.n(Dcomm(k,:))-W(k).P0.n(Dcomm(k,:));
                c(k,:)=W(k).P.c(Dcomm(k,:))-W(k).P0.c(Dcomm(k,:));
                if(k>1) % do not double-count log-prior terms
                    W(k).P.lnP0.lambda(Dcomm)=0;
                end                
            case 'vb'
                % only share counts from the data
                n(k,:)=W(k).P.n(Dcomm(k,:))-W(k).P0.n(Dcomm(k,:));
                c(k,:)=W(k).P.c(Dcomm(k,:))-W(k).P0.c(Dcomm(k,:));
                if(k>1) % do not double-count KL terms
                    W(k).P.KL.lambda(Dcomm)=0;
                end
        end
    end
    % pool the statistics back again, and perform hidden state 
    for k=1:NMX        
       switch lower(iType)
           case 'mle'
               W(k).P.n(Dcomm(k,:))=sum(n,1);
               W(k).P.c(Dcomm(k,:))=sum(c,1);
           case {'map','vb'}
               W(k).P.n(Dcomm(k,:))=W(k).P0.n(Dcomm(k,:))+sum(n,1);%
               W(k).P.c(Dcomm(k,:))=W(k).P0.c(Dcomm(k,:))+sum(c,1);%;
       end
    end
    for k=1:NMX
        W(k).Siter(X(k) ,iType);
    end
    % test for convergence
    lnL1=[W(:).lnL];
    dlnL_k=(lnL1-lnL0)*2./abs(lnL1+lnL0);
    dlnLrel=sum((lnL1-lnL0))*2./abs(sum(lnL1+lnL0));
            
    if(abs(dlnLrel)<lnLTol)
        converged_lnL=converged_lnL+1;
    else
        converged_lnL=0;
    end
    for k=1:NMX 
        [~,dPmax(k),dPmaxName{k}]=W(k).modelDiff(W0(k));        
    end
    [~,pm]=max(dPmax);  
    if(dPmax<parTol)
        converged_par=converged_par+1;
    else
        converged_par=0;
    end
    
    fprintf('dlnL = %8.2e, dP = %8.2e (%s %d)\n',dlnLrel,dPmax(pm),dPmaxName{pm},pm)

    
    if(ii>=minIter && converged_lnL>=3 && converged_par>=3)        
        break
    end
end
