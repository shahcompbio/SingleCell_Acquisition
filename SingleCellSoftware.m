function varargout = SingleCellSoftware(varargin)
% SINGLECELLSOFTWARE MATLAB code for SingleCellSoftware.fig
%      SINGLECELLSOFTWARE, by itself, creates a new SINGLECELLSOFTWARE or raises the existing
%      singleton*.
%
%      H = SINGLECELLSOFTWARE returns the handle to a new SINGLECELLSOFTWARE or the handle to
%      the existing singleton*.
%
%      SINGLECELLSOFTWARE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLECELLSOFTWARE.M with the given input arguments.
%
%      SINGLECELLSOFTWARE('Property','Value',...) creates a new SINGLECELLSOFTWARE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SingleCellSoftware_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SingleCellSoftware_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SingleCellSoftware

% Last Modified by GUIDE v2.5 18-Nov-2020 14:53:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SingleCellSoftware_OpeningFcn, ...
                   'gui_OutputFcn',  @SingleCellSoftware_OutputFcn, ...
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
end


% --- Executes just before SingleCellSoftware is made visible.
function SingleCellSoftware_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SingleCellSoftware (see VARARGIN)

% Choose default command line output for SingleCellSoftware
handles.output = hObject;

% initialize default parameters
%% status %%
handles.started = false;
handles.paused = false;
handles.finished = false;
handles.curRow = 1;     % currently acquiring row
handles.curCol = 1;     % currently acquiring col

%% connection %%
handles.connectedScope = false;
handles.connectedLasers = false;
handles.connectedStage = false;

%% laser control %%
% on = true, off = false;
handles.UVOn = false;
handles.BlueOn = false;
handles.CyanOn = false;
handles.TealOn = false;
handles.GreenOn = false;
handles.RedOn = false;

% power: 0 - 255
handles.UVPower = 0;
handles.BluePower = 0;
handles.CyanPower = 0;
handles.TealPower = 0;
handles.GreenPower = 0;
handles.RedPower = 0;

%% stage cal %%
handles.stepSize = 10;
handles.stageX = 0;
handles.stageY = 0;
handles.stageZ = 0;

%% settings %%
handles.chipRow = 72;
handles.chipCol = 72;
handles.imgRow = 2;
handles.imgCol = 3;
handles.rep = 1;

%% acq %%
handles.outputDir = pwd;
handles.outputFor = '604x604x16b TIFF';

%% update %%
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SingleCellSoftware wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = SingleCellSoftware_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage Calibration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Stage Calibration %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function updatePos(hObject, eventdata, handles)
% get pos here %
set(handles.stageXtext, 'String', num2str(handles.stageX));
set(handles.stageYtext, 'String', num2str(handles.stageY));
set(handles.stageZtext, 'String', num2str(handles.stageZ));
guidata(hObject, handles);
end

% --- Executes on button press in connect2stage.
function connect2stage_Callback(hObject, eventdata, handles)
disp('Connecting to stage ...');
set(handles.stageStatus, 'String', 'Connecting ...', 'ForegroundColor', [0.2, 0.66, 0.32]);

portList = get(handles.stagePortList, 'String');
port = get(handles.stagePortList, 'Value');
str = split(portList(port), 'COM');
portNum = str(2);
handles.stagePortNum = str2double(portNum);

% do the connection here
[hObject, eventdata, handles] = connect2stage(hObject, eventdata, handles);

disp('Succesfully connected to stage.');
handles.connectedStage = true;
set(handles.stageStatus, 'String', 'Connected');
set(handles.disconnStage, 'enable', 'on');
set(hObject, 'enable', 'off');

% check if all connections have been fulfilled %
checkConnections(handles);

set(handles.XYup, 'enable', 'on');
set(handles.XYdown, 'enable', 'on');
set(handles.XYleft, 'enable', 'on');
set(handles.XYright, 'enable', 'on');
set(handles.Zup, 'enable', 'on');
set(handles.Zdown, 'enable', 'on');
set(handles.stepSizeEdit, 'enable', 'on');
set(handles.stepUp, 'enable', 'on');
set(handles.stepDown, 'enable', 'on');

set(handles.stageXtext, 'enable', 'on');
set(handles.stageYtext, 'enable', 'on');
set(handles.stageZtext, 'enable', 'on');

