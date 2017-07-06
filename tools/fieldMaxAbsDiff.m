function sd=fieldMaxAbsDiff(s1,s2)
% sd=fieldMaxAbsDiff(s1,s2)
% compute maximum absolute difference in all subfields of the structs
% s1,s2, and put results in struct sd

fname=union(fieldnames(s1),fieldnames(s2));
sd=struct;
for n=1:numel(fname)
    fn=fname{n};
    if(isfield(s1,fn) && isfield(s1,fn))
        sd.(fn)=max(max(abs(s1.(fn)-s2.(fn))));
    else
        sd.(fn)=nan;
    end    
end
