function [R,opt,dat]=displayResults(runinput,varargin)
% [R,opt,dat]=YZShmm.displayResults(runinput,p1,v1,p2,v2,...)
%
% Display the results of YZShmm.runAnalysis in a standardized way
% 
% runinput : 1) name of runinput file, or
%            2) options struct, or
%            3) [] (in which case a runinput GUI asks for a runinput file)
% p1,v1,p2,v2,...
% Optional parameter-value pairs passed on to the displayStruct function,
% as applied to the estimated model parameters. 
% 
% Example: convert D from nm^"/S to um^2/s, and display units of D, RMNerr
% and dwellTime:
% ...,'scale',{'D',1e-6},'units',{'D','um2/s','RMSerr','nm','dwellTime','s'}) 

% get a runinput file is not given
if(~exist('runinput','var') || isempty(runinput))
    
    [filename, pathname, filterindex] = uigetfile( ...
        {'*.m','(*.m)'}, ...
        'Pick a runinput file', 'runinput.m');
    if(filterindex<=0 && ~exist(fullfile(pathname,filename),'file') )
        disp('Runinput file not found, or no runinput file selected.')
        return
    end
    runinput=fullfile(pathname,filename);
end
        
% read options
opt=spt.readRuninputFile(runinput);        
        
% read analysis results
R=YZShmm.readResult(opt);

%% read data
dat=spt.preprocess(runinput);

% display rough analysis and data parameters
disp('------------------------------------------------------------')
disp(['model    : ' opt.model.class ', ' int2str(sum(dat.T-1)) ' steps, ' ...
    int2str(R.Wbest.numStates) ' states, ' int2str(R.Wbest.sample.dim) 'd.'])
disp(['runinput : ' opt.runinputfile ' in ' opt.runinputroot])
disp(['results  : ' opt.output.outputFile ' in ' opt.runinputroot])
disp('------------------------------------------------------------')

%% display model parameters
if(opt.modelSearch.MLEparam)
    disp('MLE parameters : ')
else
    disp('VB parameters : ')
end
Pest=R.Pbest;
vars=fieldnames(Pest);
vars=setdiff(vars,'dwellSteps');
if(isfield(R,'PbestBSstd'))
    dPest=R.PbestBSstd;
    displayStruct(Pest,'dP',dPest,'fieldName',vars,'numFormat','6.2f',varargin{:})
else
    displayStruct(Pest,'scale','fieldName',vars,'numFormat','6.2f',varargin{:})
end
disp('------------------------------------------------------------')
%% plot transition rates
A0=R.Pbest.A-diag(diag(R.Pbest.A)); % transition matrix, off-diagonal part
G=digraph(A0);
LW=G.Edges.Weight;

% reduce number of significant digits in transition weights and diffusion
% constants
figure(201)
GP=plot(G,'linewidth',10*LW/max(LW),'edgelabel',LW,...
    'nodelabel',R.Pbest.D);
title('diffusive states and transition probabilities')
% improve some lables
N=size(A0,1);
nd=3; % number of digits in the labels
for k=1:N
   GP.NodeLabel{k}=['D' int2str(k) '=' num2str(R.Pbest.D(k),nd)];
end

ne=0;
for r=1:N
    for c=1:N
        if(A0(r,c)>0) % then a node exists
            ne=ne+1;
            GP.EdgeLabel{ne}=num2str(A0(r,c),nd);
        
        end
    end
end
axis off
%% plot model selection
NN=1:R.opt.modelSearch.maxHidden;
leg={};
h=[];
figure(200)
clf
leg{1}='VB';

if(R.opt.bootstrap.modelSelection)
    subplot(2,1,1)
    h(1)=errorbar(NN,R.VB_dlnL,R.VB_dlnLstdErr,'-k.');
else
    h(1)=plot(NN,R.VB_dlnL,'.k-');
end
hold on
if(R.opt.modelSearch.PBF)
    leg{2}='PBF';
    h(2)=errorbar(NN,R.PBF_dlnL,R.PBF_dlnLstdErr,'bs-');
end
xlabel('states')
ylabel('\DeltalnL')
legend(leg)
grid on
title('model selection score')

if(R.opt.bootstrap.modelSelection)
    subplot(2,1,2)
    hold on
    [a,~]=hist(R.NVBbs,NN);
    bar(NN,a/sum(a),1,'edgecol','none','facecol','k')
    if(R.opt.modelSearch.PBF)
        [a,~]=hist(R.NPBFbs,NN);
        bar(NN,a/sum(a),0.8,'edgecol','none','facecol','b')
    end
    xlabel('states')
    ylabel('freq.')
    legend(leg)
    title('bootstrapped #states')
    box on
end
    
end