% TODO: update this so it shows the actual current stage position %
% get pos here and update %
updatePos(hObject, eventdata, handles);
guidata(hObject, handles);
end


% --- Executes on button press in disconnStage.
function disconnStage_Callback(hObject, eventdata, handles)
disp('Disconnecting from stage ...');
set(handles.stageStatus, 'String', 'Disconnecting ...', 'ForegroundColor', [1, 0, 0]);

% disconnect here %
[hObject, eventdata, handles] = disconnStage(hObject, eventdata, handles);

handles.connectedStage = false;
handles.stagePortNum = -1;
set(hObject, 'enable', 'off');
set(handles.connect2stage, 'enable', 'on');
set(handles.XYup, 'enable', 'off');
set(handles.XYdown, 'enable', 'off');
set(handles.XYleft, 'enable', 'off');
set(handles.XYright, 'enable', 'off');
set(handles.Zup, 'enable', 'off');
set(handles.Zdown, 'enable', 'off');
set(handles.stepSizeEdit, 'enable', 'off');
set(handles.stepUp, 'enable', 'off');
set(handles.stepDown, 'enable', 'off');

set(handles.stageXtext, 'enable', 'off');
set(handles.stageYtext, 'enable', 'off');
set(handles.stageZtext, 'enable', 'off');

set(handles.startImgButton, 'enable', 'off');
set(handles.stageStatus, 'String', 'Disconnected'); 
set(handles.status, 'String', 'Waiting for instruments to connect', 'ForegroundColor', [1, 0, 0]);
disp('Disconnected from stage.');

guidata(hObject, handles);
end


% --- Executes on selection change in stagePortList.
function stagePortList_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns stagePortList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stagePortList
portList = get(hObject, 'String');
port = get(hObject, 'Value');
if port >= 2
    if handles.connectedStage ~= true
        try
            str = split(portList(port), 'COM');
            portNum = str(2);
            handles.stagePortNum = str2double(portNum);
            set(handles.connect2stage, 'enable', 'on');
            set(handles.stageStatus, 'String', 'Ready to Connect', 'ForegroundColor', [0.2, 0.66, 0.32]);
        catch
            warndlg('No available port detected.');
            set(handles.connect2stage, 'enable', 'off');
        end
    end
else
    set(handles.connect2stage, 'enable', 'off');
    set(handles.stageStatus, 'String', 'Invalid port', 'ForegroundColor', [1, 0, 0]);
end
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function stagePortList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
availablePorts = getAvailableComPort();
% availablePorts = {'', 'COM11'};
set(hObject, 'String', [{'Select a port'}, availablePorts]);
guidata(hObject, handles);
end


% --- Executes on button press in XYup.
function XYup_Callback(hObject, eventdata, handles)
y = handles.stepSize;
% move the stage here %
% update stage pos %
% TODO: change below to get the current stage pos instead of incrementing%
handles.stageY = handles.stageY + y;
updatePos(hObject, eventdata, handles);
end


% --- Executes on button press in XYdown.
function XYdown_Callback(hObject, eventdata, handles)
y = handles.stepSize;
handles.stageY = handles.stageY - y;
updatePos(hObject, eventdata, handles);
end


% --- Executes on button press in XYleft.
function XYleft_Callback(hObject, eventdata, handles)
x = handles.stepSize;
handles.stageX = handles.stageX - x;
updatePos(hObject, eventdata, handles);
end


% --- Executes on button press in XYright.
function XYright_Callback(hObject, eventdata, handles)
x = handles.stepSize;
handles.stageX = handles.stageX + x;
updatePos(hObject, eventdata, handles);
end


% --- Executes on button press in Zdown.
function Zdown_Callback(hObject, eventdata, handles)
z = handles.stepSize;
handles.stageZ = handles.stageZ - z;
updatePos(hObject, eventdata, handles);
end


% --- Executes on button press in Zup.
function Zup_Callback(hObject, eventdata, handles)
z = handles.stepSize;
handles.stageZ = handles.stageZ + z;
updatePos(hObject, eventdata, handles);
end


function stepSizeEdit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of stepSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of stepSizeEdit as a double
prev = handles.stepSize;
stepSize = str2double(get(hObject, 'String'));
if isnan(stepSize) || floor(stepSize) ~= stepSize || stepSize > 1000 || stepSize < 1
    set(hObject, 'String', num2str(prev));
    warndlg('Step size must be an integer in the range of [1, 1000]');
