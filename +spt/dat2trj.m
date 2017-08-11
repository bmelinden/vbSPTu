function trj=dat2trj(i0,i1,x)
% trj=dat2trj(i0,i1,x)
% revert a prprocessed field to cell vector of individual trajectories. In
% a sense, this is the inverse of what spt.proprocess does to the x,v, and
% misc input, excpet that missing points at the beginning and end of each
% trajectory are not reinserted.
%
% i0,i1 : start- and end indices, as produced by spt.proprocess
% x     : the stacked trajectory representation, , as produced by
%         spt.proprocess 
%
% trj   : cell vector output, trj{k}=x(i0(k):i1(k),:)
%
% ML 2017-08-02

trj=cell(1,length(i0));
for k=1:numel(trj)
    trj{k}=x(i0(k):i1(k),:);
end
