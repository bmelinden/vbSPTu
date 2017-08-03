function dat=preprocess(X,varX,dim,misc,warn)
% [dat,X,varX]=spt.preprocess(X,varX,dim,misc,warn)
%
% Input (*optional)
% Assemble single particle diffusion data for diffusive HMM analysis.
% X         : cell vector of position trajectories, or single trajectory.
% *varX     : cell vector of position uncertainties (posterior variances),
%             or a vector of such variances. If empty, no variance field is
%             written to dat.
% NaN/Inf entries in X,varX and varX<0, is interpreted as missing data.
%
% *dim      : number of data dimensions (x,y,z,...). Default=size(X{1},2);
% *misc     : cell vector of some other field one would like to keep track
%             of. The row elements of each cell element are organized in
%             the same way as the positions, for easy comparison.
% *warn     : if true, display some output when trajectory data is
%             truncated. (default true).
%
% output: a struct dat, with fields
% dim       : data dimensionality (number of columns in X, varX)
% i0,i1     : index vector, such that X{k} is stored in
%             dat.X(i0(k):i1(k),:), and similar for varX, isPos, etc
% T         : vector of trj lengths, T(k)=1+dat.i1(k)-dat.i0(k).
% x         : positions array, with number of columns given by dim. 
% v         : localization variance array. Inf means missing data point.
%             Only if a non-empty varX input was given.
%       Missing data points are indicated by NaNs in the x field, and Inf
%       in the v field. Data outside of measured trajectories (t=T+1) are
%       NaN. 
% misc      : misc data array
%  
% 
% ML 2017-07-03

% v1 : maintains missing data with an arra isPos
% v2 : missing data indicated by NaN in positions and variances

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocess, data preprocessor for diffusive HMM analysis
% =========================================================================
% 
% Copyright (C) 2017 Martin Lindén
% 
% E-mail: bmelinden@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or any later
% version.   
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
%  Additional permission under GNU GPL version 3 section 7
%  
%  If you modify this Program, or any covered work, by linking or combining it
%  with Matlab or any Matlab toolbox, the licensors of this Program grant you 
%  additional permission to convey the resulting work.
%
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <http://www.gnu.org/licenses/>.
%% parse input
% if an existing file, generate options structure
if(~iscell(X))
    X={X};
end
if(exist('varX','var')&&~isempty(varX))
    hasVarX=true;
    if(~iscell(varX))
        varX={varX};
    end
else
    hasVarX=false;
end
if(~exist('dim','var')||isempty(dim))
    dim=size(X{1},2);
end
if(exist('misc','var')&&~isempty(misc))
    hasMisc=true;
    if(~iscell(misc))
        misc={misc};
    end
else
    hasMisc=false;
end
if(~exist('warn','var')||isempty(warn))
    warn=true;
end
%% assemble output structure
dat=struct;
dat.dim=dim;

% prune away missing data points in the beginnings and ends of each
% trajectory
hadToPrune=false;
prunedTrjs=[];
for k=1:length(X)
    x=X{k};
    if(hasVarX)
        v=varX{k};
        ip=isfinite(sum([x v],2)) & prod(v>=0,2); % check for existing data points
    else
        ip=isfinite(sum(x,2));   % check for existing data points
    end    
    % sanity check 1: remove missing data in the beginning or end of trj
    while( ~ip(1))
        hadToPrune=true;
        prunedTrjs(end+1)=k;
        x = x(2:end,:);
        ip=ip(2:end,:);
        if(hasVarX)
            v = v(2:end,:);
        end
        if(hasMisc)
            misc{k}=misc{k}(2:end,:);
        end
    end
    while( ~ip(end))
        hadToPrune=true;
        prunedTrjs(end+1)=k;
        x = x(1:end-1,:);
        ip=ip(1:end-1,:);
        if(hasVarX)
            v = v(1:end-1,:);
        end
        if(hasMisc)
            misc{k}=misc{k}(1:end-1,:);
        end
    end
    X{k}=x;
    if(hasVarX)
        varX{k}=v;
    end
end
if(warn && hadToPrune) % then warn that pruning took place
    prunedTrjs=union(prunedTrjs(1),prunedTrjs);    
    disp(['spt.preprocess : shortened trajectories' sprintf(' %d',prunedTrjs) ', to remove missing data in the end or beginning.'])
end

% count output size
T=zeros(size(X));
for k=1:length(X)
    T(k)=size(X{k},1);
end
% discard trajectories with only 1 position
if(~isempty(find(T<2,1)))
    if(warn)
        disp('spt.preprocess :  removing traces with no steps.')
    end
   X=X(T>1);
   if(hasVarX)
       varX=varX(T>1);
   end
   if(hasMisc)
       misc=misc(T>1);
   end
   T=T(T>1);   
end
% data stacking: pack a zero-row between every trajectory to match sizes of
% data x(t) and diffusive path y(t).
dat.T=T;
dat.i0=zeros(1,length(X),'double');
dat.i1=zeros(1,length(X),'double');
dat.x=zeros(sum(T+1),dim);
if(hasVarX)
    dat.v=zeros(sum(T+1),dim);
end
if(hasMisc)
    miscColumns=size(misc{1},2);
    dat.misc=zeros(sum(T+1),miscColumns);
end

% now step through trj data and build output arrays
ind=1;
for k=1:length(X)
    x=X{k}(:,1:dim);
    if(hasVarX)
        v=varX{k}(:,1:dim);
    end
    Tx=size(x,1);
    dat.i0(k)=ind;
    dat.i1(k)=ind+Tx-1;
    ind=ind+Tx;
    dat.x(dat.i0(k):dat.i1(k),1:dim)=x; 
    if(hasVarX)
        dat.v(dat.i0(k):dat.i1(k),1:dim)=v;
    end
    if(hasMisc)
       dat.misc( dat.i0(k):dat.i1(k),1:miscColumns)=misc{k};
    end
    ind=ind+1;
end
% output convention for missing data points and T+1 points
% outside of trajectories: counts as missing
if(hasVarX)
    ip=isfinite(sum([dat.x dat.v],2)) & prod(dat.v>=0,2); % check for existing data points
else
    ip=isfinite(sum(dat.x,2));   % check for existing data points
end

dat.x(~ip,:)=nan;
dat.x(dat.i1+1,:)=nan;
if(hasVarX)
    dat.v(~ip,:)=inf;
    dat.v(dat.i1+1,:)=nan;
end

