function dP=bootstrapStd(P)
% spt.dP=bootstrapStd(P)
%
% Compute standard deviation along dimension 3 of all fields in P. This is
% intended for use with parameter structs from YZShmm.bootstrap, where
% bootstrap parameters are stored in dimension 3.

fn=fieldnames(P);
dP=struct;
for f=1:numel(fn)
    V=P.(fn{f});
    if(size(V,3)<=1)
        warning(['Field ' fn{f} ' is of size 1 in dimension 3. No bootstrapStd computed.'])
    else
        dP.(fn{f})=std(V,[],3);
    end
end