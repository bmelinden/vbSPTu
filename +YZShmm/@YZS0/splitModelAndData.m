function [Wii,Xii,W0,X0]=splitModelAndData(this,X,ii)
% [Wii,Xii,W0,X0]=splitModelAndData(this,X,ii)
% split model W and data X into two parts, with Wi,Xi containing
% trajectories with index ii, and W0,X0 containing the remaining parts.
% Misc fields of the data are not included.

% indices to complementary data set
i0=setdiff(1:numel(X.i0),ii);

if(nargout>2)
    doi0=true;
else
    doi0=false;
end

% split data
x=spt.dat2trj(X.i0,X.i1,X.x);
if(isfield(X,'v') && ~isempty(X.v))
    v=spt.dat2trj(X.i0,X.i1,X.v);
    vii=ii;vi0=i0;
else
    v=[];vii=[];vi0=[];
end
% split misc 
misci=[];misc0=[];
if(isfield(X,'misc'))
    if(isreal(X.misc)) % then a single array
        misc=spt.dat2trj(X.i0,X.i1,X.misc);
        misci=misc(ii);
        if(doi0)
            misc0=misc(i0);
        end
    elseif(iscell(X.misc)) % then a cell vector of arrays
        misci=cell();misc0=cell();
        for k=1:numel(X.misc)
            misc=spt.dat2trj(X.i0,X.i1,X.misc{k});
            misci{k}=misc(ii);
            if(doi0)
                misc0{k}=misc(i0);
            end
        end
    elseif(isstruct(X.misc)) % then a struct with arrays as fields
        misci=struct;misc0=struct;
        fn=fieldnames(X.misc);
        for k=1:numel(fn)
            misc=spt.dat2trj(X.i0,X.i1,X.misc.(fn{k}));
            misci.(fn{k})=misc(ii);
            if(doi0)
                misc0.(fn{k})=misc(i0);
            end
        end
    end
end
Xii=spt.preprocess(x(ii),v(vii),X.dim,misci,[],false);
if(doi0)
    X0 =spt.preprocess(x(i0),v(vi0),X.dim,misc0,[],false);
end

% create new models with empty q(S) and q(Y,Z) distributions
Wii=this.clone();
Wii.S.pst=[];
Wii.YZ.i0=Xii.i0;
Wii.YZ.i1=Xii.i1+1;
if(doi0)
    W0=this.clone();
    W0.S.pst=[];
    W0.YZ.i0=X0.i0;
    W0.YZ.i1=X0.i1+1;
end
YZf={'muY','muZ','varY','varZ','covYtYtp1','covYtZt','covYtp1Zt'};%,'i0','i1'};
for m=1:numel(YZf)
   Wii.YZ.(YZf{m})=[]; 
   if(doi0)
       W0.YZ.(YZf{m})=[]; 
   end
end

% split q(S) and q(Y,Z)
for k=1:numel(ii)
    Wii.S.pst(Wii.YZ.i0(k):Wii.YZ.i1(k),:)=...
        this.S.pst(this.YZ.i0(ii(k)):this.YZ.i1(ii(k)),:);
    for m=1:numel(YZf)
        Wii.YZ.(YZf{m})(Wii.YZ.i0(k):Wii.YZ.i1(k),:)=...
            this.YZ.(YZf{m})(this.YZ.i0(ii(k)):this.YZ.i1(ii(k)),:);
    end
end
if(doi0)
    for k=1:numel(i0)
        W0.S.pst(W0.YZ.i0(k):W0.YZ.i1(k),:)=...
            this.S.pst(this.YZ.i0(i0(k)):this.YZ.i1(i0(k)),:);
        for m=1:numel(YZf)
            W0.YZ.(YZf{m})(W0.YZ.i0(k):W0.YZ.i1(k),:)=...
                this.YZ.(YZf{m})(this.YZ.i0(i0(k)):this.YZ.i1(i0(k)),:);
        end
    end
end



