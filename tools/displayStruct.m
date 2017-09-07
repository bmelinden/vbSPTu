function displayStruct(P,varargin)
% displayStruct(P,...)
% print the fields of a struct P, optionally with std errors given in
% identially named fields of dP. Only scalars and 2-dimensional arrays are
% handled correctly.
%
% optional parameter value pairs
% 'dP', dP                          : also display std.err. in the form 
%                                     P.f1 +- dP.f1
% 'fieldName',{'f1','f2',...}       : displays fields f1,f2,... Default:
%                                     all fields in P.
% 'scale', {'f1',s1,'f2',s2,...}    : rescales fields f1,f2,... in P and dP
%                                     by factors s1,s2.
% 'units',{'f1','u1',f2','u2',...}  : print units u1,u2, after the
%                                     corresponding fiels. 
% 'numFormat',ss                    : C-style number format string without
%                                     leading %. Default '6.2f'. 
%   Note that a '-' for left-adjustment is added in front for the std.err.,
%   and the format string must be compatible with that if errors are
%   displayed. (e.g., '-6.2f' will not work)

% default parameters
numFormat='6.2f';
dP=[];

for k=1:2:numel(varargin)
    eval([varargin{k} '= varargin{' int2str(k+1) '};'])
end
hasdP=exist('dP','var') & ~isempty(dP);
% field names to display
if(~exist('fieldName','var'))    
    fieldName=fieldnames(P);
end
% rescale diplay values
if(exist('scale'))
   for k=1:2:numel(scale)
      P.(scale{k})= P.(scale{k})*scale{k+1};
      if(hasdP)
          dP.(scale{k})= dP.(scale{k})*scale{k+1};
      end
   end
end
% units 
fieldUnit=cell2struct(cell(1,numel(fieldName)),fieldName,2);
if(exist('units','var'))
    for k=1:2:numel(units)
        fieldUnit.(units{k})=units{k+1};
    end
end
    
% maximum fieldname width
nameWidth=length(fieldName{1});
for k=2:length(fieldName)
   nameWidth=max(nameWidth,length(fieldName{k})); 
end
nameFormat=['%' int2str(nameWidth) 's']; % format string for field names

for f=1:numel(fieldName)
    for r=1:size(P.(fieldName{f}),1)
       % first column: field names
       if(r==1)
           fprintf([nameFormat ' : '],fieldName{f})
       else
           fprintf([nameFormat ' : '],'')
       end
       % actual numbers
       if(~hasdP)
           fprintf(['%' numFormat ' '],P.(fieldName{f})(r,:));
       else
          for c=1:size( P.(fieldName{f}),2)
              fprintf(['%' numFormat ' +- ' '%-' numFormat ' '],P.(fieldName{f})(r,c),dP.(fieldName{f})(r,c));
          end
       end
       
       % units (if any)
       fprintf(' %s',fieldUnit.(fieldName{f}))
       % new line
       fprintf('\n')
    end
end

