function displayParameters(this,dat,iType,varargin)
% displayParameters(this,dat,iType,varargin)
% 1) estimate paramters using
% P=this.getParameters(dat,iType)
% 2) print them to command prompt in a nice way, using 
% displayStruct(P,varargin)
% see help text for YZShmm.classname.getParameters and displayStruct for
% guidance on input parameters

P=this.getParameters(dat,iType);
displayStruct(P,varargin{:})
