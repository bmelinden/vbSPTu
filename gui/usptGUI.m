function varargout = usptGUI(varargin)
% usptGUI MATLAB code for usptGUI.fig
%      usptGUI, by itself, creates a new usptGUI or raises the existing
%      singleton*.
%
%      H = usptGUI returns the handle to a new usptGUI or the handle to
%      the existing singleton*.
%
%      usptGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in usptGUI.M with the given input arguments.
%
%      usptGUI('Property','Value',...) creates a new usptGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the usptGUI before usptGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to usptGUI_OpeningFcn via varargin.
%
%      *See usptGUI Options on GUIDE's Tools menu.  Choose "usptGUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help usptGUI

% Last Modified by GUIDE v2.5 03-Jan-2018 00:40:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @usptGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @usptGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before usptGUI is made visible.
function usptGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to usptGUI (see VARARGIN)

% Choose default command line output for usptGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
data=guidata(hObject);

data.opt=struct;
guidata(hObject,data);

% set some default options
[d0,~]=fileparts(mfilename('fullpath'));
opt=spt.readRuninputFile(fullfile(d0,'usptGUI_defaultOptions.m'));
updateGUIoptions(hObject,opt);


% UIWAIT makes usptGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = usptGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in input_file_button.
function input_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to input_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname, filterindex] = uigetfile( ...
    {'*.mat','(*.mat)'}, ...
    'Pick a data file', '');
if(filterindex>0 && exist(fullfile(pathname,filename),'file') )
    % read external runinput file
    inFile=fullfile(pathname,filename);
    % update internal options struct with newOpt
    data=guidata(hObject);
    data.opt.trj.inputfile=inFile;    
    updateGUIoptions(hObject,data.opt);
end

% --- Executes on button press in output_file_button.
function output_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to output_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname, filterindex] = uiputfile( ...
    {'*.mat','(*.mat)'}, ...
    'Select output file', '');
if(filterindex>0 )% && exist(fullfile(pathname,filename),'file') )
    % read external runinput file
    outFile=fullfile(pathname,filename);
    % update internal options struct with newOpt
    data=guidata(hObject);
    data.opt.output.outputFile=outFile;    
    updateGUIoptions(hObject,data.opt);
end

% --- Executes on selection change in trajectory_popup.
function trajectory_popup_Callback(hObject, eventdata, handles)
% hObject    handle to trajectory_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trajectory_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trajectory_popup

%warning('make the dropdown list look for variable names when clicked on?')
%ML: no, better to update the list when the input file is selected

contents = cellstr(get(hObject,'String'));
trjVar=contents{get(hObject,'Value')};
data=guidata(hObject);
data.opt.trj.trajectoryfield=trjVar;
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function trajectory_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trajectory_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in uncertainty_popup.
function uncertainty_popup_Callback(hObject, eventdata, handles)
% hObject    handle to uncertainty_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns uncertainty_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from uncertainty_popup
contents = cellstr(get(hObject,'String'));
uncVar=contents{get(hObject,'Value')};
data=guidata(hObject);
data.opt.trj.uncertaintyfield=uncVar;
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function uncertainty_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uncertainty_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function timestep_edit_Callback(hObject, eventdata, handles)
% hObject    handle to timestep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timestep_edit as text
%        str2double(get(hObject,'String')) returns contents of timestep_edit as a double

num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.trj.timestep=num;
    else
        errordlg('Timestep must be positive and finite.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function timestep_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timestep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R_edit_Callback(hObject, eventdata, handles)
% hObject    handle to R_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R_edit as text
%        str2double(get(hObject,'String')) returns contents of R_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0 && num<=1/6)     % ... and within the correct range
        data.opt.trj.blurCoeff=num;
    else
        errordlg('Blur coefficient must be in (0,1/6].')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function R_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function shutter_mean_edit_Callback(hObject, eventdata, handles)
% hObject    handle to shutter_mean_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shutter_mean_edit as text
%        str2double(get(hObject,'String')) returns contents of shutter_mean_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0 && num<=1/2)     % ... and within the correct range
        data.opt.trj.shutterMean=num;
    else
        errordlg('Shutter mean must be in (0,1)')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function shutter_mean_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shutter_mean_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function trj_min_length_edit_Callback(hObject, eventdata, handles)
