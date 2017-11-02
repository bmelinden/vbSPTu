% s=SM_opt2str(opt,numDig)
%
% Produce a string represenation of the fields in opt that can be
% evaluated line by line. The inverse function is SM_str2opt, which
% interprets such strings.
% 
% s     : string cell vector output
% opt   : input structure whose fields are to be printed to s
% numDig: Number of significant digits, as in num2str(pi,numDig). 
%       : Optional, default 15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SM_opt2str.m, convert struct to string cell vector, part of the SMeagol 
% package.
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
function s=SM_opt2str(opt,numDig)
if(~exist('numDig','var')|| isempty(numDig))
    numDig=5;
end

% loop over all fields
f=fieldnames(opt);
s=cell(0);
for k=1:length(f)
    var=opt.(f{k});

    [a,b,c]=size(var);

    if(c>1)
        error('SM_opt2str cannot handle matrices with >2 dimensions.')
    end
    try
        if(isempty(var))
            if(isnumeric(var))
                s{end+1,1}=[f{k} ' = [];' ];                            %#ok
            elseif(iscell(var))
                s{end+1,1}=[f{k} ' = {};' ];                            %#ok
            elseif(ischar(var))
                s{end+1,1}=[f{k} ' = ' char(39) char(39) ';'];          %#ok
            else
                error(['SM_opt2str encountered an unimplemented empty object: ' f{k} ' is a ' class(var) '.'])
            end
        elseif(ischar(var))
            s{end+1,1} = [ f{k} '=' char(39) var char(39) ';'];
        elseif(isstruct(var))
            SS=SM_opt2str(var,numDig);
            for kk=1:length(SS)
                s{end+1,1}=[f{k} '.' SS{kk}];
            end
        elseif(iscell(var))
            for kk=1:length(var)
                vs=struct;
                vs.(f{k})=var{kk};
                SS=SM_opt2str(vs);
                for mm=1:length(SS)
                    flength=length(f{k});
                    s{end+1,1}=[SS{mm}(1:flength) '{' int2str(kk) '}' SS{mm}(flength+1:end)];
                end
            end
        elseif(islogical(var) && a==1 && b==1)
            if(var)
                s{end+1,1} = [ f{k} '=true;']; 
            else
                s{end+1,1} = [ f{k} '=false;'];                 
            end
        elseif( a==1 && b==1) % var is a scalar
            s{end+1,1} = [ f{k} '=' num2str(var,numDig) ';'];       %#ok
        elseif( a==1 && b>1 ) % var is a row vector
            s{end+1,1} = [ f{k} '=[ ' num2str(var,numDig) '];'];   %#ok
        elseif( a>1 && b==1) % var is a column vector
            s{end+1,1} = [ f{k} '=[ ' num2str(var',numDig) ...     %#ok
                ']' char(39) '; %(note transpose!)'];        %#ok
        elseif( a>1 && b>1) % var is a matrix
            for m=1:a
                s{end+1,1} =  [ f{k} '(' int2str(m) ',:)=[' ...        %#ok
                    num2str(var(m,:),numDig) '];'];                 %#ok
            end
        else
            disp('Oops, SM_opt2str found a field it could not handle.')
            keyboard
        end
    catch me
        disp('Oops, SM_opt2str encountered a conversion error:')
        disp(me.message)
        keyboard
    end
end

