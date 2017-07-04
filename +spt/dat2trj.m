function trj=dat2trj(i0,i1,x)

trj=cell(1,length(i0));
for k=1:numel(trj)
    trj{k}=x(i0(k):i1(k),:);
end