% hObject    handle to trj_min_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trj_min_length_edit as text
%        str2double(get(hObject,'String')) returns contents of trj_min_length_edit as a double
num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num<0)     % ... and within the correct range
        num=0;
    end
    data.opt.trj.Tmin=num;
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function trj_min_length_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trj_min_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function dim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim_edit as text
%        str2double(get(hObject,'String')) returns contents of dim_edit as a double
num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and within the correct range
        data.opt.trj.dim=num;
    else
        errordlg('Dim must be integer >0.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function dim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in model_class_menu.
function model_class_menu_Callback(hObject, eventdata, handles)
% hObject    handle to model_class_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns model_class_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from model_class_menu
contents = cellstr(get(hObject,'String'));
M=contents{get(hObject,'Value')};

opt=struct;
opt.model.class=M;
updateGUIoptions(hObject,opt);

% --- Executes during object creation, after setting all properties.
function model_class_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_class_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% set default options for model classes
Mstr={'','YZShmm.dXt','YZShmm.dX'};
set(hObject,'String',Mstr);
set(hObject,'Value',1);


function Dprior_median_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Dprior_median_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dprior_median_edit as text
%        str2double(get(hObject,'String')) returns contents of Dprior_median_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and within the correct range
        data.opt.prior.diffusionCoeff.D=num;
        data.opt.prior.diffusionCoeff.type='median_strength';
    else
        errordlg('D prior median must be >0.')
    end
end
updateGUIoptions(hObject,data.opt);


% --- Executes during object creation, after setting all properties.
function Dprior_median_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dprior_median_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dprior_strength_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Dprior_strength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dprior_strength_edit as text
%        str2double(get(hObject,'String')) returns contents of Dprior_strength_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and within the correct range
        data.opt.prior.diffusionCoeff.strength=num;
        data.opt.prior.diffusionCoeff.type='median_strength';
    else
        errordlg('D prior strength must be >0.')
    end
end
updateGUIoptions(hObject,data.opt);


% --- Executes during object creation, after setting all properties.
function Dprior_strength_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dprior_strength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Tprior_mean_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Tprior_mean_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tprior_mean_edit as text
%        str2double(get(hObject,'String')) returns contents of Tprior_mean_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    try
        dt=data.opt.trj.timestep;
        if(num>=dt)     % ... and within the correct range
            data.opt.prior.transitionMatrix.dwellMean=num;
            data.opt.prior.transitionMatrix.type= 'dwellRelStd_Bweight';
        else
            errordlg('Prior mean dwell time must be > timestep.')
        end
    catch
        set(hObject,'String',[]);
        errordlg('Input timestep first.')
    end    
end
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function Tprior_mean_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tprior_mean_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Tprior_std_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Tprior_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tprior_std_edit as text
%        str2double(get(hObject,'String')) returns contents of Tprior_std_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and within the correct range
        data.opt.prior.transitionMatrix.dwellRelStd=num;
        data.opt.prior.transitionMatrix.type= 'dwellRelStd_Bweight';%dwell_Bweight';
    else
        errordlg('Prior mean dwell std. time must be > 0.')
    end
end
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function Tprior_std_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tprior_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Dinit_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Dinit_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dinit_range_edit as text
%        str2double(get(hObject,'String')) returns contents of Dinit_range_edit as a double
num=str2num(get(hObject,'String'));
data=guidata(hObject);
% update if legitimate entry
if(numel(num)==2 && prod(isfinite(num))==1 &&  0<num(1) && num(1)<num(2) )
    data.opt.init.Drange=num;
else
    errordlg('D range should be two numbers satisfying 0 < D_low < D_high < inf.')
end
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function Dinit_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dinit_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dinit_upper_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Dinit_upper_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dinit_upper_edit as text
%        str2double(get(hObject,'String')) returns contents of Dinit_upper_edit as a double


% --- Executes during object creation, after setting all properties.
function Dinit_upper_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dinit_upper_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dwell_init_lower_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dwell_init_lower_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dwell_init_lower_edit as text
%        str2double(get(hObject,'String')) returns contents of dwell_init_lower_edit as a double


% --- Executes during object creation, after setting all properties.
function dwell_init_lower_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dwell_init_lower_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dwell_init_upper_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dwell_init_upper_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dwell_init_upper_edit as text
%        str2double(get(hObject,'String')) returns contents of dwell_init_upper_edit as a double


% --- Executes during object creation, after setting all properties.
function dwell_init_upper_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dwell_init_upper_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in about_uSPThmm_button.
function about_uSPThmm_button_Callback(hObject, eventdata, handles)
% hObject    handle to about_uSPThmm_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in runinput_name_button.
function runinput_name_button_Callback(hObject, eventdata, handles)
% hObject    handle to runinput_name_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname, filterindex] = uiputfile( ...
    {'*.m','(*.m)'}, ...
    'Select runinput file', '');
