% update internal opt struct and GUI strings
function updateGUIoptions(hObject,newOpt)

data=guidata(hObject);
opt=data.opt; % current options

% hard-coded GUI defaults
opt.modelSearch.Pwarmup=10;
opt.trj.miscfield={};
opt.prior.initialState.type = 'flat';

% update the options and corresponding GUI settings
%
% assumptions : do not pass empty or incomplete options, rahter omit the
% fields altogether in those cases
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
    if( ~isfield(opt,'trj') || ~isfield(opt.trj,'inputfile') ...
            || ~strcmp(inFile,opt.trj.inputfile) ) % then the file needs updating
        opt.trj.inputfile=inFile;
        set(data.input_file_name,'String',inStr);
        % populate popup menus
        matObj=matfile(opt.trj.inputfile);
        w=whos(matObj);
        
        ind= strcmp({w.class},'cell');
        vn={'',w(ind).name};
        set(data.trajectory_popup,'String',vn)
        set(data.trajectory_popup,'Value',1)
        set(data.uncertainty_popup,'String',vn)
        set(data.uncertainty_popup,'Value',1)
    end
end

% position variable
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'trajectoryfield') )
    % find
    trjValue=find(strcmp(get(data.trajectory_popup,'String'),newOpt.trj.trajectoryfield));
    if(isempty(trjValue)) % if the choosen field is not in the list of ceel vectors from the input file
        trjValue=1; % 1 means no variable in this case
    end
    set(data.trajectory_popup,'Value',trjValue);
    contents = cellstr(get(data.trajectory_popup,'String'));
    trjVar=contents{trjValue};
    opt.trj.trajectoryfield=trjVar;
end

% uncertainty variable
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'uncertaintyfield') )
    % find
    uncValue=find(strcmp(get(data.uncertainty_popup,'String'),newOpt.trj.uncertaintyfield));
    if(isempty(uncValue)) % if the choosen field is not in the list of ceel vectors from the input file
        uncValue=1;
    end
    set(data.uncertainty_popup,'Value',uncValue);
    contents = cellstr(get(data.uncertainty_popup,'String'));
    uncVar=contents{uncValue};
    opt.trj.uncertaintyfield=uncVar;
end

% dimensions 
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'dim') )
    opt.trj.dim=newOpt.trj.dim;
    set(data.dim_edit,'String',int2str(opt.trj.dim));
end

% minimum trajectory length 
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'Tmin') )
    opt.trj.Tmin=newOpt.trj.Tmin;
    set(data.trj_min_length_edit,'String',int2str(opt.trj.Tmin));
end

% timestep
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'timestep') )
    opt.trj.timestep=newOpt.trj.timestep;
    set(data.timestep_edit,'String',num2str(opt.trj.timestep));
end

% shutter mean 
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'shutterMean') )
    opt.trj.shutterMean=newOpt.trj.shutterMean;
    set(data.shutter_mean_edit,'String',num2str(opt.trj.shutterMean));
end

% Berglund blur coefficient R
if( isfield(newOpt,'trj') && isfield(newOpt.trj,'blurCoeff') )
    opt.trj.blurCoeff=newOpt.trj.blurCoeff;
    set(data.R_edit,'String',num2str(opt.trj.blurCoeff));
end
%% output
if( isfield(newOpt,'output') && isfield(newOpt.output,'outputFile') )
    if(isfield(newOpt,'runinputroot'))
        % runinputroot only exists if newOpt is just read from a file
        outFile=fullfile(newOpt.runinputroot,newOpt.output.outputFile);
    else
        % if output.outputFile is unchanged or generated by the user, it
        % will be an absolute path
        outFile=newOpt.output.outputFile;
    end        
    opt.output.outputFile=outFile;
    if(numel(outFile)>80)
        outStr=['...' outFile(end-80:end)];
    else
        outStr=outFile;
    end    
    set(data.output_file_text,'String',num2str(outStr));
end
%% convergence criteria
% maximum number of iterations
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'maxIter') )
    % input file given relative to the runinput file location
    opt.conv.maxIter=newOpt.conv.maxIter;
    set(data.maxIter_edit,'String',int2str(opt.conv.maxIter));
