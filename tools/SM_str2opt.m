% function [opt,isOK]=SM_str2opt(str)
%
% Evaluate expressions of the form str={'a=x;','b=y;',...} and puts the
% LHS variables as fields in the structure opt. This is the inverse of
% SM_opt2str function.
% isOK = true if all cells of str could be evaluated, and false otherwise.
%
% ML 2014-11-21

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SM_str2opt.m, convert cell string to struct, part of the SMeagol package
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
function [opt,isOK]=SM_str2opt(str)
opt=struct;
isOK=true;

try
    for k=1:length(str);
        eval(['opt.' str{k}]);
    end
catch
    isOK=false;
end