if(filterindex>0 )% && exist(fullfile(pathname,filename),'file') )
    % read external runinput file
    runinputFile=fullfile(pathname,filename);
    % update internal options struct with newOpt
    data=guidata(hObject);
    data.runinputFile=runinputFile;
    % NOTE: the localtion of the runinput file is not an options field. The
    % approach taken here is thus to store only absolute paths in the GUI,
    % and then convert to relative paths when the runinput file is written
    % to disk.
    if(numel(runinputFile)>80)
        runinputStr=['...' runinputFile(end-80:end)];
    else
        runinputStr=runinputFile;
    end
    guidata(hObject,data);
    set(data.runinput_name_text,'string',runinputStr);
    
end


% --- Executes on button press in runinput_load_button.
function runinput_load_button_Callback(hObject, eventdata, handles)
% hObject    handle to runinput_load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% select a runinput file to read data from
% starting path for selection

[filename, pathname, filterindex] = uigetfile( ...
    {'*.m','(*.m)'}, ...
    'Pick a runinput file', 'runinput.m');
if(filterindex>0 && exist(fullfile(pathname,filename),'file') )
    % read external runinput file
    newOpt=spt.readRuninputFile(fullfile(pathname,filename));
    % update internal options struct with newOpt
    updateGUIoptions(hObject,newOpt);
end

% --- Executes on button press in runinput_save_button.
function runinput_save_button_Callback(hObject, eventdata, handles)
% hObject    handle to runinput_save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
opt=data.opt;
if(~isfield(data,'runinputFile'))
   errordlg('Specify runinput file to save to.') 
else
    % name etc of the target runinput file
    [RIroot,RIfile,RIext]=fileparts(data.runinputFile);
    % specify input and output files relative to the runinput file
    opt.trj.inputfile=SM_relative_path_to_file(RIroot,opt.trj.inputfile);
    opt.output.outputFile=SM_relative_path_to_file(RIroot,opt.output.outputFile);
    flag=spt.writeRuninputFile(opt,fullfile(RIroot,[RIfile RIext]) ,true);
    if(flag<0)
       error(['Failed to write runinput file ' fullfile(RIroot,[RIfile RIext])])
    end
end
    
    

% --- Executes on button press in save_and_run_button.
function save_and_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_and_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% first save:
runinput_save_button_Callback(hObject, eventdata, handles);

% then run
ans=questdlg('Start vbuSPT analysis?');
if(strcmp(ans,'Yes'))
    data=guidata(hObject);
    YZShmm.runAnalysis(data.runinputFile);
end
% --- Executes on button press in PBF_model_select_button.
function PBF_model_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to PBF_model_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PBF_model_select_button
num=get(hObject,'Value');
data=guidata(hObject);
data.opt.modelSearch.PBF=num;
updateGUIoptions(hObject,data.opt);
% --- Executes on button press in MLE_parameters_button.
function MLE_parameters_button_Callback(hObject, eventdata, handles)
% hObject    handle to MLE_parameters_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of MLE_parameters_button
num=get(hObject,'Value');
data=guidata(hObject);
data.opt.modelSearch.MLEparam=num;
updateGUIoptions(hObject,data.opt);

