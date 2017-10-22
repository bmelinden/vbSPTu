% update internal opt struct and GUI strings
function updateGUIoptions(hObject,newOpt)

data=guidata(hObject);
opt=data.opt; % current options

% update the options and corresponding GUI settings

%% input data 
% input file
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'inputfile') )
    % input file given relative to the runinput file location
    if(isfield(newOpt,'runinputroot'))
        inFile=fullfile(newOpt.runinputroot,newOpt.trj.inputfile);
    else
        inFile=newOpt.trj.inputfile;
    end
    
    if(numel(inFile)>80)
        inStr=['...' inFile(end-80:end)];
    else
        inStr=inFile;
    end
    if(~strcmp(inFile,opt.trj.inputfile)) % then the file was updated
        opt.trj.inputfile=inFile;
        set(data.input_file_name,'String',inStr);
        % populate popup menus
        matObj=matfile(opt.trj.inputfile);
        w=whos(matObj);
    
        ind=find(strcmp({w.class},'cell'));
        vn={'',w(ind).name};
        set(data.trajectory_popup,'String',vn)
        set(data.trajectory_popup,'Value',1)
        set(data.uncertainty_popup,'String',vn)
        set(data.uncertainty_popup,'Value',1)
    end
else
   warning('field trj.inputfile not found.')
end

% position variable
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'trajectoryfield') )
    % find
    trjValue=find(strcmp(get(data.trajectory_popup,'String'),newOpt.trj.trajectoryfield));
    if(isempty(trjValue)) % if the choosen field is not in the list of ceel vectors from the input file
        trjValue=1;
    end
    set(data.trajectory_popup,'Value',trjValue);
    contents = cellstr(get(data.trajectory_popup,'String'));
    trjVar=contents{get(hObject,'Value')};
    opt.trj.trajectoryfield=trjVar;
else
    warning('field trj.trajectoryfield not found.')
end

% uncertainty variable
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'uncertaintyfield') )
    % find
    trjValue=find(strcmp(get(data.uncertainty_popup,'String'),newOpt.trj.uncertaintyfield));
    if(isempty(trjValue)) % if the choosen field is not in the list of ceel vectors from the input file
        trjValue=1;
    end
    set(data.uncertainty_popup,'Value',trjValue);
    contents = cellstr(get(data.uncertainty_popup,'String'));
    trjVar=contents{get(hObject,'Value')};
    opt.trj.uncertaintyfield=trjVar;
else
   warning('field trj.uncertaintyfield not found.')
end

% dimensions 
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'dim') )
    opt.trj.dim=newOpt.trj.dim;
    set(data.dim_edit,'String',int2str(opt.trj.dim));
else
   warning('field trj.dim not found.')
end

% minimum trajectory length 
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'Tmin') )
    opt.trj.Tmin=newOpt.trj.Tmin;
    set(data.trj_min_length_edit,'String',int2str(opt.trj.Tmin));
else
   warning('field trj.Tmin not found.')
end

% timestep
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'timestep') )
    opt.trj.timestep=newOpt.trj.timestep;
    set(data.timestep_edit,'String',num2str(opt.trj.timestep));
else
   warning('field trj.Tmin not found.')
end

% shutter mean 
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'shutterMean') )
    opt.trj.shutterMean=newOpt.trj.shutterMean;
    set(data.shutter_mean_edit,'String',num2str(opt.trj.shutterMean));
else
   warning('field trj.shutterMean not found.')
end

% Berglund blur coefficient R
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'blurCoeff') )
    opt.trj.blurCoeff=newOpt.trj.blurCoeff;
    set(data.R_edit,'String',num2str(opt.trj.blurCoeff));
else
   warning('field trj.blurCoeff not found.')
end
%% output
if( isfield(newOpt,'output') && isfield(newOpt.output,'outputFile') )
    if(isfield(newOpt,'runinputroot'))
        outFile=fullfile(newOpt.runinputroot,newOpt.output.outputFile);
    else
        outFile=newOpt.output.outputFile;
    end        
    opt.output.outputFile=outFile;
    if(numel(outFile)>80)
        outStr=['...' outFile(end-80:end)];
    else
        outStr=outFile;
    end    
    set(data.output_file_text,'String',num2str(outStr));
else
   warning('field output.outputFile not found.')
