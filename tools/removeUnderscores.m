function str=removeUnderscores(str)
% replace underscores _ in a string with \_, so that they display as
% underscores by e.g. the title command.

%str(str=='_')=' ';
ind=find(str=='_');
for j=numel(ind):-1:1
   str=[str(1:ind(j)-1) '\_' str(ind(j)+1:end)]; 
end
