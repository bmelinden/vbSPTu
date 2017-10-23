% relpath=SM_relative_path(path1,path2)
%
% Compute out the relative path from path1 to path2, which must be
% (absolute) paths with a common root.
%
% Note that the inputs are treated as paths even if they do not end with a
% filesep character, for example if called by complete paths to file names.
% What is actually done is 
% [pathX,~,~]=fileparts([pathX filesep]); % for X=1,2
%
% The inputs do not need to exist, but they do need to have some common
% root, e.g., /home/restofpath1, /home/restofpath2, or c:\path1, c:\path2)
%
% ML 2015-03-12

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SM_license.m, prints a short license text for the SMeagol package
% ========================================================================= 
% Copyright (C) 2015 Martin Lindén and Johan Elf
% 
% E-mail: bmelinden@gmail.com, johan.elf@gmail.com
% =========================================================================
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any
% later version.  This program is distributed in the hope that it will
% be useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
% the GNU General Public License for more details.
% 
% Additional permission under GNU GPL version 3 section 7
%  
% If you modify this Program, or any covered work, by linking or
% combining it with Matlab or any Matlab toolbox, the licensors of this
% Program grant you additional permission to convey the resulting work.
% 
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%% start of actual code
function relpath=SM_relative_path(path1,path2)

% add file separators at the end, but only one
[path1,~,~]=fileparts([path1 filesep]); path1=fullfile([path1 filesep]);
[path2,~,~]=fileparts([path2 filesep]); path2=fullfile([path2 filesep]);

% look for common root
fsn1=strfind(path1,filesep);
fsn2=strfind(path2,filesep);

% see if they start the same
if(fsn1(1)~=fsn2(1) || ~strcmp(path1(1:fsn1(1)),path2(1:fsn2(1))) )
    % then the two paths have no common root
    error('SM_relative_pathfound no common root in the input paths.')
end

if(fsn1(1)~=1) % then add index 0 to be able to compare first part of it
fsn1=[0 fsn1];
end
if(fsn2(1)~=1) % then add index 0 to be able to compare first part of it
fsn2=[0 fsn2];
end

% find the first intance where the paths diverge
start_of_divergence=length(fsn1); % start assuming that path2 is a subfolder of path1
for k=1:length(fsn1)-1 % loop through path1
    if(k==length(fsn2)) % then all of path2 was in path1: path1 is a subfolder of path2
        start_of_divergence=k;
        break;        
    end    
    folder1=path1(fsn1(k)+1:fsn1(k+1)-1);
    folder2=path2(fsn2(k)+1:fsn2(k+1)-1);
    if(~strcmp(folder1,folder2)) % then the paths start to diverge here
        start_of_divergence=k;
        break;
    end
end


% number of remaining subfolders in path1 after path divergence
n_up1=length(fsn1)-start_of_divergence;

% number of remaining subfolders in path2 after path divergence
n_down2=length(fsn2)-start_of_divergence;

% build relative path
relpath='.';
for k=1:n_up1
   relpath=fullfile(relpath,'..'); 
end
relpath=fullfile(relpath,path2(fsn2(start_of_divergence):end),filesep);

