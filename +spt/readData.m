function [X,varX,misc,dim,Tmin]=readData(opt)
% [X,varX,misc,dim,Tmin]=spt.readData(runinput)
% [X,varX,misc,dim,Tmin]=spt.readData(opt)
% Read data fields from a runinput file or options struct.
% output can be fed directly to spt.preprocess

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

Tmin=opt.trj.Tmin;
dim=opt.trj.dim;

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
