% opt=spt.readRuninputFile(runinputfile)
%
% convert SMeagol runinput parameters from a runinput file into an options
% structure opt. All variables created by the command eval(runinputfile)
% are stored in the opt structure.
%
% Additionally, the absolute path to the runinput file is stored in
% opt.runinput_root, to make it possible to interpret paths in the runinput
% file relative to the location of that file.
%
% If a struct object is passed, it is simply returned. This is a convenient
% way to make it possible to use opt structures as alternative input in all
% sorts of SM simulation files without having to perform string-tests etc
% each time. However, this does not perform the above path operations.
%
% M.L. 2014-01-24

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spt.readRuninputFile.m, read runinout parameters in the mesoSM package
% derived from corresponding files in the vbTPM package.
% =========================================================================
% 
% Copyright (C) 2014 Martin Lindén
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
%  If you modify this Program, or any covered work, by linking or combining
%  it with Matlab or any Matlab toolbox, the licensors of this Program
%  grant you additional permission to convey the resulting work.
%
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <http://www.gnu.org/licenses/>.
%% start of actual code

%% start of actual code
function opt=readRuninputFile(runinputfile)
% if empty input, select file manually
if(~exist('runinputfile','var') || isempty(runinputfile))
    [RIname, RIpath] = uigetfile({'*.m'},'select a runinput file');
    if(RIname == 0)
        disp('Error! No (or wrong) file selected!')
        opt=struct;
        return
    end
    runinputfile=fullfile(RIpath,RIname);
    clear RIname RIpath
end
% if input is a struct, then just return it
if(isstruct(runinputfile))
    opt=runinputfile;
    %disp('spt.readRuninputFile got a struct input, returns struct as is.')
    return
end

%% Find and verify path to the runinput file
[path_tmp, name_tmp, ext_tmp] = fileparts(runinputfile);
if(isempty(ext_tmp)) % then add in the .m extension
    runinputfile=[runinputfile '.m'];
    [path_tmp, name_tmp, ext_tmp] = fileparts(runinputfile);
end
%if(~strcmp(ext_tmp,'.m') && ~isempty(ext_tmp)) % %% good new feature?
%    error('spt.readRuninputFile: ruininput file must be a Matlab .m file')
%end


% test to see if the runinput file exists
if(~exist(runinputfile,'file'))
    error(['spt.readRuninputFile: runinput file not found: ' runinputfile ' .'])        
end
if(isempty(path_tmp)) % no path given, interpreted as relative path
    path_tmp='';
    isRelPath=true;
else % if path is given, interpret as relative path if possible
    isRelPath=exist(fullfile(pwd,runinputfile),'file');
end
% make path_tmp an absolute path if it isn't already
if(isRelPath)
    path_tmp=fullfile(pwd,path_tmp);
end
clear isRelPath
disp('spt.readRuninputFile looking for runinput file : ')
disp(fullfile(path_tmp,[name_tmp ext_tmp]));
%% evaluate runinput file and store all variables to opt structure
oldFolder = cd(path_tmp); % oldFolder is path from which spt.getOption was called
% check that the runinput file is actually present in this folder
abspathfile=fullfile(path_tmp,[name_tmp ext_tmp]);
if(exist(abspathfile,'file'))
    eval(name_tmp)
else
    error(['spt.readRuninputFile: runinput file not found: ' abspathfile ' .'])    
end
cd(oldFolder);
clear oldFolder abspathfile; % forget what folder the options file happend to be called from

vv=whos;
opt=struct;
for m=1:length(vv)
    opt.(vv(m).name)=eval(vv(m).name);    
end
opt.localroot=pwd;                      % take note of where getOptions was called from
opt.runinputroot=fullfile(path_tmp);    % absolute path to runinput file
opt=rmfield(opt,'runinputfile');        % move this field last
opt.runinputfile=[name_tmp ext_tmp];    % name of runinput file 
%% cleanup fields created within this function
opt=rmfield(opt,{'path_tmp','name_tmp','ext_tmp'});
