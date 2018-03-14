
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

%% plot segmentation 
% compute segmentations:
% sMaxP : sequence of most likely states
% sVit  : most likely sequence of states (Viterbi path)
[~,~,sMaxP,sVit]=W.Siter(X,'vb');

sVit=double(sVit); % originallt int32
sVit(sVit==0)=nan; % do not plot space between trajectories
sMaxP=double(sMaxP); % originallt int32
sMaxP(sMaxP==0)=nan; % do not plot space between trajectories

% true hidden state sequence, from simulation. The point of this exercise
% is to get it to the same format
op2=opt;
op2.trj.miscfield='s'; % preprocess true hidden states along the data
X2=spt.preprocess(op2);
sTrue=X2.misc.s;
sTrue(sTrue==0)=nan;

%% plot hidden states of the best model
R=YZShmm.readResult(opt); % get the results from the analysis
figure(20)
clf
hold on

% make non-assigned states nan
stairs(sVit ,'k-','linewidth',3)
stairs(sMaxP,'b-','linewidth',2)
stairs(sTrue,'r-','linewidth',1)

legend('viterbi path','argmax p(s_t)','truth')

xlim([0 500])
ylim([0.5 3.5])

box on
xlabel('time step')
ylabel(' s(t)')
title('hidden state segmentation')

