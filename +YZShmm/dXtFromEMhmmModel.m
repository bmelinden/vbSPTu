function W=dXtFromEMhmmModel(Whmm,data,opt)
% W = YZShmm.dXtFromEMhmmModel(Whmm,data,opt)
% create and MLE-converge new dXt model from a (converged) EMhmm model. 
%
% Whmm  : input EMhmm model (from the uncertainSPT suite).
% data  : pre-processed data struct, same as used for Whmm
% opt   : options struct with settings for the new model

% input parameters
Phmm=EMhmm.parameterEstimate(Whmm,opt.trj.timestep);

% create new model object
W=YZShmm.dXt(Whmm.N,opt,data,Phmm.p0,Phmm.D,Phmm.A);
% transfer Whmm model parameters
W.S=Whmm.S;
W.YZiter(data,'mle');
W.converge(data,'itype','mle','PSYfixed',2,'displayLevel',0,'Dsort',false);
W.converge(data,'itype','mle','PSYwarmup',[0 0 0],'displayLevel',0,'Dsort',false);