function maxHidden_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxHidden_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxHidden_edit as text
%        str2double(get(hObject,'String')) returns contents of maxHidden_edit as a double
num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.modelSearch.maxHidden=num;
    else
        errordlg('Maximum number of states must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);


% --- Executes during object creation, after setting all properties.
function maxHidden_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxHidden_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VBinitStates_edit_Callback(hObject, eventdata, handles)
% hObject    handle to VBinitStates_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of VBinitStates_edit as text
%        str2double(get(hObject,'String')) returns contents of VBinitStates_edit as a double
num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.modelSearch.VBinitHidden=num;
    else
        errordlg('Initial numer of states for model search must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);


% --- Executes during object creation, after setting all properties.
function VBinitStates_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VBinitStates_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function restarts_edit_Callback(hObject, eventdata, handles)
% hObject    handle to restarts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of restarts_edit as text
%        str2double(get(hObject,'String')) returns contents of restarts_edit as a double
num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.modelSearch.restarts=num;
    else
        errordlg('Number of restarts must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function restarts_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to restarts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in close_button.
function close_button_Callback(hObject, eventdata, handles)
% hObject    handle to close_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ans=questdlg('Really close the GUI?');
if(strcmp(ans,'Yes'))
    data=guidata(hObject);
    figure1_CloseRequestFcn(data.figure1,eventdata,handles)
end


% --- Executes on button press in show_results_button.
function show_results_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_results_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if a runinput file exist, suggest that as default
data=guidata(hObject);
if(isfield(data,'runinputFile'))
    RIdefault=data.runinputFile;
else
    RIdefault='runinput.m';
end

[filename, pathname, filterindex] = uigetfile( ...
    {'*.m','(*.m)'}, ...
    'Pick a runinput file', RIdefault);
if(filterindex<=0 && ~exist(fullfile(pathname,filename),'file') )
    disp('Runinput file not found, or no runinput file selected.')
    return
end
runinput=fullfile(pathname,filename);

% by default, we rescale the diffusion constant and add an exponent as unit
YZShmm.displayResults(runinput);%,'scale',{'D',1e-6},'units',{'D','x 1e6'});

function YZww_edit_Callback(hObject, eventdata, handles)
% hObject    handle to YZww_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YZww_edit as text
%        str2double(get(hObject,'String')) returns contents of YZww_edit as a double
num=round(str2num(get(hObject,'String')));
data=guidata(hObject);
if(prod(isfinite(num))==1) % only update if a real ...    
    if(prod(num>1)==1)     % ... and all positive numbers are given    
        data.opt.modelSearch.YZww=num;
    else
        errordlg('YZ smoothing radii must be >1. Try again.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function YZww_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YZww_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in about_button.
function about_button_Callback(hObject, eventdata, handles)
% hObject    handle to about_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uSPTlicense('usptGUI');


function Dinit_lower_Callback(hObject, eventdata, handles)
% hObject    handle to Dinit_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dinit_range_edit as text
%        str2double(get(hObject,'String')) returns contents of Dinit_range_edit as a double


% --- Executes during object creation, after setting all properties.
function Dinit_lower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dinit_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dinit_upper_Callback(hObject, eventdata, handles)
% hObject    handle to Dinit_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dinit_upper as text
%        str2double(get(hObject,'String')) returns contents of Dinit_upper as a double


% --- Executes during object creation, after setting all properties.
function Dinit_upper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dinit_upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tinit_range_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Tinit_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tinit_range_edit as text
%        str2double(get(hObject,'String')) returns contents of Tinit_range_edit as a double
num=str2num(get(hObject,'String'));
data=guidata(hObject);
dt=0;
try
    dt=data.opt.trj.timestep;
catch
end
% update if legitimate entry
if(numel(num)==2 && prod(isfinite(num))==1 &&  dt<num(1) && num(1)<num(2) )
    data.opt.init.Trange=num;
else
    errordlg('Dwell time range should be two numbers satisfying timestep < T_low < T_high < inf.')
end
updateGUIoptions(hObject,data.opt);


% --- Executes during object creation, after setting all properties.
function Tinit_range_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tinit_range_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Tinit_upper_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Tinit_upper_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tinit_upper_edit as text
%        str2double(get(hObject,'String')) returns contents of Tinit_upper_edit as a double


% --- Executes during object creation, after setting all properties.
function Tinit_upper_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tinit_upper_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Bprior_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bprior_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bprior_edit as text
%        str2double(get(hObject,'String')) returns contents of Bprior_edit as a double


% --- Executes during object creation, after setting all properties.
function Bprior_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bprior_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Vprior_Vstrength_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Vprior_Vstrength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vprior_Vstrength_edit as text
%        str2double(get(hObject,'String')) returns contents of Vprior_Vstrength_edit as a double
warning('TBA')


% --- Executes during object creation, after setting all properties.
function Vprior_Vstrength_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vprior_Vstrength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bootstrap_samples_edit_Callback(hObject, eventdata, handles)
% hObject    handle to bootstrap_samples_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bootstrap_samples_edit as text
%        str2double(get(hObject,'String')) returns contents of bootstrap_samples_edit as a double

num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.bootstrap.bootstrapNum=num;
    else
        errordlg('Number of bootstrap samples must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function bootstrap_samples_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bootstrap_samples_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Vprior_strength_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Vprior_strength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vprior_strength_edit as text
%        str2double(get(hObject,'String')) returns contents of Vprior_strength_edit as a double
num=str2num(get(hObject,'String'));
data=guidata(hObject);
% update if legitimate entry
if(numel(num)==1 && isfinite(num) &&  0<num )
    data.opt.prior.positionVariance.strength= num;
    data.opt.prior.positionVariance.type='median_strength';
elseif(isempty(num))
    % guess that the user wants to remove the entry
    data.opt.prior.positionVariance.strength   =[];
    data.opt.prior.positionVariance.type='median_strength';
else
    errordlg('Localization variance strength needs to be a positive number (or leave empty).');
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function Vprior_strength_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vprior_strength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Vprior_RMSEmedian_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Vprior_RMSEmedian_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Vprior_RMSEmedian_edit as text
%        str2double(get(hObject,'String')) returns contents of Vprior_RMSEmedian_edit as a double
num=str2num(get(hObject,'String'));
data=guidata(hObject);
% update if legitimate entry
if(numel(num)==1 && isfinite(num) &&  0<num )
    % legitimate new value
    data.opt.prior.positionVariance.v   =num^2;
    data.opt.prior.positionVariance.type='median_strength';
elseif(isempty(num))
    % guess that the user wants to remove the entry
    data.opt.prior.positionVariance.v   =[];
    data.opt.prior.positionVariance.type='median_strength';
else
    errordlg('Localization variance needs to be a positive number (or empty entry).');
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function Vprior_RMSEmedian_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Vprior_RMSEmedian_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Bprior_weight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Bprior_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Bprior_weight_edit as text
%        str2double(get(hObject,'String')) returns contents of Bprior_weight_edit as a double
num =str2num(get(hObject,'String'));
data=guidata(hObject);
% update if legitimate entry
if(numel(num)==1 && isfinite(num) &&  0<num )
    data.opt.prior.transitionMatrix.Bweight = num;
    data.opt.prior.transitionMatrix.type    = 'dwell_Bweight';
	% 1: flat, <1: favors sparse jump matrix, >1: favors dense jump matrix
else
    errordlg('Localization variance needs to be a positive number.');
end
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function Bprior_weight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Bprior_weight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit47_Callback(hObject, eventdata, handles)
% hObject    handle to Tprior_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tprior_std_edit as text
%        str2double(get(hObject,'String')) returns contents of Tprior_std_edit as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tprior_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit46_Callback(hObject, eventdata, handles)
% hObject    handle to Tprior_mean_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tprior_mean_edit as text
%        str2double(get(hObject,'String')) returns contents of Tprior_mean_edit as a double


% --- Executes during object creation, after setting all properties.
function edit46_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tprior_mean_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bootstrap_param_box.
function bootstrap_param_box_Callback(hObject, eventdata, handles)
% hObject    handle to bootstrap_param_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num=get(hObject,'Value');
data=guidata(hObject);
data.opt.bootstrap.bestParam=num;
updateGUIoptions(hObject,data.opt);

% --- Executes on button press in bootstrap_model_box.
function bootstrap_model_box_Callback(hObject, eventdata, handles)
% hObject    handle to bootstrap_model_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num=get(hObject,'Value');
data=guidata(hObject);
data.opt.bootstrap.modelSelection=num;
updateGUIoptions(hObject,data.opt);

%%% % --- Executes on button press in saveErr_box.
%%% function saveErr_box_Callback(hObject, eventdata, handles)
%%% % hObject    handle to saveErr_box (see GCBO)
%%% % eventdata  reserved - to be defined in a future version of MATLAB
%%% % handles    structure with handles and user data (see GUIDATA)
%%% % Hint: get(hObject,'Value') returns toggle state of saveErr_box
%%% num=get(hObject,'Value');
%%% data=guidata(hObject);
%%% data.opt.conv.saveErr=num;
%%% updateGUIoptions(hObject,data.opt);

function parTol_edit_Callback(hObject, eventdata, handles)
% hObject    handle to parTol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of parTol_edit as text
%        str2double(get(hObject,'String')) returns contents of parTol_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.conv.parTol=num;
    else
        errordlg('Parameter tolerance must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function parTol_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parTol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lnLTol_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lnLTol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lnLTol_edit as text
%        str2double(get(hObject,'String')) returns contents of lnLTol_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.conv.lnLTol=num;
    else
        errordlg('lnL tolerance must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function lnLTol_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lnLTol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function maxIter_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxIter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIter_edit as text
%        str2double(get(hObject,'String')) returns contents of maxIter_edit as a double
num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.conv.maxIter=num;
    else
        errordlg('Maximum number of iterations must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);
% --- Executes during object creation, after setting all properties.
function maxIter_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxIter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in exposure_time_button.
function exposure_time_button_Callback(hObject, eventdata, handles)
% hObject    handle to exposure_time_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
opt=data.opt;

if(isfield(opt,'trj') && isfield(opt.trj,'timestep') ...
        && ~isempty(opt.trj.timestep) && isreal(opt.trj.timestep) )
    dt=opt.trj.timestep;
    answer=inputdlg('Enter exposure time (<timestep):','exposure time');
    tE=str2double(answer{1});
    if(~isempty(tE) )
        if(tE>=dt)
            errordlg('Exposure time must be smaller than the timestep.','');
        else
           opt.trj.shutterMean=tE/dt/2;
           opt.trj.blurCoeff  = tE/dt/6;
           updateGUIoptions(hObject,opt);
        end
    end
else
   errordlg('Must specify a finite timestep before computing blur coefficients from the exposure time.',...
        'No timestep');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

function PBF_fracPos_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PBF_fracPos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PBF_fracPos_edit as text
%        str2double(get(hObject,'String')) returns contents of PBF_fracPos_edit as a double

num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num) && num>0 && num<1 ) % only update if a real ...
    data.opt.modelSearch.PBFfracPos=num;
else
    errordlg('Relative size of validation data set must be between 0 and 1.')
end
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function PBF_fracPos_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBF_fracPos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function PBF_restarts_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PBF_restarts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PBF_restarts_edit as text
%        str2double(get(hObject,'String')) returns contents of PBF_restarts_edit as a double

num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if(isfinite(num) && num>0 && num==round(num) ) % only update if a real ...
    data.opt.modelSearch.PBFrestarts=num;
else
    errordlg('Number of restarts must be a positive integer.')
end
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function PBF_restarts_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBF_restarts_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in trj_length_button.
function trj_length_button_Callback(hObject, eventdata, handles)
% hObject    handle to trj_length_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
opt=data.opt;
% input files are specified with absolute path, but the runinputroot
% field is still needed
opt.runinputroot='';
spt.trjLength_hist(opt,101);

% --- Executes on button press in RMSE_button.
function RMSE_button_Callback(hObject, eventdata, handles)
% hObject    handle to RMSE_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
opt=data.opt;
% input files are specified with absolute path, but the runinputroot
% field is still needed
opt.runinputroot='';
spt.RMSE_hist(opt,102);


% --- Executes on button press in D_filter_button.
function D_filter_button_Callback(hObject, eventdata, handles)
% hObject    handle to D_filter_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data=guidata(hObject);
opt=data.opt;
% input files are specified with absolute path within the GUI, but the
% runinputroot field is still needed
opt.runinputroot='';

spt.D_lin_log_hist(opt,103);



function maxRMSE_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxRMSE_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxRMSE_edit as text
%        str2double(get(hObject,'String')) returns contents of maxRMSE_edit as a double

num=round(str2double(get(hObject,'String')));
data=guidata(hObject);
if( num>0 ) % positive or inf is OK
    data.opt.trj.maxRMSE=num;
else
    errordlg('RMSE upper threshold must be positive number, or inf.')
end
updateGUIoptions(hObject,data.opt);

% --- Executes during object creation, after setting all properties.
function maxRMSE_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxRMSE_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Dprior_plot_button.
function Dprior_plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to Dprior_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
Dprior=data.opt.prior.diffusionCoeff;
if(   isfield(Dprior,'D')        && ~isempty(Dprior.D) ...
   && isfield(Dprior,'strength') && ~isempty(Dprior.strength) ...
   &&  isfield(Dprior,'type') && strcmp(Dprior.type,'median_strength')==true )

    [n,c]=spt.prior_inverse_gamma_median_strength(1,Dprior.D,Dprior.strength);    
    
    lnp0=@(x)(n*log(c)-gammaln(n)-(n+1)*log(x)-c./x);
    Dmode=c/(n+1); % prior mode value    
    DD=logspace(log10(Dmode)-3,log10(Dprior.D)+3,1000);
    
    figure(104)
    clf
    subplot(2,1,1)
    hold on
    plot(DD,exp(lnp0(DD)            ),'k')
    plot(Dprior.D,exp(lnp0(Dprior.D)),'mo')
    set(gca,'xscale','lin')
    xlabel('D')
    ylabel('\rho(D)')
    box on
    title('diffusion constant prior distribution')    
    legend('\rho_0(D)','median')
    
    subplot(2,1,2)
    Dmode=c/n; % prior mode value    
    DD=logspace(log10(Dmode)-2,log10(Dprior.D)+4,1000);
    hold on
    plot(DD,exp(lnp0(DD)            +log(DD)),'k')
    plot(Dprior.D,exp(lnp0(Dprior.D)+log(Dprior.D)),'mo')

    set(gca,'xscale','log')
    xlabel('D')
    ylabel('\rho(log D)')
    box on
    title('log(D) prior ')
    legend('\rho_0(log D)','median')
    
else
    errordlg(['Diffusion const. prior not completely specified (or of wrong type)'],...
       'Error plotting D prior.')
end

% --- Executes on button press in Vprior_plot_button.
function Vprior_plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to Vprior_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data=guidata(hObject);
Vprior=data.opt.prior.positionVariance;
if(   isfield(Vprior,'v')        && ~isempty(Vprior.v) ...
   && isfield(Vprior,'strength') && ~isempty(Vprior.strength) ...
   && isfield(Vprior,'type') && strcmp(Vprior.type,'median_strength'))

    [nV,cV]=spt.prior_inverse_gamma_median_strength(1,Vprior.v,Vprior.strength);
    
    figure(106)
    clf
    subplot(2,2,1)
    hold on
    % variance prior
    lnp0=@(x)(nV*log(cV)-gammaln(nV)-(nV+1)*log(x)-cV./x);
    Vmode=cV/(nV+1);
    VV=logspace(log10(Vmode)-2,log10(Vprior.v)+2,1000);

    plot(VV,exp(lnp0(VV)),'k')
    plot(Vprior.v,exp(lnp0(Vprior.v)),'mo')

    set(gca,'xscale','lin')
    xlabel('position variance v  [length^2]')
    ylabel('\rho(v)')
    box on
    title('position variance (v) prior distribution')
    axis([VV([1 end]) 0 1.05*exp(lnp0(Vmode))])
    
    subplot(2,2,3)
    hold on
    Vmode=cV/nV;
    VV=logspace(log10(Vmode)-1,log10(Vprior.v)+3,1000);
    
    plot(VV,exp(lnp0(VV)            +log(VV)),'k')
    plot(Vprior.v,exp(lnp0(Vprior.v)+log(Vprior.v)),'mo')

    set(gca,'xscale','log')
    xlabel('position variance v [length^2]')
    ylabel('\rho(log v)')
    box on
    title('log(v) prior ')
    legend('\rho_0(log v)','median')
    axis([VV([1 end]) 0 1.05*exp(lnp0(Vmode)+log(Vmode))])
    
        
    % RMSE=sqrt(v) prior
    RMSEmedian=sqrt(Vprior.v);
    lnp0=@(x)(nV*log(cV)-gammaln(nV)-(2*nV+1)*log(x)-cV./x.^2);
    RMSEmode=sqrt(cV/(nV+0.5));
    VV=logspace(log10(RMSEmode)-2,log10(RMSEmedian)+2,1000);

    subplot(2,2,2)
    hold on
    plot(VV,exp(lnp0(VV)),'k')
    plot(RMSEmedian,exp(lnp0(RMSEmedian)),'mo')
    xlabel('RMS error r [length]')
    ylabel('\rho(r)')
    box on
    title('RMSE prior distribution')
    set(gca,'xscale','lin')
    axis([VV([1 end]) 0 1.05*exp(lnp0(RMSEmode))])
    
    subplot(2,2,4)
    RMSEmode=sqrt(cV/nV);
    VV=logspace(log10(RMSEmode)-1,log10(RMSEmedian)+3,1000);
    
    hold on
    plot(VV,exp(lnp0(VV)+log(VV)),'k')
    plot(RMSEmedian,exp(lnp0(RMSEmedian)+log(RMSEmedian)),'mo')
    xlabel('RMS error r [length]')
    ylabel('\rho(log r)')
    box on
    title('log(RMSE) prior distribution')
    set(gca,'xscale','log')
    legend('\rho_0(log RMSE)','median')

    axis([VV([1 end]) 0 1.05*exp(lnp0(RMSEmode)+log(RMSEmode))])
    
end

% --- Executes on button press in Tprior_plot_button.
function Tprior_plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to Tprior_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=guidata(hObject);
Tprior=data.opt.prior.transitionMatrix;
if(isfield(Tprior,'dwellMean') && isfield(data.opt.trj,'timestep'))
    dt=data.opt.trj.timestep;    
    % set Bweight=1 since it is not used anyway
    wa=spt.prior_transition_dwellRelStd_Bweight(2,...
        Tprior.dwellMean/dt,Tprior.dwellRelStd,1);
    wa1=wa(1,1);
    wa2=wa(1,2);
    wa0=wa1+wa2;
    
    figure(105)
    clf
    subplot(2,1,1)
    lnp0=@(x)(log(dt)+gammaln(wa1)+gammaln(wa2)-gammaln(wa0)-wa0*log(x/dt)+(wa2-1)*log(x/dt-1));
    TT=linspace(dt,10*Tprior.dwellMean*Tprior.dwellRelStd,1000);
    hold on
    plot(TT,exp(lnp0(TT)))
    plot(dt*[1 1],[0 max(exp(lnp0(TT)))],'k:')
    xlabel('mean dwell time \tau [time]')
    ylabel('\rho_0(\tau)')
    title('mean dwell time prior')
    legend('\rho_0(\tau)','\Delta t')
    
    subplot(2,1,2)
    lnp0=@(x)(log(dt)+gammaln(wa1)+gammaln(wa2)-gammaln(wa0)-wa0*log(x/dt)+(wa2-1)*log(x/dt-1)+log(x/dt));
    TT=logspace(log10(dt*1.001),2+log10(Tprior.dwellMean*Tprior.dwellRelStd),1000);
    hold on
    plot(TT,exp(lnp0(TT)))
    plot(dt*[1 1],[0 max(exp(lnp0(TT)))],'k:')
    xlabel('mean dwell time \tau [time]')
    ylabel('\rho_0(log \tau)')
    title('log(\tau) prior')
    set(gca,'xscale','log')
    legend('\rho_0(log \tau)','\Delta t')
else
    errordlg('Input time step and mean mean dwell time first.')
end

% --- Executes on button press in Bprior_plot_button.
function Bprior_plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to Bprior_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in class_help_button.
function class_help_button_Callback(hObject, eventdata, handles)
% hObject    handle to class_help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data=guidata(hObject);
opt=data.opt;

if(~isfield(opt,'model') || isempty(opt.model.class))
    errordlg('Select a model class first.')
else
    H=help(opt.model.class);
    helpdlg(H,opt.model.class);
end
    



function dsTol_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dsTol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dsTol_edit as text
%        str2double(get(hObject,'String')) returns contents of dsTol_edit as a double
num=str2double(get(hObject,'String'));
data=guidata(hObject);
if(isfinite(num)) % only update if a real ...
    if(num>0)     % ... and positive number is given    
        data.opt.conv.dsTol=num;
    else
        errordlg('s tolerance must be positive.')
    end
end
updateGUIoptions(hObject,data.opt);


% --- Executes during object creation, after setting all properties.
function dsTol_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dsTol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
