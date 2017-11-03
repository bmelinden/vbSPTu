function [X,varX,misc,dim,Tmin,maxRMSE]=readData(opt)
% [X,varX,misc,dim,Tmin,maxRMSE]=spt.readData(runinput)
% [X,varX,misc,dim,Tmin,maxRMSE]=spt.readData(opt)
% Read data fields from a runinput file or options struct.
% output can be fed directly to spt.preprocess. 
% 
% input:
% opt          : a uSPT options struct
% runinputfile : path to a uSPT runinput file
% 
% output:
% X     : cell vector of positions, read from the variable
%         opt.trj.trajectoryfield in opt.trj.inputfile
% varX  : cell vector of position uncertainties (variances), read from the
%         variable opt.trj.uncertaintyfield in opt.trj.inputfile
% misc  : cell/struct with misc data, read from the variable(s)
%         opt.trj.miscfield (a cell vector) in opt.trj.inputfile
%
% The full variables X,varX, misc are read from the data, the remaining
% output are simple extracted from the options structure or runinput file
% as parameters for preprocessing. If fields are missing, empty variables
% are returned.
%
% dim   : Only the first dim columns of the position and vaiance data are
%         kept by spt.preprocess. Given by dim=opt.trj.dim.
% Tmin  : Only trajectories with >=Tmin positions are kept by
%         spt.preprocess. Given by opt.trj.Tmin
% maxRMSE : Upper threshold on estimated errors. If
%         max(varX{k}(t,:))>maxRMSE^2, then X{k}(t,:) are treated by
%         spt.preprocess as a missing position, and set to
%         varX{k}(t,:)=inf, X{k}(t,:)=nan.  
%         Given by opt.trj.maxRMSE (set opt.trj.maxRMSE=inf to include all
%         detected positions).

if(isstruct(opt))
    % then we are presumably good
elseif(ischar(opt))
    runinputfile = opt;
    if (exist(opt, 'file')==2)
        opt=spt.readRuninputFile(runinputfile);
        disp(['Read runinput file ' runinputfile])
    else
        error(['File not found: ' opt])
    end
end

Tmin=[];dim=[];maxRMSE=[];
if(isfield(opt.trj,'Tmin'))
    Tmin=opt.trj.Tmin;
end
if(isfield(opt.trj,'dim'))
    dim=opt.trj.dim;
end
if(isfield(opt.trj,'maxRMSE'))
    maxRMSE=opt.trj.maxRMSE;
end

if(~isempty(opt.trj.trajectoryfield))
    R=load(fullfile(opt.runinputroot,opt.trj.inputfile),opt.trj.trajectoryfield);
    X=R.(opt.trj.trajectoryfield);
else
    error('missing option trajectoryfield')
end
if(~isempty(opt.trj.uncertaintyfield))
    R=load(fullfile(opt.runinputroot,opt.trj.inputfile),opt.trj.uncertaintyfield);
    varX=R.(opt.trj.uncertaintyfield);
else
    varX=[];
end
if(~isempty(opt.trj.miscfield))
    if(ischar(opt.trj.miscfield)) % a single misc. field name
        misc=load(fullfile(opt.runinputroot,opt.trj.inputfile),opt.trj.miscfield);
        % misc=misc.(opt.miscfield);
    elseif(iscell(opt.trj.miscfield)) % multiple misc. field names in a cell vector 
        misc=load(fullfile(opt.runinputroot,opt.trj.inputfile),opt.trj.miscfield{:});
    end
else
    misc=[];
end
