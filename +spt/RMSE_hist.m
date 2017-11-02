function [RMSE,figH]=RMSE_hist(opt,figNum)
% [RMSE,figH]=spt.RMSE_hist(opt,figNum)
% Plot a simple histogram of (estimated) root-mean-square errors (RMSE) in
% the data set specified by the options struct opt. 
% 
% opt   : options struct, e.g., from spt.readRuninputFile
% figNum: (optional) figure number in which to plot (figure is cleared). 
%
% RMSE  : array with RMSE values, as read from the input data specified by
%         opt.
% figH  : handle to the figure in which the histogram is plotted
%
% ML 2017-11-02

if(isfield(opt,'trj') ...
        && isfield(opt.trj,'inputfile') && exist(opt.trj.inputfile,'file')  ...
        && isfield(opt.trj,'trajectoryfield') && ~isempty(opt.trj.trajectoryfield) ...
        && isfield(opt.trj,'uncertaintyfield') && ~isempty(opt.trj.uncertaintyfield))
    
    try
        X=spt.preprocess(opt);
    catch me
        me
        errordlg('Something went wrong when processing input data.')
        return
    end
    RMSE=sqrt(X.v(:));
    RMSE=RMSE(isfinite(RMSE));
    
    % plot histogram
    if(exist('figNum','var'))
        figH=figure(figNum);
    else
        figH=figure;
    end
    clf
    [a,b]=hist(RMSE,50);
    
    bar(b,a/sum(a)/mean(diff(b)),1,'facecolor','k','edgecol','none')
    xlabel('RMSE [length]')
    ylabel('pdf [length^{-1}]')
else
    errordlg('Need input file + trajectory and precision variables for this plot')
end