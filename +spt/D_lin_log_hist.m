function [Dmv,figH]=D_lin_log_hist(opt,figNum)
% Dmv=spt.D_lin_log_hist(opt,figNum)
% Plot histograms of D and log(D) based on parameters in the options struct
% opt.
% Dmv   : cell vector of running average diffusion const. estimates, using
%         window radii opt.modelSearch.YZww
% figH  : handle to the figure in which the histograms are plotted.

if(isfield(opt,'trj') ...
        && isfield(opt.trj,'inputfile') && exist(opt.trj.inputfile,'file')  ...
        && isfield(opt.trj,'trajectoryfield') && ~isempty(opt.trj.trajectoryfield) ...
        && isfield(opt,'modelSearch') && isfield(opt.modelSearch,'YZww') ...
        && ~isempty(opt.modelSearch.YZww)...
        && isfield(opt.trj,'timestep') && ~isempty(opt.trj.timestep) ...
        && isfield(opt.trj,'shutterMean') && ~isempty(opt.trj.shutterMean) ...
        && isfield(opt.trj,'blurCoeff') && ~isempty(opt.trj.blurCoeff))
    
    try
        X=spt.preprocess(opt);
    catch me
        me
        errordlg('Something went wrong when processing input data.')
        return
    end
    YZww=opt.modelSearch.YZww;
    disp('Running D filter ')
    Dmv=cell(size(YZww));
    parfor k=1:numel(YZww)
        tk=tic;
        if(isfield(X,'v') && ~isempty(X.v))
            [~,Dmv{k}]=mleYZdXt.YZinitMovingAverage(X,YZww(k),3e-2,opt.trj.shutterMean,opt.trj.blurCoeff,opt.trj.timestep);
        else
            [~,Dmv{k}]=mleYZdXs.YZinitMovingAverage(X,YZww(k),3e-2,opt.trj.shutterMean,opt.trj.blurCoeff,opt.trj.timestep);
        end
        disp(['window radius ' int2str(YZww(k)) ' completed in ' num2str(toc(tk),2) ' s.' ])

    end

    % plot histogram
    if(exist('figNum','var'))
        figH=figure(figNum);
    else
        figH=figure;
    end
    clf
    col='krbm';    
    leg={}; 
    
    subplot(2,1,1)
    hold on
    for k=1:numel(YZww)
        [a,b]=hist(Dmv{k},50);
        nc=mod(k-1,numel(col))+1;
        stairs(b-0.5*mean(diff(b)),a/sum(a)/mean(diff(b)),'k-','color',col(nc))
        leg{k}=['radius ' int2str(YZww(k))];
    end
    xlabel('D [length^2/time]')
    ylabel('p(D) [time/length^2]')
    box on
    legend(leg,'location','best')
    
    subplot(2,1,2)
    hold on
    for k=1:numel(YZww)
        [a,b]=hist(log(Dmv{k}),50);
        nc=mod(k-1,numel(col))+1;
        stairs(exp(b-0.5*mean(diff(b))),a/sum(a)/mean(diff(b)),'k-','color',col(nc))
    end
    set(gca,'xscale','log')
    xlabel('D [length^2/time]')
    ylabel('p(log D)')
    legend(leg,'location','best')
    box on
    
else
    errordlg('Need input file, trajectory variable, timestep, shutterMean, and R for this plot')
end
