function displayParameters(this,dat,iType,varargin)
% displayParameters(this,dat,iType,varargin)
% 1) estimate paramters using
% P=this.getParameters(this,'data',dat,'iType',iType)
% 2) print them to command prompt in a nice way, using 
% displayStruct(P,varargin)
% see help text for YZShmm.classname.getParameters and displayStruct for
% guidance on input parameters

P=this.getParameters('data',dat,'iType',iType);

displayStruct(P,varargin{:})