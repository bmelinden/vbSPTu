function uSPThmm_setup()
% add uncertainSPT to the matlab path

dir0=fileparts(mfilename('fullpath'));% path to this file, even if called from other folder
addpath(dir0)
addpath(fullfile(dir0,'tools'))
addpath(fullfile(dir0,'HMMcore'))
disp('Added local uSPThmm paths from')
disp(dir0)
disp('-----------------------')
% set new random seed
rng('shuffle')