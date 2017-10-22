% spt.writeRuninputFile: write runinput file from opt struct.
% Also adds some comments for the SMeagol-spcific headers.
%
% [flag,S]=spt.writeRuninputFile(opt,file,writeBackup)
% 
% input:
% opt   : options structure to write to the file
% file  : file to write to
% writeBackup : if true, rename an existing runinput file before
%               overwriting it (default: false).
%
% output:
% S     : cell vector of strings, one for every line written
% flag  : 0 = file written OK (possibly overwriting existing file) 
%        -1 = no file written
%        >0 = file written, olf file moved to [file '.' flag]
% ML 2015-03-02

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% writeRuninputFile, print runinput file from opt structure, part of the 
% uSPThmm package.
% ========================================================================= 
% Copyright (C) 2017 Martin Lindén and Johan Elf
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
function [flag,S]=writeRuninputFile(opt,file,writeBackup)

%% input check
if(~exist('writeBackup','var'))
    writeBackup=false;
end
flag=-1;
% check extension of input file
% theErr: potential error message generated
[~,~,ext_tmp] = fileparts(file);
if(isempty(ext_tmp)) % then add in the .m extension
    file=[file '.m'];
end
clear ext_tmp

% move existing file to a backup
bckflag=0;
if(writeBackup && exist(file,'file'))
    backupfile=file;
    while(exist(backupfile,'file'))
        bckflag=bckflag+1;
        backupfile=[file '.' int2str(bckflag)];
    end
    eval(['! mv ' file ' ' backupfile])
    disp(['moved old runinput file ' file ' to ' backupfile ])
end
%% define helpul comments corresponding to the different headings
heading=cell(0);
heading_intro=cell(0);

heading{1}='trj';
heading_intro{1}=...
{'% trj: information about the input data.'};
heading{2}='output';
heading_intro{2}=...
{'% output: what to output, and where.'};
heading{3}='model';
heading_intro{3}=...
{'% Model: name of the model class.'};
heading{4}='prior';
heading_intro{4}=...
{'% Prior: how to create prior distribution for different model sizes.'};
heading{5}='init';
heading_intro{5}=...
{'% init: parameters for initializing new models.'};
heading{6}='conv';
heading_intro{6}=...
{'% conv: convergence parameters.'};
heading{7}='modelSearch';
heading_intro{7}=...
{'% modelSearch: methods and parameters to search for good models.'};
heading{8}='bootstrap';
heading_intro{8}=...
{'% bootstrap: bootstrap-based uncertainty estimates of model selection and parameters.'};
%% write the file and string
fid=fopen(file,'w');
if(fid==-1)
    error(['Error: could not open file ' file ' for writing.'])
end

% write stuff item by item
S={};
% brief introduction
S{end+1,1}=['% SMeagol runinputfile, created ' datestr(now) '.'];
S{end+1,1}= '% a note on units: SMeagol does not know about units, and so the user is';
S{end+1,1}= '% charged with using consistent units of length, time, and diffusion';
S{end+1,1}= '% constants (units of length^2/time).';

for h=1:length(heading)
    if(isfield(opt,heading{h}))
        % add divider
        %S{end+1,1}=[''];
        S{end+1,1}=['%% ' heading{h}];
        %S{end+1,1}=['%-----------------------------------------------------------------------------------------------'];
        %S{end,1}=[S{end,1}(1:length(S{end-1,1})-1) '%']; % a row of --- as long as the preceding heading '%'
        S{end+1,1}='% ----------------------------------------------------------------------- %';
        % add comments part
        for k=1:length(heading_intro{h})
            S{end+1,1}=heading_intro{h}{k};
        end        
        % add actual parameters
        H=struct;
        H.(heading{h})=opt.(heading{h});
        SH=SM_opt2str(H);
        for k=1:length(SH)
           S{end+1,1}=SH{k}; 
        end
            S{end+1,1}='% ----------------------------------------------------------------------- %';
    else
        error(['input option struct missing field ' heading{h}])
    end
end

% write the strings to the file
for k=1:length(S)
    fprintf(fid,'%s\n',S{k});
end
    
flag=max(flag,bckflag);
fclose(fid);