else
    handles.stepSize = stepSize;
end
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function stepSizeEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in stepUp.
function stepUp_Callback(hObject, eventdata, handles)
if handles.stepSize <= 999
    handles.stepSize = handles.stepSize + 1;
end
set(handles.stepSizeEdit, 'String', num2str(handles.stepSize));
guidata(hObject, handles);
end

% --- Executes on button press in stepDown.
function stepDown_Callback(hObject, eventdata, handles)
if handles.stepSize >= 2
    handles.stepSize = handles.stepSize - 1;
end
set(handles.stepSizeEdit, 'String', num2str(handles.stepSize));
guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Live View %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Live View %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in scopePortList.
function scopePortList_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns scopePortList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scopePortList
portList = get(hObject, 'String');
port = get(hObject, 'Value');
if port >= 2
    if handles.connectedScope ~= true
        try
            str = split(portList(port), 'COM');
            portNum = str(2);
            handles.scopePortNum = str2double(portNum);
            set(handles.connect2scope, 'enable', 'on');
            set(handles.scopeStatus, 'String', 'Ready to Connect', 'ForegroundColor', [0.2, 0.66, 0.32]);
        catch
            warndlg('No available port detected.');
            set(handles.connect2scope, 'enable', 'off');
        end
    end
else
    set(handles.connect2scope, 'enable', 'off');
    set(handles.scopeStatus, 'String', 'Invalid port', 'ForegroundColor', [1, 0, 0]);
end
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function scopePortList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
availablePorts = getAvailableComPort();
% availablePorts = {'COM11'};
set(hObject, 'String', [{'Select a port'}, availablePorts]);
guidata(hObject, handles);
end


% --- Executes on button press in connect2scope.
function connect2scope_Callback(hObject, eventdata, handles)
disp('Connecting to Nikon TiE ...');
set(handles.scopeStatus, 'String', 'Connecting ...', 'ForegroundColor', [0.2, 0.66, 0.32]);

portList = get(handles.scopePortList, 'String');
port = get(handles.scopePortList, 'Value');
str = split(portList(port), 'COM');
portNum = str(2);
handles.scopePortNum = str2double(portNum);

% do the connection here
[hObject, eventdata, handles] = connect2scope(hObject, eventdata, handles);

disp('Succesfully connected to Nikon TiE.');
set(handles.scopeStatus, 'String', 'Connected');
handles.connectedScope = true;

% check connections %
checkConnections(handles);

set(handles.disconnScope, 'enable', 'on');
set(handles.liveView, 'enable', 'on');
set(hObject, 'enable', 'off');
guidata(hObject, handles);
end


% --- Executes on button press in disconnScope.
function disconnScope_Callback(hObject, eventdata, handles)
disp('Disconnecting from microscope ...');
set(handles.scopeStatus, 'String', 'Disconnecting ...', 'ForegroundColor', [1, 0, 0]);

% disconnect here %
[hObject, eventdata, handles] = disconnScope(hObject, eventdata, handles);

handles.connectedScope = false;
handles.scopePortNum = -1;
set(hObject, 'enable', 'off');
set(handles.connect2scope, 'enable', 'on');
set(handles.liveView, 'enable', 'off');
set(handles.liveView, 'Value', 0);

set(handles.startImgButton, 'enable', 'off');
set(handles.scopeStatus, 'String', 'Disconnected'); 
set(handles.status, 'String', 'Waiting for instruments to connect', 'ForegroundColor', [1, 0, 0]);
disp('Disconnected from microscope.');

guidata(hObject, handles);
end


function showGrid(handles, width, height)
%mesh grid
row = handles.imgRow;
col = handles.imgCol;
% horizontal lines
x = [1 height];
y = [width/row width/row];
plot(x,y,'LineWidth',2,'Color','g');
% vertical lines
for k = height/col:height/col:height-height/col
x = [k k];
y = [1 width];
plot(x,y,'LineWidth',2,'Color','g');
end
end

% --- Executes on button press in liveView.
function liveView_Callback(hObject, eventdata, handles)
%     position = get(handles.LiveViewImg, 'Position');
%     width = position(3) - position(1);
%     height = position(4) - position(2);
if get(hObject, 'Value') == 1
    set(handles.liveViewMsg, 'Visible', 'off');
    %TODO: replace below with image capture %
    I = imread(fullfile(pwd, 'singlecell.jpg'));
    imshow(I);
    hold on
    M = size(I,1);
    N = size(I,2);
    showGrid(handles, M, N);
    hold off
