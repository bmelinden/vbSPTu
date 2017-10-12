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

% Last Modified by GUIDE v2.5 12-Oct-2017 22:16:15

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

1;

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


% --- Executes on button press in output_file_button.
function output_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to output_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in position_variable_popupmenu.
function position_variable_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to position_variable_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns position_variable_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from position_variable_popupmenu


% --- Executes during object creation, after setting all properties.
function position_variable_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to position_variable_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in precision_variable_popup.
function precision_variable_popup_Callback(hObject, eventdata, handles)
% hObject    handle to precision_variable_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns precision_variable_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from precision_variable_popup


% --- Executes during object creation, after setting all properties.
function precision_variable_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to precision_variable_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timestep_edit_text_Callback(hObject, eventdata, handles)
% hObject    handle to timestep_edit_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timestep_edit_text as text
%        str2double(get(hObject,'String')) returns contents of timestep_edit_text as a double


% --- Executes during object creation, after setting all properties.
function timestep_edit_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timestep_edit_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function exposure_time_edit_Callback(hObject, eventdata, handles)
% hObject    handle to exposure_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exposure_time_edit as text
%        str2double(get(hObject,'String')) returns contents of exposure_time_edit as a double


% --- Executes during object creation, after setting all properties.
function exposure_time_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exposure_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function blur_coeff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to blur_coeff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blur_coeff_edit as text
%        str2double(get(hObject,'String')) returns contents of blur_coeff_edit as a double


% --- Executes during object creation, after setting all properties.
function blur_coeff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blur_coeff_edit (see GCBO)
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



function Dprior_median_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Dprior_median_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dprior_median_edit as text
%        str2double(get(hObject,'String')) returns contents of Dprior_median_edit as a double


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


% --- Executes on button press in prior_misc_button.
function prior_misc_button_Callback(hObject, eventdata, handles)
% hObject    handle to prior_misc_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Dinit_lower_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Dinit_lower_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Dinit_lower_edit as text
%        str2double(get(hObject,'String')) returns contents of Dinit_lower_edit as a double


% --- Executes during object creation, after setting all properties.
function Dinit_lower_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dinit_lower_edit (see GCBO)
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


% --- Executes on button press in runinput_load_button.
function runinput_load_button_Callback(hObject, eventdata, handles)
% hObject    handle to runinput_load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in runinput_save_button.
function runinput_save_button_Callback(hObject, eventdata, handles)
% hObject    handle to runinput_save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_and_run_button.
function save_and_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_and_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PBF_model_select_button.
function PBF_model_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to PBF_model_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PBF_model_select_button


% --- Executes on button press in MLE_parameters_button.
function MLE_parameters_button_Callback(hObject, eventdata, handles)
% hObject    handle to MLE_parameters_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MLE_parameters_button


% --- Executes on button press in bootstrap_param_button.
function bootstrap_param_button_Callback(hObject, eventdata, handles)
% hObject    handle to bootstrap_param_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bootstrap_param_button


% --- Executes on button press in bootstrap_model_button.
function bootstrap_model_button_Callback(hObject, eventdata, handles)
% hObject    handle to bootstrap_model_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bootstrap_model_button



function maxHidden_edit_Callback(hObject, eventdata, handles)
% hObject    handle to maxHidden_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxHidden_edit as text
%        str2double(get(hObject,'String')) returns contents of maxHidden_edit as a double


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


% --- Executes on button press in show_results_button.
function show_results_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_results_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function YZww_edit_Callback(hObject, eventdata, handles)
% hObject    handle to YZww_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YZww_edit as text
%        str2double(get(hObject,'String')) returns contents of YZww_edit as a double


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
