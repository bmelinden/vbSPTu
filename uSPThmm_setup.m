function uSPThmm_setup()
% set new random seed
rng('shuffle')
% add uncertainSPT to the matlab path
dir0=fileparts(mfilename('fullpath'));% path to this file, even if called from other folder
addpath(dir0)
addpath(fullfile(dir0,'tools'))
addpath(fullfile(dir0,'gui'))
addpath(fullfile(dir0,'HMMcore'))
disp('Added local uSPThmm paths from')
disp(dir0)
disp('-----------------------')
uSPTlicense('')
disp('-----------------------')
disp('to start the GUI, type usptGUI')
disp('-----------------------')
