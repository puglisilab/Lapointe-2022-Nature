
function varargout = Process_movies(varargin)
% Put full path to the setup file here

% PROCESS_MOVIES M-file for Process_movies.fig
%      PROCESS_MOVIES, by itself, creates a new PROCESS_MOVIES or raises the existing
%      singleton*.
%
%      H = PROCESS_MOVIES returns the handle to a new PROCESS_MOVIES or the handle to
%      the existing singleton*.
%
%      PROCESS_MOVIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESS_MOVIES.M with the given input arguments.
%
%      PROCESS_MOVIES('Property','Value',...) creates a new PROCESS_MOVIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Process_movies_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Process_movies_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Process_movies

% Last Modified by GUIDE v2.5 09-Jul-2014 17:41:24

% Begin initialization code - DO NOT EDIT
warning('off');

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Process_movies_OpeningFcn, ...
                   'gui_OutputFcn',  @Process_movies_OutputFcn, ...
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



% --- Executes just before Process_movies is made visible.
function Process_movies_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Process_movies (see VARARGIN)

% Choose default command line output for Process_movies
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Process_movies wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Process_movies_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in realign.
function realign_Callback(hObject, eventdata, handles)
% hObject    handle to realign (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of realign


% --- Executes on button press in run_process_movies.
function run_process_movies_Callback(hObject, eventdata, handles)
NsigmasG = str2num(get(handles.n_sigmas_g,'String'));
NsigmasR = str2num(get(handles.n_sigmas_r,'String'));
tooBig = str2num(get(handles.toobig,'String'));
tooSmall = str2num(get(handles.toosmall,'String'));
newdir = get(handles.dir_name,'String');
frameRate = str2num(get(handles.framerate,'String'));
file_look_up = get(handles.file_lookup,'String');
comp_alignment = get(handles.realign,'Value');
X_align = str2num(get(handles.X_align,'String'));
Y_align = str2num(get(handles.Y_align,'String'));
G_on_R = get(handles.G_on_R,'Value');
R_on_G = get(handles.R_on_G,'Value');
GTR = str2num(get(handles.GTR,'String'));
RTR = str2num(get(handles.RTR,'String'));


% fid = fopen('//home/bright/Desktop/Matlab_Scripts/Process_movies/process_movies_setup.txt', 'wt');
% fprintf(fid, ['NsigmasG, ' num2str(NsigmasG) '\n']);
% fprintf(fid, ['NsigmasR, ' num2str(NsigmasR) '\n']);
% fprintf(fid, ['tooBig, ' num2str(tooBig) '\n']);
% fprintf(fid, ['tooSmall, ' num2str(tooSmall) '\n']);
% fprintf(fid, ['X_align, ' get(handles.X_align,'String') '\n']);
% fprintf(fid, ['Y_align, ' get(handles.Y_align,'String') '\n']);
% fprintf(fid, ['framerate, ' get(handles.framerate,'String') '\n']);
% fprintf(fid, ['auto_dir_name, ' num2str(get(handles.auto_dir_name,'Value')) '\n']);
% fprintf(fid, ['realign, ' num2str(get(handles.realign,'Value')) '\n']);
mkdir(newdir);
pack;
stackList = dir(['*' file_look_up '*']);
if isempty(stackList)
    disp('No compatible files are present in this directory');
    return
end

if length(stackList)==1
    disp(' ');
    disp(['This directory contains ' num2str(length(stackList)) ' movie']);
else
    disp(' ');
    disp(['This directory contains ' num2str(length(stackList)) ' movies']);
end

for movie=1:length(stackList);
    MV = stackList(movie).name;
    Import_pick_colocalize_gui;
end

clear all;
disp('Movie processing finished')
% hObject    handle to run_process_movies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function dir_name_Callback(hObject, eventdata, handles)
% hObject    handle to dir_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dir_name as text
%        str2double(get(hObject,'String')) returns contents of dir_name as a double


% --- Executes during object creation, after setting all properties.
function dir_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dir_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end



function n_sigmas_g_Callback(hObject, eventdata, handles)
if get(handles.auto_dir_name, 'Value') == 1
set(handles.dir_name,'String',['Analysis' get(handles.n_sigmas_g,'String') get(handles.n_sigmas_r,'String') get(handles.toobig,'String') get(handles.toosmall,'String');]);
end
% hObject    handle to n_sigmas_g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_sigmas_g as text
%        str2double(get(hObject,'String')) returns contents of n_sigmas_g as a double


% --- Executes during object creation, after setting all properties.
function n_sigmas_g_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_sigmas_g (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function n_sigmas_r_Callback(hObject, eventdata, handles)
if get(handles.auto_dir_name, 'Value') == 1
set(handles.dir_name,'String',['Analysis' get(handles.n_sigmas_g,'String') get(handles.n_sigmas_r,'String') get(handles.toobig,'String') get(handles.toosmall,'String');]);
end
% hObject    handle to n_sigmas_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_sigmas_r as text
%        str2double(get(hObject,'String')) returns contents of n_sigmas_r as a double


% --- Executes during object creation, after setting all properties.
function n_sigmas_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_sigmas_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in prev_parameters.
function prev_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to prev_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prev_parameters = csvread ('//home/bright/Desktop/Matlab_Scripts/Process_movies/process_movies_setup.txt', 0, 1,[0, 1, 8, 1]);

set(handles.n_sigmas_g,'String',num2str(prev_parameters(1,1)));
set(handles.n_sigmas_r,'String',num2str(prev_parameters(2,1)));
set(handles.toobig,'String',num2str(prev_parameters(3,1)));
set(handles.toosmall,'String',num2str(prev_parameters(4,1)));
set(handles.X_align,'String',num2str(prev_parameters(5,1)));
set(handles.Y_align,'String',num2str(prev_parameters(6,1)));
set(handles.framerate,'String',num2str(prev_parameters(7,1)));
set(handles.auto_dir_name,'Value',prev_parameters(8,1));
set(handles.realign,'Value',prev_parameters(9,1));
%set(handles.dir_name,'String',num2str(prev_parameters(10,1)));


function toobig_Callback(hObject, eventdata, handles)
if get(handles.auto_dir_name, 'Value') == 1
set(handles.dir_name,'String',['Analysis' get(handles.n_sigmas_g,'String') get(handles.n_sigmas_r,'String') get(handles.toobig,'String') get(handles.toosmall,'String');]);
end
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text4 as text
%        str2double(get(hObject,'String')) returns contents of text4 as a double


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function toosmall_Callback(hObject, eventdata, handles)
if get(handles.auto_dir_name, 'Value') == 1
set(handles.dir_name,'String',['Analysis' get(handles.n_sigmas_g,'String') get(handles.n_sigmas_r,'String') get(handles.toobig,'String') get(handles.toosmall,'String');]);
end
% hObject    handle to toosmall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toosmall as text
%        str2double(get(hObject,'String')) returns contents of toosmall as a double


% --- Executes during object creation, after setting all properties.
function toosmall_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toosmall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function toobig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toobig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function file_lookup_Callback(hObject, eventdata, handles)
% hObject    handle to file_lookup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_lookup as text
%        str2double(get(hObject,'String')) returns contents of file_lookup as a double


% --- Executes during object creation, after setting all properties.
function file_lookup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_lookup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in auto_dir_name.
function auto_dir_name_Callback(hObject, eventdata, handles)
if get(handles.auto_dir_name, 'Value') == 1
set(handles.dir_name,'String',['Analysis' get(handles.n_sigmas_g,'String') get(handles.n_sigmas_r,'String') get(handles.toobig,'String') get(handles.toosmall,'String');]);
end
% hObject    handle to auto_dir_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of auto_dir_name


% --- Executes on key press with focus on auto_dir_name and none of its controls.
function auto_dir_name_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to auto_dir_name (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on toobig and none of its controls.
function toobig_KeyPressFcn(hObject, eventdata, handles)
if get(handles.auto_dir_name, 'Value') == 1
set(handles.dir_name,'String',['Analysis' get(handles.n_sigmas_g,'String') get(handles.n_sigmas_r,'String') get(handles.toobig,'String') get(handles.toosmall,'String');]);
end
% hObject    handle to toobig (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



function framerate_Callback(hObject, eventdata, handles)
% hObject    handle to framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of framerate as text
%        str2double(get(hObject,'String')) returns contents of framerate as a double


% --- Executes during object creation, after setting all properties.
function framerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in G_on_R.
function G_on_R_Callback(hObject, eventdata, handles)
% hObject    handle to G_on_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of G_on_R


% --- Executes on button press in R_on_G.
function R_on_G_Callback(hObject, eventdata, handles)
% hObject    handle to R_on_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of R_on_G



function GTR_Callback(hObject, eventdata, handles)
% hObject    handle to GTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GTR as text
%        str2double(get(hObject,'String')) returns contents of GTR as a double


% --- Executes during object creation, after setting all properties.
function GTR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RTR_Callback(hObject, eventdata, handles)
% hObject    handle to RTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RTR as text
%        str2double(get(hObject,'String')) returns contents of RTR as a double


% --- Executes during object creation, after setting all properties.
function RTR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
