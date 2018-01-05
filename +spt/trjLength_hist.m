function [T,figH]=trjLength_hist(opt,figNum)
% [RMSE,figH]=spt.trjLength_hist(opt,figNum)
% Plot a simple histogram of trajectory lengths in the data set specified
% by the options struct opt.
% 
% opt   : options struct, e.g., from spt.readRuninputFile
% figNum: (optional) figure number in which to plot (figure is cleared). 
%
% T     : array with trajectory lengths (number of position points,
% including missing positions) in the the input data specified by opt.
% figH  : handle to the figure in which the histogram is plotted
%
% ML 2017-11-02

if(isfield(opt,'trj') && isfield(opt.trj,'inputfile') ...
        && exist(opt.trj.inputfile,'file') ...
        && isfield(opt.trj,'trajectoryfield') && ~isempty(opt.trj.trajectoryfield) )
    
    try
        X=spt.preprocess(opt);
    catch me
        me
        errordlg('Something went wrong when processing uncertainty data.')
        return
    end
    % plot histogram
    if(exist('figNum','var'))
        figH=figure(figNum);
    else
        figH=figure;
    end
    clf
    Tbin=2.5;
    [a,b]=hist(X.T,opt.trj.Tmin+Tbin/2:Tbin:(Tbin+max(X.T)));%min(50,ceil(numel(X.T)/5)));%ceil(numel(X.T)/5));
    
    bar(b,a/sum(a)/mean(diff(b)),1,'facecolor','k','edgecol','none')
    xlabel('trj. length / \Deltat')
    ylabel('pdf [length^{-1}]')
    
    numT =numel(X.T);
    meanT=mean(X.T);
    totT =sum(X.T);
    
    title(sprintf('%d position points in %d trjs, average %.1f pos./trj.',totT,numT,meanT))
    
else
    errordlg('Need input file + trajectory variable for this plot')
end
