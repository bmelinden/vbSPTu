% SM_license(funcName)
% 
% Prints a short SMeagol license text to the command line.

%% copyright notice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SM_license.m, prints a short license text for the SMeagol package
% ========================================================================= 
% Copyright (C) 2016 Martin Lindén and Johan Elf
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
function SM_license(funcName)

fprintf(...
['\nSMeagol, %s\nCopyright (C) 2016 Martin Lindén and Johan Elf\n\n' ...
 'This program comes with ABSOLUTELY NO WARRANTY. \n' ...
 'This is free software, and you are welcome to redistribute it \n' ...
 'under certain conditions. See license.txt for details. \n\n' ...
 'Additional permission under GNU GPL version 3 section 7 \n\n'...
 '   If you modify this Program, or any covered work, by linking \n'...
 '   or combining it with Matlab or any Matlab toolbox, the \n'...
 '   licensors of this Program grant you additional permission \n'...
 '   to convey the resulting work. \n\n'],funcName);
end