end
%% convergence criteria
% maximum number of iterations
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'maxIter') )
    % input file given relative to the runinput file location
    opt.conv.maxIter=newOpt.conv.maxIter;
    set(data.maxIter_edit,'String',int2str(opt.conv.maxIter));
else
   warning('field conv.maxIter not found.')
end
% lnL tolerance
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'lnLTol') )
    % input file given relative to the runinput file location
    opt.conv.lnLTol=newOpt.conv.lnLTol;
    set(data.lnLTol_edit,'String',num2str(opt.conv.lnLTol));
else
   warning('field conv.lnLTol not found.')
end
% parameter tolerance
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'parTol') )
    % input file given relative to the runinput file location
    opt.conv.parTol=newOpt.conv.parTol;
    set(data.parTol_edit,'String',num2str(opt.conv.parTol));
else
   warning('field conv.parTol not found.')
end
% save workspace in case of errors
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'saveErr') )
    % input file given relative to the runinput file location
    opt.conv.saveErr=newOpt.conv.saveErr;
    set(data.saveErr_box,'Value',opt.conv.saveErr);
else
   warning('field conv.saveErr not found.')
end
%% VB search parameters
% VB search number of restarts
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'restarts') )
    opt.modelSearch.restarts=newOpt.modelSearch.restarts;
    set(data.restarts_edit,'String',int2str(opt.modelSearch.restarts));
else
   warning('field modelSearch.restarts not found.')
end
% VB search initial number of states
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'VBinitHidden') )
    opt.modelSearch.VBinitHidden=newOpt.modelSearch.VBinitHidden;
    set(data.VBinitStates_edit,'String',int2str(opt.modelSearch.VBinitHidden));
else
   warning('field modelSearch.VBinitHidden not found.')
end
% maximum number of states to consider
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'maxHidden') )
    opt.modelSearch.maxHidden=newOpt.modelSearch.maxHidden;
    set(data.maxHidden_edit,'String',int2str(opt.modelSearch.maxHidden));
else
   warning('field modelSearch.maxHidden not found.')
end
% set of averaging radii to use for initial guess
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'YZww') )
    opt.modelSearch.YZww=newOpt.modelSearch.YZww;
    set(data.YZww_edit,'String',int2str(opt.modelSearch.YZww));
else
   warning('field modelSearch.YZww not found.')
end
% compute pseudo-Bayes factors
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'PBF') )
    opt.modelSearch.PBF=newOpt.modelSearch.PBF;
    set(data.PBF_model_select_button,'Value',opt.modelSearch.PBF);
else
   warning('field modelSearch.PBF not found.')
end
% compute maximum likelihood estimate (MLE) of best model parameters
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'MLEparam') )
    opt.modelSearch.MLEparam=newOpt.modelSearch.MLEparam;
    set(data.MLE_parameters_button,'Value',opt.modelSearch.MLEparam);
else
   warning('field modelSearch.MLEparam not found.')
end
%% bootstrap
% bootstrap best model parameters
if( isfield(newOpt,'bootstrap') && isfield(newOpt.bootstrap,'bestParam') )
    opt.bootstrap.bestParam=newOpt.bootstrap.bestParam;
    set(data.bootstrap_param_box,'Value',opt.bootstrap.bestParam);
else
   warning('field bootstrap.bestParam not found.')
end
% bootstrap model selection
if( isfield(newOpt,'bootstrap') && isfield(newOpt.bootstrap,'modelSelection') )
    opt.bootstrap.modelSelection=newOpt.bootstrap.modelSelection;
    set(data.bootstrap_model_box,'Value',opt.bootstrap.modelSelection);
else
   warning('field bootstrap.modelSelection not found.')
end
% number of bootstrap samples
if( isfield(newOpt,'bootstrap') && isfield(newOpt.bootstrap,'bootstrapNum') )
    opt.bootstrap.bootstrapNum=newOpt.bootstrap.bootstrapNum;
    set(data.bootstrap_samples_edit,'String',int2str(opt.bootstrap.bootstrapNum));
else
   warning('field bootstrap.bootstrapNum not found.')
end
%% model
% model class
if( isfield(newOpt,'model') && isfield(newOpt.model,'class') )
    opt.model.class=newOpt.model.class;
    set(data.model_class_menu,'String',opt.model.class);
else
   warning('field model.class not found.')
