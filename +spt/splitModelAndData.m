function [Wii,Xii,W0,X0]=splitModelAndData(W,X,ii)
% [Wii,Xii,W0,X0]=spt.splitModelAndData(W,X,ii)
% split model W and data X into two parts, with Wi,Xi containing
% trajectories with index ii, and W0,X0 containing the remaining parts.
% applies to mleYZdXt-type model structs

% indices to complementary data set
i0=setdiff(1:numel(X.i0),ii);

% split data
x=spt.dat2trj(X.i0,X.i1,X.x);
v=[];vii=[];vi0=[];
misci=[];misc0=[];
if(isfield(X,'v'))
    v=spt.dat2trj(X.i0,X.i1,X.v);
    vii=ii;vi0=i0;
end
if(isfield(X,'misc'))    
    if(isreal(X.misc)) % then a single array
        misc=spt.dat2trj(X.i0,X.i1,X.misc);
        misci=misc(ii);
        misc0=misc(i0);        
    elseif(iscell(X.misc)) % then a cell vector of arrays
        misci=cell();misc0=cell();
        for k=1:numel(X.misc)
            misc=spt.dat2trj(X.i0,X.i1,X.misc{k});
            misci{k}=misc(ii);
            misc0{k}=misc(i0);            
        end
    elseif(isstruct(X.misc)) % then a struct with arrays as fields
        misci=struct;misc0=struct;
        fn=fieldnames(X.misc);
        for k=1:numel(fn)
            misc=spt.dat2trj(X.i0,X.i1,X.misc.(fn{k}));
            misci.(fn{k})=misc(ii);
            misc0.(fn{k})=misc(i0);  
        end
    end
end
Xii=spt.preprocess(x(ii),v(vii),X.dim,misci,[],false);
X0 =spt.preprocess(x(i0),v(vi0),X.dim,misc0,[],false);

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