end
% lnL tolerance
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'lnLTol') )
    % input file given relative to the runinput file location
    opt.conv.lnLTol=newOpt.conv.lnLTol;
    set(data.lnLTol_edit,'String',num2str(opt.conv.lnLTol));
end
% parameter tolerance
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'parTol') )
    % input file given relative to the runinput file location
    opt.conv.parTol=newOpt.conv.parTol;
    set(data.parTol_edit,'String',num2str(opt.conv.parTol));
end
% save workspace in case of errors
if( isfield(newOpt,'conv') && isfield(newOpt.conv,'saveErr') )
    % input file given relative to the runinput file location
    opt.conv.saveErr=newOpt.conv.saveErr;
    set(data.saveErr_box,'Value',opt.conv.saveErr);
end
%% VB search parameters
% VB search number of restarts
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'restarts') )
    opt.modelSearch.restarts=newOpt.modelSearch.restarts;
    set(data.restarts_edit,'String',int2str(opt.modelSearch.restarts));
end
% VB search initial number of states
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'VBinitHidden') )
    opt.modelSearch.VBinitHidden=newOpt.modelSearch.VBinitHidden;
    set(data.VBinitStates_edit,'String',int2str(opt.modelSearch.VBinitHidden));
end
% maximum number of states to consider
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'maxHidden') )
    opt.modelSearch.maxHidden=newOpt.modelSearch.maxHidden;
    set(data.maxHidden_edit,'String',int2str(opt.modelSearch.maxHidden));
end
% set of averaging radii to use for initial guess
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'YZww') )
    opt.modelSearch.YZww=newOpt.modelSearch.YZww;
    set(data.YZww_edit,'String',int2str(opt.modelSearch.YZww));
end
% compute pseudo-Bayes factors
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'PBF') )
    opt.modelSearch.PBF=newOpt.modelSearch.PBF;
    set(data.PBF_model_select_button,'Value',opt.modelSearch.PBF);
end
% compute maximum likelihood estimate (MLE) of best model parameters
if( isfield(newOpt,'modelSearch') && isfield(newOpt.modelSearch,'MLEparam') )
    opt.modelSearch.MLEparam=newOpt.modelSearch.MLEparam;
    set(data.MLE_parameters_button,'Value',opt.modelSearch.MLEparam);
end
%% bootstrap
% bootstrap best model parameters
if( isfield(newOpt,'bootstrap') && isfield(newOpt.bootstrap,'bestParam') )
    opt.bootstrap.bestParam=newOpt.bootstrap.bestParam;
    set(data.bootstrap_param_box,'Value',opt.bootstrap.bestParam);
end
% bootstrap model selection
if( isfield(newOpt,'bootstrap') && isfield(newOpt.bootstrap,'modelSelection') )
    opt.bootstrap.modelSelection=newOpt.bootstrap.modelSelection;
    set(data.bootstrap_model_box,'Value',opt.bootstrap.modelSelection);
end
% number of bootstrap samples
if( isfield(newOpt,'bootstrap') && isfield(newOpt.bootstrap,'bootstrapNum') )
    opt.bootstrap.bootstrapNum=newOpt.bootstrap.bootstrapNum;
    set(data.bootstrap_samples_edit,'String',int2str(opt.bootstrap.bootstrapNum));
end
%% model
% model class
if( isfield(newOpt,'model') && isfield(newOpt.model,'class') )
    models = cellstr(get(data.model_class_menu,'String'));
    modInd=find(strcmp(newOpt.model.class,models),1);    
    if(isempty(modInd)) % then there was something wrong with the new model    
        % 1) try to reset to old model
        if( isfield(opt,'model') && isfield(opt.model,'class'))
            modInd=find(strcmp(opt.model.class,models),1);
        end            
        % 2) set to the empty choice
        if(isempty(modInd))
            modInd=1;
        end
    end
    opt.model.class=models{modInd};
    set(data.model_class_menu,'Value',modInd);
