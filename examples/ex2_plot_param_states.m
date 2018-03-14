% illustrate how to plot parameters and hidden state sequences

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
sMaxP=double(sMaxP); % originallt int32

% true hidden state sequence, from simulation. The point of this exercise
% is to get it to the same format
op2=opt;
op2.trj.miscfield='s'; % preprocess true hidden states along the data
X2=spt.preprocess(op2);
sTrue=X2.misc.s;

%% plot hidden states of the best model
R=YZShmm.readResult(opt); % get the results from the analysis

sTrue(X2.misc.s==0)=nan;
sVit(sVit==0)=nan; % do not plot space between trajectories
sMaxP(X2.misc.s==0)=nan; % do not plot space between trajectories

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

%% plot segmentation as diffusion constant vs time

Dest=W.getParameters(X,'vb').D*1e-6; % units of um2/s
Dtrue=D*1e-6; % parameter used in simulation

Dest_av=W.S.pst*Dest'; % posterior average diffusion constant
Dest_av(X2.misc.s==0)=nan;

D1=[Dtrue nan]; % add an extra D=nan state to the gaps between trajectories
sTrue(X2.misc.s==0)=4;
Dest1=[Dest nan];
sVit(X2.misc.s==0)=4;

figure(21)
clf
hold on

stairs(Dest1(sVit),'k-','linewidth',3)
stairs(Dest_av    ,'b-','linewidth',2)
stairs(D1(sTrue)  ,'r-','linewidth',1)

legend('D(s_t viterbi)','<D(t)>','truth')

xlim([0 500])
ylim([-0.5 6.5])

box on
xlabel('time step')
ylabel(' s(t)')
title('hidden state segmentation')


