function [absDiff,relDiff]=maxAbsDiffSubfield(s1,s2)
% [absDiff,relDiff]=maxAbsDiffSubfield(s1,s2)
% compute maximum absolute and relative difference in all subfields of the
% structs s1,s2.

fname=union(fieldnames(s1),fieldnames(s2));
absDiff=struct;
relDiff=struct;
for n=1:numel(fname)
    fn=fname{n};
    if(isfield(s1,fn) && isfield(s1,fn))
        absDiff.(fn)=max(max(abs(s1.(fn)-s2.(fn))));
        relDiff.(fn)=max(max(abs(s1.(fn)-s2.(fn))./abs(s1.(fn)+s2.(fn))*2));
    else
        absDiff.(fn)=nan;
        relDiff.(fn)=nan;
    end    
end