end
%% prior
% diffusion prior
if( isfield(newOpt,'prior')  && isfield(newOpt.prior,'diffusionCoeff')  ...
        && isfield(newOpt.prior.diffusionCoeff,'type') ...
        && strcmp(newOpt.prior.diffusionCoeff.type,'median_strength') )
    % median value
    if( isfield(newOpt.prior.diffusionCoeff,'D') )
        newOpt.prior.diffusionCoeff.D=newOpt.prior.diffusionCoeff.D;
        set(data.Dprior_median_edit,'String',num2str(newOpt.prior.diffusionCoeff.D));
    end
    % strength
    if( isfield(newOpt.prior.diffusionCoeff,'strength') )
        newOpt.prior.diffusionCoeff.strength=newOpt.prior.diffusionCoeff.strength;
        set(data.Dprior_strength_edit,'String',num2str(newOpt.prior.diffusionCoeff.strength));
    end    
else
    warning('field prior.diffusionCoeff.type not found, or type not supported (median_strength).')
end
% mean dwell time prior
if( isfield(newOpt,'prior')  && isfield(newOpt.prior,'transitionMatrix')  ...
        && isfield(newOpt.prior.transitionMatrix,'type') ...
        && strcmp(newOpt.prior.transitionMatrix.type,'dwell_Bweight') )
    
    % mean dwell time mean
    if( isfield(newOpt.prior.transitionMatrix,'dwellMean') )
        opt.prior.transitionMatrix.dwellMean=newOpt.prior.transitionMatrix.dwellMean;
        set(data.Tprior_mean_edit,'String',num2str(newOpt.prior.transitionMatrix.dwellMean));
    else
        warning('field prior.transitionMatrix.dwellMean not found.')
    end
    % mean dwell time std
    if( isfield(newOpt.prior.transitionMatrix,'dwellStd') )
        opt.prior.transitionMatrix.dwellStd=newOpt.prior.transitionMatrix.dwellStd;
        set(data.Tprior_std_edit,'String',num2str(newOpt.prior.transitionMatrix.dwellStd));
    else
        warning('field prior.transitionMatrix.dwellStd not found.')
    end
    % B-weight
    if( isfield(newOpt.prior.transitionMatrix,'Bweight') )
        newOpt.prior.transitionMatrix.Bweight=newOpt.prior.transitionMatrix.Bweight;
        set(data.Bprior_weight_edit,'String',num2str(newOpt.prior.transitionMatrix.Bweight));
    else
        warning('field prior.transitionMatrix.Bweight not found.')
    end
else
    warning('field prior.transitionMatrix.type not found, or type not supported (dwell_Bweight).')
end
% localization error prior
if( isfield(newOpt,'prior')  && isfield(newOpt.prior,'positionVariance')  ...
        && isfield(newOpt.prior.positionVariance,'type') ...
        && strcmp(newOpt.prior.positionVariance.type,'median_strength') )
    % median value
    if( isfield(newOpt.prior.positionVariance,'v') )
        newOpt.prior.positionVariance.v=newOpt.prior.positionVariance.v;
        set(data.Vprior_median_edit,'String',num2str(newOpt.prior.positionVariance.v));
    end
    % strength
    if( isfield(newOpt.prior.positionVariance,'strength') )
        newOpt.prior.positionVariance.strength=newOpt.prior.positionVariance.strength;
        set(data.Vprior_strength_edit,'String',num2str(newOpt.prior.positionVariance.strength));
    end    
else
    warning('field prior.positionVariance.type not found, or type not supported (median_strength).')
end
%% initial guess for parameters
% initial guess range for D
if( isfield(newOpt,'init') && isfield(newOpt.init,'Drange') )
    opt.init.Drange=newOpt.init.Drange;
    set(data.Dinit_lower,'String',opt.init.Drange(1));
    set(data.Dinit_upper,'String',opt.init.Drange(2));
else
   warning('field init.Drange not found.')
end
% initial guess range for mean dwell time
if( isfield(newOpt,'init') && isfield(newOpt.init,'Trange') )
    opt.init.Trange=newOpt.init.Trange;
    set(data.Tinit_lower,'String',opt.init.Trange(1));
    set(data.Tinit_upper,'String',opt.init.Trange(2));
else
   warning('field init.Trange not found.')
end
%% save new options as guidata
%data=guidata(hObject); % reload newest guidata 
data.opt=opt;
guidata(hObject,data);
