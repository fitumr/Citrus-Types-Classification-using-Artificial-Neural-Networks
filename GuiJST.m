function varargout = GuiJST(varargin)
% GuiJST MATLAB code for GuiJST.fig
%      GuiJST, by itself, creates a new GuiJST or raises the existing
%      singleton*.
%
%      H = GuiJST returns the handle to a new GuiJST or the handle to
%      the existing singleton*.
%
%      GuiJST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GuiJST.M with the given input arguments.
%
%      GuiJST('Property','Value',...) creates a new GuiJST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GuiJST_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GuiJST_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GuiJST

% Last Modified by GUIDE v2.5 24-Apr-2024 00:19:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GuiJST_OpeningFcn, ...
                   'gui_OutputFcn',  @GuiJST_OutputFcn, ...
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

% --- Executes just before GuiJST is made visible.
function GuiJST_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GuiJST (see VARARGIN)

% Choose default command line output for GuiJST
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%buat axes
axesbg = axes("unit","normalized","position", [0 0 1 1]);
%import bg
bg = imread('contoh.jpg'); imagesc(bg);
%matikan axes dan tampilkan bg
set(axesbg, 'handlevisibility','off','visible','off')

% UIWAIT makes GuiJST wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GuiJST_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName]=uigetfile('*.*');
I = imread(fullfile(PathName,FileName));
handles.I=I;
guidata(hObject,handles);
axes(handles.axes1);
imshow(I);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, ~, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Mengambil gambar dari handles.I
I = handles.I;

% Konversi gambar ke ruang warna HSV
I_hsv = rgb2hsv(I);

% Menyimpan gambar HSV ke dalam handles.Data
handles.I_hsv = I_hsv;

% Memperbarui data guidata dengan gambar yang telah diresize
guidata(hObject, handles);

% Menampilkan gambar yang telah diresize di axes2
axes(handles.axes2);
imshow(I_hsv);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, ~, handles)
I_hsv = handles.I_hsv;

% Ambil saluran warna Hue (H) dan Saturation (S)
H = I_hsv(:,:,1);
S = I_hsv(:,:,2);

% Threshold untuk mengidentifikasi warna kuning
yellow_mask = (H >= 0.1 & H <= 0.2) & (S >= 0.4 & S <= 1);

% Threshold untuk mengidentifikasi warna hijau
green_mask = (H >= 0.2 & H <= 0.4) & (S >= 0.4 & S <= 1);

% Gabungkan kedua masker
fruit_mask = yellow_mask | green_mask;

% Menyimpan gambar HSV ke dalam handles.Data
handles.Data = fruit_mask;

% Memperbarui data guidata dengan gambar yang telah diproses
guidata(hObject, handles);

% Menampilkan gambar biner yang telah diproses di axes3
axes(handles.axes3);
imshow(fruit_mask);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, ~, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Mengambil data citra dari objek handles
fruit_mask = handles.Data;
I = handles.I;

% Operasi morfologi (Dilasi)
se = strel('disk', 4);
dilasi = imdilate(fruit_mask, se);
guidata(hObject, handles);

% Menampilkan citra hasil closing pada axes ke-5
axes(handles.axes5)
imshow(dilasi);

% Operasi morfologi (closing)
se2 = strel('disk', 10);
close = imclose(dilasi, se2);
handles.Data = close;
guidata(hObject, handles);
axes(handles.axes6)
imshow(close);

% Tampilkan overlay hasil segmentasi ke gambar asli
segmented_overlay = imoverlay(I, close, [0, 0, 0]);
guidata(hObject, handles);
axes(handles.axes7)
imshow(segmented_overlay);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, ~, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Deteksi objek pada gambar yang telah disegmentasi
I = handles.I;
close = handles.Data;
props = regionprops(close, 'Area', 'Perimeter', 'BoundingBox', 'Centroid', 'Eccentricity', 'Orientation');

% Tampilkan gambar asli dengan kotak pembatas dan label untuk setiap objek
axes(handles.axes8);
imshow(I);
hold on
for i = 1:numel(props)
    rectangle('Position', props(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
end
hold off
guidata(hObject, handles);

function pushbutton6_Callback(hObject, ~, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
C = handles.Data;

stats = regionprops(C, 'Area', 'Perimeter', 'Solidity', 'Eccentricity');
Area = stats.Area;
Perimeter = stats.Perimeter;
Solidity = stats.Solidity;
Eccentricity = stats.Eccentricity;

% Calculate shape features based on Metric and Eccentricity parameters
Metric = Perimeter^2 / (4 * pi * Area);

fitur_solidity = Solidity;
fitur_metric = Metric;
fitur_eccentricity = Eccentricity;

% Store extracted features in handles structure
handles.fitur_solidity = fitur_solidity;
handles.fitur_metric = fitur_metric;
handles.fitur_eccentricity = fitur_eccentricity;

% Update edit fields with the extracted features
set(handles.edit1, 'String', fitur_solidity);
set(handles.edit2, 'String', fitur_metric);
set(handles.edit3, 'String', fitur_eccentricity);

% Update handles structure
guidata(hObject, handles);

function pushbutton7_Callback(~, ~, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Extract features from handles structure
fitur_solidity = handles.fitur_solidity;
fitur_metric = handles.fitur_metric;
fitur_eccentricity = handles.fitur_eccentricity;

% Combine features into a feature matrix
input = [fitur_solidity; fitur_metric; fitur_eccentricity];

% Load trained neural network model
load mdl802.mat net;

% Perform inference using the neural network
output = round(sim(net, input));

% Determine the class based on the output
switch output
    case 1
        kelas = 'Lemon';
    case 2
        kelas = 'Nipis';
    case 3
        kelas = 'Sunkist';
    otherwise
        kelas = 'Tidak Dikenali';
end

% Update the edit field with the predicted class
set(handles.edit4, 'String', kelas);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(~, ~, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes (handles.axes1);
cla reset
axes (handles.axes2);
cla reset
axes (handles.axes3);
cla reset
axes (handles.axes5);
cla reset
axes (handles.axes6);
cla reset
axes (handles.axes7);
cla reset
axes (handles.axes8);
cla reset

set(handles.edit1,'String',' ')
set(handles.edit2,'String',' ')
set(handles.edit3,'String',' ')
set(handles.edit4,'String',' ')
cla reset

function edit3_Callback(~, ~, ~)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
% --- Executes during object creation, after setting all properties.

function edit3_CreateFcn(hObject, ~, ~)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(~, ~, ~)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
% --- Executes during object creation, after setting all properties.

function edit2_CreateFcn(hObject, ~, ~)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(~, ~, ~)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
% --- Executes during object creation, after setting all properties.

function edit1_CreateFcn(hObject, ~, ~)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(~, ~, ~)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
% --- Executes during object creation, after setting all properties.

function edit4_CreateFcn(hObject, ~, ~)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton7.

function pushbutton7_ButtonDownFcn(~, ~, ~)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)