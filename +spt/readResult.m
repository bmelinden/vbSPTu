function [R,opt]=readResult(runinput)
% [R,opt]=spt.readResult(runinput)
% load uSPTanalysis restuls, in the .mat file out.output.outputFile

% read runinput
opt=spt.readRuninputFile(runinput);
resultFile=fullfile(opt.runinputroot,opt.output.outputFile);
% look for output
if(exist(resultFile,'file'))
    R=load(resultFile);
else
    warning(['runinput file not found: ' opt.output.outputFile])
    R=struct;
end



