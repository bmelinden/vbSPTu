function [Wii,Xii,W0,X0]=splitModelAndData(W,X,ii)
% [Wii,Xii,W0,X0]=splitModelAndData(W,X,ii)
% split model W and data X into two parts, with Wi,Xi containing
% trajectories with index ii, and W0,X0 containing the remaining parts.

% indices to complementary data set
i0=setdiff(1:numel(X.i0),ii);

% split data
x=spt.dat2trj(X.i0,X.i1,X.x);
v=[];vii=[];vi0=[];
misc=[];mii=[];mi0=[];
if(isfield(X,'v'))
    v=spt.dat2trj(X.i0,X.i1,X.v);
    vii=ii;vi0=i0;
end
if(isfield(X,'misc'))
    misc=spt.dat2trj(X.i0,X.i1,X.misc);
    mii=ii;mi0=i0;
end
Xii=spt.preprocess(x(ii),v(vii),misc(mii));
X0=spt.preprocess(x(i0),v(vi0),misc(mi0));

% create new models
Wii=mleYZdXt.init_P_dat(W.shutterMean,W.blurCoeff,W.P.lambda/2/W.timestep,W.timestep,W.P.A,W.P.p0,Xii);
W0 =mleYZdXt.init_P_dat(W.shutterMean,W.blurCoeff,W.P.lambda/2/W.timestep,W.timestep,W.P.A,W.P.p0,X0 );

% split q(S) and q(Y,Z)
YZf={'muY','muZ','varY','varZ','covYtYtp1','covYtZt','covYtp1Zt'};
for k=1:numel(ii)
    Wii.S.pst(Wii.YZ.i0(k):Wii.YZ.i1(k),:)=...
        W.S.pst(W.YZ.i0(ii(k)):W.YZ.i1(ii(k)),:);
    for m=1:numel(YZf)
        Wii.YZ.(YZf{m})(Wii.YZ.i0(k):Wii.YZ.i1(k),:)=...
            W.YZ.(YZf{m})(W.YZ.i0(ii(k)):W.YZ.i1(ii(k)),:);
    end
end
for k=1:numel(i0)
    W0.S.pst(W0.YZ.i0(k):W0.YZ.i1(k),:)=...
        W.S.pst(W.YZ.i0(i0(k)):W.YZ.i1(i0(k)),:);
    for m=1:numel(YZf)
        W0.YZ.(YZf{m})(W0.YZ.i0(k):W0.YZ.i1(k),:)=...
            W.YZ.(YZf{m})(W.YZ.i0(i0(k)):W.YZ.i1(i0(k)),:);
    end
end



