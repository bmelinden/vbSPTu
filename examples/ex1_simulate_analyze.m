% this script illustrates how to
% 1) generate a small simulated data set,
% 2) visulize some data characteristics
% 3) run standard VB analysis on it. NOTE: this takes some time (up to 30
%    min on Intel(R) Xeon(R) CPU E5-2630 0 @ 2.30GHz). To save time,
%    execute block by block and skip the block 
%    '%% running the standard ananlysis specified in the runinput file'.
%    (precomputed results are included).
% 4) run the standard model visualization
%
% Steps 2-4 can also be done from usptGUI, by
% 1) loading the runinput file ex1_runinput_file
% 2) using the 'Trj lengths', 'est. RMSE', and 'D filter' buttons in the GUI.
% 3) 'save and Run' button
% 4) 'show results' button
%
% ML 2018-03-14
clear
% set up paths (need only be done once per matlab session)
addpath ..
uSPThmm_setup
%% parameters and data
% load runinput file (prepared with usptGUI)
opt=spt.readRuninputFile('ex1_runinput_file');
savefile=opt.trj.inputfile; % write simulated data to the correct file

% simulation parameters
p0=ones(3,1)/3;
pE=0; % no specific trj ending probabilities, -> trajectories exp-distributed

D=[0.1 3 6]*1e6;    % diffusion coefficients
A=[0.95   0  0.05 ; % transition matrix, mean dwell time 20*dt
   0.05 0.95  0   ;
   0   0.05  0.95];
dt=5e-3; % time steps
tE=1.5e-3; % exposure time

tau   =tE/dt/2; % shutter mean 
Rcoeff=tE/dt/6; % blur coefficient
pM=0.03;        % fraction of missing data

% random localization errors
RMSmean=[10 12 15]; % diffusive SNR >~ 2 for all states
RMSstd =[4 5 6];

Ttrj=25; % average raw trajectory length
Tmin=5;  % minimum traj length cut-off
Ntrj=100;
dim=2;
T=Tmin+round(-Ttrj*log(rand(1,Ntrj))); % exp-distributed trajectory lengths >= 5

[x,v,s,y,z]=spt.diffusiveHMM_blur_detach(p0,A,pE,D*dt,tE/dt,RMSmean,RMSstd,3,T,numel(T),pM);
save(savefile);
disp('trajectories + errors complete')
%% plot some data charateristics 
% this is the commandline variants of buttons in the GUI:
%'Trj lengths' : 
spt.trjLength_hist(opt,1);
% 'est. RMSE'  :
spt.RMSE_hist(opt,2);
%'D filter' in the GUI.
spt.D_lin_log_hist(opt,3);
%% running the standard ananlysis specified in the runinput file
YZShmm.runAnalysis(opt);
%% standard visualization of results
opt=spt.readRuninputFile('ex1_runinput_file');
YZShmm.displayResults(opt);
%% display parameters of the best model from the VB search
R=YZShmm.readResult(opt); % result of analysis
X=spt.preprocess(opt);    % preprocess data

disp('---')
disp('Manually displayed parameters:')
% extract and display parameters
W=R.model.clone(); % best model from VB model search
P=W.getParameters(X,'vb'); % vb inference of parameters
dP=R.bootstrap.paramStdErr;
displayStruct(P,'dP',dP,'scale',{'D',1e-6},'units',{'D','um2/s','dwellTime','s'},...
    'excludeField',{'Dmode','dwellSteps'});