else
    % TODO: replace this with action %
    disp('Stop live view now');
end
guidata(hObject, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%% Laser Control %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Laser Control %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in laserPortList.
function laserPortList_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns laserPortList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from laserPortList
% get(handles.laserPortList, 'String')
portList = get(hObject, 'String');
port = get(hObject, 'Value');
if port >= 2
    if handles.connectedLasers ~= true
        try
            str = split(portList(port), 'COM');
            portNum = str(2);
            handles.laserPortNum = str2double(portNum);
            set(handles.connect2lasers, 'enable', 'on');
            set(handles.laserStatus, 'String', 'Ready to Connect', 'ForegroundColor', [0.2, 0.66, 0.32]);
        catch
            warndlg('No available port detected.');
            set(handles.connect2lasers, 'enable', 'off');
        end
    end
else
    set(handles.connect2lasers, 'enable', 'off');
    set(handles.laserStatus, 'String', 'Invalid port', 'ForegroundColor', [1, 0, 0]);
end
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function laserPortList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
availablePorts = getAvailableComPort();
% availablePorts = {'COM11'};
set(hObject, 'String', [{'Select a port'}, availablePorts]);
guidata(hObject, handles);
end


function connect2lasers_Callback(hObject, eventdata, handles)
disp('Connecting to lasers ...');
set(handles.laserStatus, 'String', 'Connecting ...', 'ForegroundColor', [0.2, 0.66, 0.32]);

portList = get(handles.laserPortList, 'String');
port = get(handles.laserPortList, 'Value');
str = split(portList(port), 'COM');
portNum = str(2);
handles.laserPortNum = str2double(portNum);

% do the connection here
[hObject, eventdata, handles] = connect2lasers(hObject, eventdata, handles);

disp('Succesfully connected to lasers.');
handles.connectedLasers = true;
set(handles.laserStatus, 'String', 'Connected');
set(handles.disconnLasers, 'enable', 'on');
set(hObject, 'enable', 'off');

% check connections %
checkConnections(handles);

set(handles.toggleUV, 'enable', 'on', 'ForegroundColor', [0.3, 0.3, 0.3]);

set(handles.toggleBlue, 'enable', 'on', 'ForegroundColor', [0.3, 0.3, 0.3]);

set(handles.toggleCyan, 'enable', 'on', 'ForegroundColor', [0.3, 0.3, 0.3]);

set(handles.toggleTeal, 'enable', 'on', 'ForegroundColor', [0.3, 0.3, 0.3]);

set(handles.toggleGreen, 'enable', 'on', 'ForegroundColor', [0.3, 0.3, 0.3]);

set(handles.toggleRed, 'enable', 'on', 'ForegroundColor', [0.3, 0.3, 0.3]);

guidata(hObject, handles);
end


function changePower(changed, toBeChanged)
set(toBeChanged, 'Value', str2double(get(changed, 'String')));
set(toBeChanged, 'String', floor(get(changed, 'Value')));
end


function toggleOnOff(button, edit, slider, curState)
if curState == 0
    set(button, 'Value', 0);
    set(button, 'String', 'OFF', 'ForegroundColor', [0.3, 0.3, 0.3]);
    set(edit, 'enable', 'off');
    set(slider, 'enable', 'off');
else
    set(button, 'Value', 1);
    set(button, 'String', 'ON', 'ForegroundColor', [0.2, 0.66, 0.32]);
    set(edit, 'enable', 'on');
    set(slider, 'enable', 'on');
end
end


function turnOffLaser(onOffToggle, powerEdit, slider)
if get(onOffToggle, 'Value') == 1
    % maybe turn it off here, might have to take laser handle as param %
    set(onOffToggle, 'Value', 0);
    set(onOffToggle, 'String', 'OFF', 'BackgroundColor', [0.9, 0.9, 0.9]);
    
    set(powerEdit, 'String', num2str(0));
    changePower(powerEdit, slider);
end
end


% --- Executes on button press in disconnLasers.
function disconnLasers_Callback(hObject, eventdata, handles)
disp('Disconnecting from lasers ...');
set(handles.laserStatus, 'String', 'Disconnecting ...', 'ForegroundColor', [1, 0, 0]);

% reset all laser power to 0 and turn off lasers
% TODO: actually shut them down and reset power to 0 %
turnOffLaser(handles.toggleUV, handles.editUV, handles.sliderUV);
handles.UVOn = 0;
handles.UVPower = 0;

turnOffLaser(handles.toggleBlue, handles.editBlue, handles.sliderBlue);
handles.BlueOn = 0;
handles.BluePower = 0;

turnOffLaser(handles.toggleCyan, handles.editCyan, handles.sliderCyan);
handles.CyanOn = 0;
handles.CyanPower = 0;

turnOffLaser(handles.toggleTeal, handles.editTeal, handles.sliderTeal);
handles.TealOn = 0;
handles.TealPower = 0;

turnOffLaser(handles.toggleGreen, handles.editGreen, handles.sliderGreen);
handles.GreenOn = 0;
handles.GreenPower = 0;

turnOffLaser(handles.toggleRed, handles.editRed, handles.sliderRed);
handles.RedOn = 0;
handles.RedPower = 0;

% disconnect here %
[hObject, eventdata, handles] = disconnLasers(hObject, eventdata, handles);

handles.connectedLasers = false;
handles.laserPortNum = -1;
set(hObject, 'enable', 'off');
set(handles.connect2lasers, 'enable', 'on');

set(handles.toggleUV, 'enable', 'off');
set(handles.editUV, 'enable', 'off');
set(handles.sliderUV, 'enable', 'off');

set(handles.toggleBlue, 'enable', 'off');
set(handles.editBlue, 'enable', 'off');
set(handles.sliderBlue, 'enable', 'off');

set(handles.toggleCyan, 'enable', 'off');
set(handles.editCyan, 'enable', 'off');
set(handles.sliderCyan, 'enable', 'off');

set(handles.toggleTeal, 'enable', 'off');
set(handles.editTeal, 'enable', 'off');
set(handles.sliderTeal, 'enable', 'off');

set(handles.toggleGreen, 'enable', 'off');
set(handles.editGreen, 'enable', 'off');
set(handles.sliderGreen, 'enable', 'off');

set(handles.toggleRed, 'enable', 'off');
set(handles.editRed, 'enable', 'off');
set(handles.sliderRed, 'enable', 'off');

set(handles.startImgButton, 'enable', 'off');
set(handles.laserStatus, 'String', 'Disconnected'); 
set(handles.status, 'String', 'Waiting for instruments to connect', 'ForegroundColor', [1, 0, 0]);
disp('Disconnected from lasers.');

guidata(hObject, handles);
end


function ContSliderDrag(hObject, eventdata)
handles = guidata(hObject);
tag = get(hObject, 'tag');
value = get(hObject, 'Value');
switch tag
    case 'sliderUV'
        set(handles.editUV, 'String', num2str(floor(value)));
    case 'sliderBlue'
        set(handles.editBlue, 'String', num2str(floor(value)));
    case 'sliderCyan'
        set(handles.editCyan, 'String', num2str(floor(value)));
    case 'sliderTeal'
        set(handles.editTeal, 'String', num2str(floor(value)));
    case 'sliderGreen'
        set(handles.editGreen, 'String', num2str(floor(value)));
    case 'sliderRed'
        set(handles.editRed, 'String', num2str(floor(value)));
end
end


% --- Executes on slider movement.
function sliderUV_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.UVPower = floor(get(hObject, 'Value'));
changePower(hObject, handles.editUV);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function sliderUV_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
addlistener(hObject, 'ContinuousValueChange', @(hObject, eventdata) ContSliderDrag(hObject, eventdata));
end


% --- Executes on button press in toggleUV.
function toggleUV_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of toggleUV
toggleOnOff(hObject, handles.editUV, handles.sliderUV, get(hObject, 'Value'));
handles.UVOn = 1 - handles.UVOn;
guidata(hObject, handles);
end


function editUV_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of editUV as text
%        str2double(get(hObject,'String')) returns contents of editUV as a double
prev = handles.UVPower;
power = str2double(get(hObject, 'String'));
if isnan(power) || floor(power) ~= power || power > 255 || power < 0
    set(hObject, 'String', num2str(prev));
    warndlg('Laser power must be an integer in the range of [0, 255]');
else
    handles.UVPower = power;
end
changePower(hObject, handles.sliderUV);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function editUV_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on slider movement.
function sliderBlue_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.BluePower = floor(get(hObject, 'Value'));
changePower(hObject, handles.editBlue);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function sliderBlue_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
addlistener(hObject, 'ContinuousValueChange', @(hObject, eventdata) ContSliderDrag(hObject, eventdata));
end


function editBlue_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of editBlue as text
%        str2double(get(hObject,'String')) returns contents of editBlue as a double
prev = handles.BluePower;
power = str2double(get(hObject, 'String'));
if isnan(power) || floor(power) ~= power || power > 255 || power < 0
    set(hObject, 'String', num2str(prev));
    warndlg('Laser power must be an integer in the range of [0, 255]');
else
    handles.BluePower = power;
end
changePower(hObject, handles.sliderBlue);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function editBlue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in toggleBlue.
function toggleBlue_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of toggleBlue
toggleOnOff(hObject, handles.editBlue, handles.sliderBlue, get(hObject, 'Value'));
handles.BlueOn = 1 - handles.BlueOn;
guidata(hObject, handles);
end


% --- Executes on slider movement.
function sliderCyan_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.CyanPower = floor(get(hObject, 'Value'));
changePower(hObject, handles.editCyan);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function sliderCyan_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
addlistener(hObject, 'ContinuousValueChange', @(hObject, eventdata) ContSliderDrag(hObject, eventdata));
end


function editCyan_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of editCyan as text
%        str2double(get(hObject,'String')) returns contents of editCyan as a double
prev = handles.CyanPower;
power = str2double(get(hObject, 'String'));
if isnan(power) || floor(power) ~= power || power > 255 || power < 0
    set(hObject, 'String', num2str(prev));
    warndlg('Laser power must be an integer in the range of [0, 255]');
else
    handles.CyanPower = power;
end
changePower(hObject, handles.sliderCyan);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function editCyan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in toggleCyan.
function toggleCyan_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of toggleCyan
toggleOnOff(hObject, handles.editCyan, handles.sliderCyan, get(hObject, 'Value'));
handles.CyanOn = 1 - handles.CyanOn;
guidata(hObject, handles);
end


% --- Executes on slider movement.
function sliderTeal_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.TealPower = floor(get(hObject, 'Value'));
changePower(hObject, handles.editTeal);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function sliderTeal_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
addlistener(hObject, 'ContinuousValueChange', @(hObject, eventdata) ContSliderDrag(hObject, eventdata));
end


function editTeal_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of editTeal as text
%        str2double(get(hObject,'String')) returns contents of editTeal as a double
prev = handles.TealPower;
power = str2double(get(hObject, 'String'));
if isnan(power) || floor(power) ~= power || power > 255 || power < 0
    set(hObject, 'String', num2str(prev));
    warndlg('Laser power must be an integer in the range of [0, 255]');
else
    handles.TealPower = power;
end
guidata(hObject, handles);
changePower(hObject, handles.sliderTeal);
end


% --- Executes during object creation, after setting all properties.
function editTeal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in toggleTeal.
function toggleTeal_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of toggleTeal
toggleOnOff(hObject, handles.editTeal, handles.sliderTeal, get(hObject, 'Value'));
handles.TealOn = 1 - handles.TealOn;
guidata(hObject, handles);
end


% --- Executes on slider movement.
function sliderGreen_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.GreenPower = floor(get(hObject, 'Value'));
changePower(hObject, handles.editGreen);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function sliderGreen_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
addlistener(hObject, 'ContinuousValueChange', @(hObject, eventdata) ContSliderDrag(hObject, eventdata));
end


function editGreen_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of editGreen as text
%        str2double(get(hObject,'String')) returns contents of editGreen as a double
prev = handles.GreenPower;
power = str2double(get(hObject, 'String'));
if isnan(power) || floor(power) ~= power || power > 255 || power < 0
    set(hObject, 'String', num2str(prev));
    warndlg('Laser power must be an integer in the range of [0, 255]');
else
    handles.GreenPower = power;
end
guidata(hObject, handles);
changePower(hObject, handles.sliderGreen);
end


% --- Executes during object creation, after setting all properties.
function editGreen_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in toggleGreen.
function toggleGreen_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of toggleGreen
toggleOnOff(hObject, handles.editGreen, handles.sliderGreen, get(hObject, 'Value'));
handles.GreenOn = 1 - handles.GreenOn;
guidata(hObject, handles);
end

% --- Executes on button press in toggleRed.
function toggleRed_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of toggleRed
toggleOnOff(hObject, handles.editRed, handles.sliderRed, get(hObject, 'Value'));
handles.RedOn = 1 - handles.RedOn;
guidata(hObject, handles);
end


function editRed_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of editRed as text
%        str2double(get(hObject,'String')) returns contents of editRed as a double
prev = handles.RedPower;
power = str2double(get(hObject, 'String'));
if isnan(power) || floor(power) ~= power || power > 255 || power < 0
    set(hObject, 'String', num2str(prev));
    warndlg('Laser power must be an integer in the range of [0, 255]');
else
    handles.RedPower = power;
end
guidata(hObject, handles);
changePower(hObject, handles.sliderRed);
end


% --- Executes during object creation, after setting all properties.
function editRed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on slider movement.
function sliderRed_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.RedPower = floor(get(hObject, 'Value'));
changePower(hObject, handles.editRed);
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function sliderRed_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
addlistener(hObject, 'ContinuousValueChange', @(hObject, eventdata) ContSliderDrag(hObject, eventdata));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main Control %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Main Control %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function checkConnections(handles)
if (handles.connectedStage && handles.connectedScope && handles.connectedLasers)
    set(handles.status, 'String', 'Ready', 'ForegroundColor', [0.2, 0.66, 0.32]);
    set(handles.startImgButton, 'enable', 'on');
end
end

% --- Executes on button press in startImgButton.
function startImgButton_Callback(hObject, eventdata, handles)
handles.started = true;
set(handles.status, 'String', 'Started acquisition');
set(handles.pauseORresume, 'enable', 'on');
set(hObject, 'enable', 'off');
concatEnableDisable(hObject, eventdata, handles, false);

% save selected lasers %
laserHandles = [handles.toggleUV, handles.toggleBlue, handles.toggleCyan, handles.toggleTeal, handles.toggleGreen, handles.toggleRed];
handles.lasers = [];
for i = 1:6
    if get(laserHandles(i), 'Value') == 1
        handles.lasers(end+1) = i;
    end
end

set(handles.Quit, 'enable', 'off');
guidata(hObject, handles);
pause(0.05);
% TODO: add start functionality, with concatenation at the end 
% get values from the check boxes here, and append it to 
% handles.selected %

try
    for laser = 1:length(handles.lasers)
        waitfor(handles.pauseORresume, 'Value', 0);
        handles.curLaser = handles.lasers(laser);
        handles.curRow = 1;
        handles.curCol = 1;
        [hObject, eventdata, handles] = acquire(hObject, eventdata, handles);
    end

    handles.finished = true;
    set(handles.status, 'String', 'Acquisition completed', 'ForegroundColor', [0.2, 0.66, 0.32]);
    set(handles.pauseORresume, 'enable', 'off');
    guidata(hObject, handles);
    pause(1);
    set(handles.status, 'String', 'Concatenating images ...');
    [hObject, eventdata, handles] = concatImage(hObject, eventdata, handles);
    set(handles.status, 'String', 'Completed. You may close this window.');
    set(handles.Quit, 'enable', 'on');
    guidata(hObject, handles);
    handles
catch
    disp('Quit.');
end
end

% --- Executes on button press in pauseORresume.
function pauseORresume_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of pauseORresume
try
    handles.paused = get(hObject, 'Value');
    if get(hObject, 'Value') == 1
        % pause %
        set(hObject, 'enable', 'off');
        concatEnableDisable(hObject, eventdata, handles, true);
    else
        % resume %
        set(handles.status, 'String', 'Resumed', 'ForegroundColor', [0.2, 0.66, 0.32]);
        set(hObject, 'String', 'Pause');
        set(handles.Quit, 'enable', 'off');
        concatEnableDisable(hObject, eventdata, handles, false);
        [hObject, eventdata, handles] = acquire(hObject, eventdata, handles);
    end
    guidata(hObject, handles);
catch
    disp('Quit.');
end
end

% --- Executes on button press in Quit.
function Quit_Callback(hObject, eventdata, handles)
figure1_CloseRequestFcn(handles.figure1, eventdata, handles);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% Hint: delete(hObject) closes the figure
if handles.started && handles.paused == false && handles.finished == false
    warndlg('Please pause the experiment before quitting.');
else
    disp('Disconnecting from all instruments before quitting GUI ...');

    [hObject, eventdata, handles] = disconnStage(hObject, eventdata, handles);
    [hObject, eventdata, handles] = disconnScope(hObject, eventdata, handles);
    [hObject, eventdata, handles] = disconnLasers(hObject, eventdata, handles);
    guidata(hObject, handles);

    disp('Quitting GUI ...');
    delete(hObject);
end
end


% --- Executes on button press in concat.
function concat_Callback(hObject, eventdata, handles)
set(handles.selectConcat, 'visible', 'on');
set(handles.concatUV, 'visible', 'on');
set(handles.concatBlue, 'visible', 'on');
set(handles.concatCyan, 'visible', 'on');
set(handles.concatTeal, 'visible' ,'on');
set(handles.concatGreen, 'visible', 'on');
set(handles.concatRed, 'visible', 'on');
set(handles.UVBar, 'visible', 'on');
set(handles.BlueBar, 'visible', 'on');
set(handles.CyanBar, 'visible', 'on');
set(handles.TealBar, 'visible', 'on');
set(handles.GreenBar, 'visible', 'on');
set(handles.RedBar, 'visible', 'on');

guidata(hObject, handles);
end


function concatEnableDisable(hObject, eventdata, handles, onOff)
if onOff
    state = 'on';
else
    state = 'off';
end
set(handles.concat, 'enable', state);
set(handles.concatUV, 'enable', state);
set(handles.concatBlue, 'enable', state);
set(handles.concatCyan, 'enable', state);
set(handles.concatTeal, 'enable' ,state);
set(handles.concatGreen, 'enable', state);
set(handles.concatRed, 'enable', state);
set(handles.UVBar, 'enable', state);
set(handles.BlueBar, 'enable', state);
set(handles.CyanBar, 'enable', state);
set(handles.TealBar, 'enable', state);
set(handles.GreenBar, 'enable', state);
set(handles.RedBar, 'enable', state);
guidata(hObject, handles);
end


% --- Executes on button press in outputDirButton.
function outputDirButton_Callback(hObject, eventdata, handles)
dir = uigetdir;
set(handles.outputDirText,'String',dir);
handles.outputDir = dir;
guidata(hObject, handles);
end


% --- Executes on selection change in outputFormatList.
function outputFormatList_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns outputFormatList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from outputFormatList
end


% --- Executes during object creation, after setting all properties.
function outputFormatList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in concatUV.
function concatUV_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of concatUV
end


% --- Executes on button press in concatBlue.
function concatBlue_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of concatBlue
end


% --- Executes on button press in concatCyan.
function concatCyan_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of concatCyan
end


% --- Executes on button press in concatTeal.
function concatTeal_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of concatTeal
end


% --- Executes on button press in concatGreen.
function concatGreen_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of concatGreen
end


% --- Executes on button press in concatRed.
function concatRed_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of concatRed
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%% Advanced Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Advanced Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in changeChip.
function changeChip_Callback(hObject, eventdata, handles)
set(handles.rowEdit, 'enable', 'on');
set(handles.colEdit, 'enable', 'on');
guidata(hObject, handles);
end


function rowEdit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of rowEdit as text
%        str2double(get(hObject,'String')) returns contents of rowEdit as a double
prev = handles.chipRow;
row = str2double(get(hObject, 'String'));
if isnan(row) || floor(row) ~= row || row < 1
    set(hObject, 'String', num2str(prev));
    warndlg('Chip row must be a positive integer');
else
    handles.chipRow = row;
end
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function rowEdit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function colEdit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of colEdit as text
%        str2double(get(hObject,'String')) returns contents of colEdit as a double
prev = handles.chipCol;
col = str2double(get(hObject, 'String'));
if isnan(col) || floor(col) ~= col || col < 1
    set(hObject, 'String', num2str(prev));
    warndlg('Chip column must be a positive integer');
else
    handles.chipCol = col;
end
guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function colEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in rowPerImgList.
function rowPerImgList_Callback(hObject, eventdata, handles)
end


% --- Executes during object creation, after setting all properties.
function rowPerImgList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in colPerImgList.
function colPerImgList_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns colPerImgList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colPerImgList
end


% --- Executes during object creation, after setting all properties.
function colPerImgList_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in repetitionsList.
function repetitionsList_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns repetitionsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from repetitionsList
end


% --- Executes during object creation, after setting all properties.
function repetitionsList_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end