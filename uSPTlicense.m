function uSPTlicense(funcName)
% uSPTlicense(funcName)
%?
% Prints a short license text to the command line.

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% uSPTlicense.m, prints a short license text for the uSPThmm package
% =========================================================================
% 
% Copyright (C) 2017 Martin Lindén and Johan Elf
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
%% start of actual code
if(~exist('funcName','var'))
    funcName=[];
else
    funcName=[funcName ', '];
end
fprintf(...
['\n uSPThmm, %sCopyright (C) 2017 Martin Lindén and Johan Elf.\n\n' ...
' This program is free software: you can redistribute it and/or modify it\n' ...
' under the terms of the GNU General Public License as published by the\n' ...
' Free Software Foundation, either version 3 of the License, or any later\n' ...
' version.   \n' ...
' This program is distributed in the hope that it will be useful, but\n' ...
' WITHOUT ANY WARRANTY; without even the implied warranty of\n' ...
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General\n' ...
' Public License for more details.\n' ...
'\n' ...
' Additional permission under GNU GPL version 3 section 7\n' ...
'  \n' ...
'   If you modify this Program, or any covered work, by linking or combining \n' ...
'   it with Matlab or any Matlab toolbox, the licensors of this Program \n' ...
'   grant you additional permission to convey the resulting work.\n' ...
'\n' ...
' You should have received a copy of the GNU General Public License along\n' ...
' with this program. If not, see <http://www.gnu.org/licenses/>.\n\n'],funcName);

end



