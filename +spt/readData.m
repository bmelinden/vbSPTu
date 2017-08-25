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
        opt=spt.getOptions(runinputfile);
        disp(['Read runinput file ' runinputfile])
    else
        error(['File not found: ' opt])
    end
end

Tmin=opt.Tmin;
dim=opt.dim;

if(~isempty(opt.trajectoryfield))
    R=load(fullfile(opt.runinputroot,opt.inputfile),opt.trajectoryfield);
    X=R.(opt.trajectoryfield);
else
    error('missing option trajectoryfield')
end
if(~isempty(opt.uncertaintyfield))
    R=load(fullfile(opt.runinputroot,opt.inputfile),opt.uncertaintyfield);
    varX=R.(opt.uncertaintyfield);
else
    varX=[];
end
if(~isempty(opt.miscfield))
    if(ischar(opt.miscfield)) % a single misc. field name
        misc=load(fullfile(opt.runinputroot,opt.inputfile),opt.miscfield);
        % misc=misc.(opt.miscfield);
    elseif(iscell(opt.miscfield)) % multiple misc. field names in a cell vector 
        misc=load(fullfile(opt.runinputroot,opt.inputfile),opt.miscfield{:});
    end
else
    misc=[];
end
