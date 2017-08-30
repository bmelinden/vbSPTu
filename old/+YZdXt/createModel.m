function W=createModel(opt,X,N,p0_init,A_init,D_init,npc)
% W=createModel(opt,X,N,p0_init,A_init,D_init,npc)
% construct a YZdXt model with N states, based on data X and options opt.
% This is also a 'supercreator' for the other models, since they are
% really just extensions of the YZdXt model
%
% opt   : runinput options struct or runinput file name
% X     : preprocessed data struct
% N     : number of states
% 
% initial parameters : 
% D_init,A_init,p0_init : specify parameter mean values. Default: sample
%                         from the prior distributions.
% npc   : strength (number of pseudocounts) in the parameter distributions.
%         Default = number of steps in the data set.
%         
% Variational models for trajectories and hidden states are constructed
% based on the input data 

%% input parameters: make missing ones empty
for vv={'p0_init','A_init','D_init','npc'}
    if(~exist(vv{1},'var'))
       eval([ vv{1} '=[];'])
    end
end
% start with the basic model
W=uSPThmm.createModel(opt,X,N,p0_init,A_init,D_init,npc);
%% trajectory distribution
W.YZ=YZdXt.naiveYZfromData(X);
W.YZ.mean_lnqyz=0;
W.YZ.mean_lnpxz=0;
W.YZ.Fs_yz=0;
