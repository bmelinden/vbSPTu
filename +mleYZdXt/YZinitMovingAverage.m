function [YZ,Dest]=YZinitMovingAverage(X,wRad,dDtol,tau,R,dt)

tInit=tic;
wWidth=2*wRad-1; % width of moving average (off integer)
W=mleYZdXt.init_P_dat(tau,R,1,dt,1,1,X);
Dest=nan(size(X.x(:,1))); % estimated local diffusion constant

% default guess, to use in place of long missing data stretches
W=mleYZdXt.converge(W,X,'display',0); % backup for stretches of missing data

ff={'muY' 'muZ' 'varY' 'varZ' 'covYtYtp1' 'covYtZt' 'covYtp1Zt'};
for n=1:numel(X.i0)
    ind=W.YZ.i0(n):W.YZ.i1(n);
    Tn =numel(ind)-1;
    
    % init small model for the first stretch
    ix =1:min(wWidth,Tn);
    iyz=1:1+min(wWidth,Tn);    
    % small data set with NaN left in place (hence not using
    % spt.preprocess)
    if(isfield(X,'misc'))
        x0=rmfield(X,'misc');
    else
        x0=X;
    end
    x0.x=X.x(ind(iyz),:);
    x0.v=X.v(ind(iyz),:);
    x0.i0=1;
    x0.i1=ix(end);
    x0.T=x0.i1(end);
    x0.x(end,:)=nan;
    x0.v(end,:)=nan;

    % small model (created from W, in case of too many NaN in x0)
    w=rmfield(W,'EMexit');
    w.lnL=0;
    for nn=1:numel(ff)
        w.YZ.(ff{nn})=W.YZ.(ff{nn})(ind(iyz),:);
    end
    w.YZ.i0=1;
    w.YZ.i1=numel(iyz);
    w.S.pst=W.S.pst(ind(iyz),:);

    if(sum(isfinite(x0.x(:,1)))>1) % then something can meaningfully be estimated
        w=mleYZdXt.converge(w,x0,'display',0,'Nwarmup',1,'lnLrelTol',1e-6);
        for nn=1:numel(ff)
            W.YZ.(ff{nn})(ind(ix),:)=w.YZ.(ff{nn})(ix,:);
        end
        W.YZ.muY( ind(iyz(end)),:)= w.YZ.muY(iyz(end),:);
        W.YZ.varY(ind(iyz(end)),:)=w.YZ.varY(iyz(end),:);

        % local diffusion const
        Dest(ind(iyz))=w.P.lambda/2/w.timestep;
    end
    
    if(Tn>wWidth) % then there is room for a moving average
        % intermediates
        for t=wRad+1:(Tn-wRad)+1 % intermediate points
            %ix =t+(1:wWidth)-wRad;
            iyz =t+(1:wWidth+1)-wRad;
            %x0=spt.preprocess({X.x(ind(ix),:)},{X.v(ind(ix),:)},dim);
            % shift x0 and w0 model by 1
            x0.x=X.x(ind(iyz),:);
            x0.v=X.v(ind(iyz),:);
            x0.x(end,:)=nan;
            x0.v(end,:)=nan;
            
            if(sum(isfinite(x0.x(:,1)))>1) % then something can meaningfully be estimated
                % moving average estimate
                for it=1:100
                    lam0=w.P.lambda;
                    w=mleYZdXt.diffusionPathUpdate(w,x0);
                    w=mleYZdXt.parameterUpdate(w);
                    dDrel=abs(w.P.lambda/lam0-1);
                    if(dDrel<dDtol)
                        break
                    end
                end
                % save estimate from t and onwards
                for nn=1:numel(ff)
                    W.YZ.(ff{nn})(ind(iyz(wRad:wWidth)),:)=w.YZ.(ff{nn})(wRad:wWidth,:);
                end
                W.YZ.muY(ind(iyz(wWidth+1)),:) = w.YZ.muY(wWidth+1,:);
                W.YZ.varY(ind(iyz(wWidth+1)),:)=w.YZ.varY(wWidth+1,:);
                
                Dest(ind(iyz(wRad:wWidth+1)))=w.P.lambda/2/w.timestep;
            end
        end
    end
    %disp(int2str([n numel(X.i0)]))
end
%toc(tInit)
YZ=W.YZ;
