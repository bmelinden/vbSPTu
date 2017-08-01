function [YZ,Dest]=YZinitMovingAverage(X,wRad,dDtol,tau,R,dt)

tInit=tic;
wWidth=2*wRad-1; % width of moving average (off integer)
W=mleYZdXt.init_P_dat(tau,R,1,dt,1,1,X);
Dest=zeros(size(X.x(:,1))); % estimated local diffusion constant
ff={'muY' 'muZ' 'varY' 'varZ' 'covYtYtp1' 'covYtZt' 'covYtp1Zt'};
for n=1:numel(X.i0)
   ind=W.YZ.i0(n):W.YZ.i1(n);
   Tn =numel(ind)-1;
   
   % first stretch
   ix=1:min(wWidth,Tn);
   iyz=1:1+min(wWidth,Tn);
   % small data set with NaN left in place
   x0=rmfield(X,'misc');   
   x0.x=X.x(ind(iyz),:);
   x0.v=X.v(ind(iyz),:);
   x0.i0=1;
   x0.i1=ix(end);
   x0.T=x0.i1(end);
   w0=mleYZdXt.init_P_dat(tau,R,1e6,dt,1,1,x0);
   w0=mleYZdXt.converge(w0,x0,'display',0,'Nwarmup',1,'lnLrelTol',1e-6);    
   for nn=1:numel(ff)
       W.YZ.(ff{nn})(ind(iyz),:)=w0.YZ.(ff{nn})(iyz,:);
   end
   % local diffusion const
   Dest(ind(iyz))=w0.P.lambda/2/w0.timestep;
   
   if(Tn>wWidth) % then there is room for a moving average
       % intermediates
       for t=wRad+1:(Tn-wRad) % intermediate points
           ix =t+(1:wWidth)-wRad;
           iyz =t+(1:wWidth+1)-wRad;
           %x0=spt.preprocess({X.x(ind(ix),:)},{X.v(ind(ix),:)},dim);
           % shift x0 and w0 model by 1
           x0.x=X.x(ind(iyz),:);
           x0.v=X.v(ind(iyz),:);
           % moving average estimate
           for it=1:100
               lam0=w0.P.lambda;
               w0=mleYZdXt.diffusionPathUpdate(w0,x0);
               w0=mleYZdXt.parameterUpdate(w0);
               dDrel=abs(w0.P.lambda/lam0-1);
               if(dDrel<dDtol)
                   break
               end
           end
           % save estimate from t and onwards
           for nn=1:numel(ff)
               W.YZ.(ff{nn})(ind(iyz(wRad:wWidth+1)),:)=w0.YZ.(ff{nn})(wRad:wWidth+1,:);
           end      
           Dest(ind(iyz(wRad:wWidth+1)))=w0.P.lambda/2/w0.timestep;
       end
   end   
   %disp(int2str([n numel(X.i0)]))
end
toc(tInit)
YZ=W.YZ;