end
%% prior
% diffusion prior
if( isfield(newOpt,'prior')  && isfield(newOpt.prior,'diffusionCoeff')  ...
        && isfield(newOpt.prior.diffusionCoeff,'type'))
    if(~strcmp(newOpt.prior.diffusionCoeff.type,'median_strength') )
        warning(['GUI cannot handle prior.diffusionCoeff.type = ' newOpt.prior.diffusionCoeff.type '. Ignoring.'])
    else
        % the prior is understood!
        opt.prior.diffusionCoeff.type='median_strength';
        
        % median value
        if( isfield(newOpt.prior.diffusionCoeff,'D') )
            opt.prior.diffusionCoeff.D=newOpt.prior.diffusionCoeff.D;
            set(data.Dprior_median_edit,'String',num2str(opt.prior.diffusionCoeff.D));
        end
        
        % strength
        if( isfield(newOpt.prior.diffusionCoeff,'strength') )
            opt.prior.diffusionCoeff.strength=newOpt.prior.diffusionCoeff.strength;
            set(data.Dprior_strength_edit,'String',num2str(opt.prior.diffusionCoeff.strength));
        end
    end
end
% mean dwell time prior
if( isfield(newOpt,'prior')  && isfield(newOpt.prior,'transitionMatrix')  ...
        && isfield(newOpt.prior.transitionMatrix,'type'))
    if(~strcmp(newOpt.prior.transitionMatrix.type,'dwell_Bweight') )
        warning(['GUI cannot handle prior.transitionMatrix.type = ' newOpt.prior.transitionMatrix.type '. Ignoring.'])
    else
        opt.prior.transitionMatrix.type='dwell_Bweight';
        % mean dwell time mean
        if( isfield(newOpt.prior.transitionMatrix,'dwellMean') )
            opt.prior.transitionMatrix.dwellMean=newOpt.prior.transitionMatrix.dwellMean;
            set(data.Tprior_mean_edit,'String',num2str(opt.prior.transitionMatrix.dwellMean));
        end
        % mean dwell time std
        if( isfield(newOpt.prior.transitionMatrix,'dwellStd') )
            opt.prior.transitionMatrix.dwellStd=newOpt.prior.transitionMatrix.dwellStd;
            set(data.Tprior_std_edit,'String',num2str(opt.prior.transitionMatrix.dwellStd));
        end
        % B-weight
        if( isfield(newOpt.prior.transitionMatrix,'Bweight') )
            opt.prior.transitionMatrix.Bweight=newOpt.prior.transitionMatrix.Bweight;
            set(data.Bprior_weight_edit,'String',num2str(opt.prior.transitionMatrix.Bweight));
        end
    end
end
% localization error prior
if( isfield(newOpt,'prior')  && isfield(newOpt.prior,'positionVariance')  ...
        && isfield(newOpt.prior.positionVariance,'type'))
    if(~strcmp(newOpt.prior.positionVariance.type,'median_strength') )
        warning(['GUI cannot handle prior.positionVariance.type = ' newOpt.prior.positionVariance.type '. Ignoring.'])
    else
        opt.prior.positionVariance.type='median_strength';
        % median value
        if( isfield(newOpt.prior.positionVariance,'v') )
            opt.prior.positionVariance.v=newOpt.prior.positionVariance.v;
            set(data.Vprior_median_edit,'String',num2str(opt.prior.positionVariance.v));
        end
        % strength
        if( isfield(newOpt.prior.positionVariance,'strength') )
            opt.prior.positionVariance.strength=newOpt.prior.positionVariance.strength;
            set(data.Vprior_strength_edit,'String',num2str(opt.prior.positionVariance.strength));
        end
    end
end
%% initial guess for parameters
% initial guess range for D
if( isfield(newOpt,'init') && isfield(newOpt.init,'Drange') )
    R1=newOpt.init.Drange;
    opt.init.Drange=R1;
    set(data.Dinit_range_edit,'String',num2str(R1));
end
% initial guess range for mean dwell time
if( isfield(newOpt,'init') && isfield(newOpt.init,'Trange') )
    R1=newOpt.init.Trange;
    opt.init.Trange=R1;
    set(data.Tinit_range_edit,'String',num2str(R1));
end
%% save new options as guidata
%data=guidata(hObject); % reload newest guidata 
data.opt=opt;
guidata(hObject,data);