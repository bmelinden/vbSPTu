function newTrjInd=trjImproveYZS(this,X,W1,iType)
% newTrjInd=YZSh.YZS0.trjImproveYZS(X,W1,iType)
% go through all trajectories, and replace the S,YZ fields of W0 with those
% of W1 if that improves the total lower bound of W0. Affected trajectories
% are returned in the newTrjInd vector.
% All trajectories are compared using the parameter distributions of W0,
% but paramters are not updated.

% ML 2018-02-14



YZfield={'muY','muZ','varY','varZ','covYtYtp1','covYtZt','covYtp1Zt'};
newTrjInd=[];
% loop over trajectories
for t=1:numel(X.i0)
   % extract 1-trj models
   [W0t,Xt]=this.splitModelAndData(X,t);
   W1t     =W1.splitModelAndData(X,t);
   W1t.P=this.P; % ensure parameters are the same
   
   % converge with fixed parameters
   W0t.YZiter(Xt,iType);
   W0t.Siter(Xt,iType);
   W1t.YZiter(Xt,iType);
   W1t.Siter(Xt,iType);

   if(W1t.lnL>W0t.lnL)
      % then replace the S- and YZ- fields of W0 with those of W1t
      YZind=this.YZ.i0(t):this.YZ.i1(t);
      this.S.pst(YZind(1:end-1),:)=W1t.S.pst(1:end-1,:);
      for n=1:numel(YZfield)
         this.YZ.(YZfield{n})(YZind,:)=W1t.YZ.(YZfield{n});
      end
      newTrjInd(end+1)=t;
   end
   
end




