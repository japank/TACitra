function varargout = Pengelompokkan(varargin)
% PENGELOMPOKKAN MATLAB code for Pengelompokkan.fig
%      PENGELOMPOKKAN, by itself, creates a new PENGELOMPOKKAN or raises the existing
%      singleton*.
%
%      H = PENGELOMPOKKAN returns the handle to a new PENGELOMPOKKAN or the handle to
%      the existing singleton*.
%
%      PENGELOMPOKKAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PENGELOMPOKKAN.M with the given input arguments.
%
%      PENGELOMPOKKAN('Property','Value',...) creates a new PENGELOMPOKKAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Pengelompokkan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Pengelompokkan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Pengelompokkan

% Last Modified by GUIDE v2.5 01-Dec-2020 14:17:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Pengelompokkan_OpeningFcn, ...
                   'gui_OutputFcn',  @Pengelompokkan_OutputFcn, ...
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


% --- Executes just before Pengelompokkan is made visible.
function Pengelompokkan_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Pengelompokkan (see VARARGIN)

% Choose default command line output for Pengelompokkan
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Pengelompokkan wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Pengelompokkan_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = uigetdir();
nama_folder = sprintf('%s', folder);
%nama_folder = 'dataset';
% membaca nama file yang berformat jpg
nama_file = dir(fullfile(nama_folder,'*.jpg'));
% menghitung jumlah file yang dibaca
jumlah_file = numel(nama_file);
% menginisialisasi variabel ciri
% melakukan ekstraksi ciri terhadap seluruh file yang dibaca
for n = 1:jumlah_file
    % membaca file citra
    Img = imread(fullfile(nama_folder,nama_file(n).name));
   %rezise
    Img = imresize(Img,[500,500]);
    %merubah ruang warna
    bw = im2bw(Img,0.5);
    %melakukan operasi crop
    bw = imcrop(bw, [50, 50, 300, 300]);
    % melakukan median filtering
    bw = medfilt2(~bw,[5,5]);
    %Penajaman gambar pada gambar dengan Highpass Filter
    hpf1=[-1 -1 -1;-1 8 -1;-1 -1 -1]; 
    bw=uint8(conv2(double(bw),hpf1,'same'));
    %segmentasi
    m = zeros(size(bw,1),size(bw,2)); 
    m(59:200,100:200) = 1; 
    bw = activecontour(bw,m,350); 
     % melakukan operasi morfologi filling holes
    bw = imfill(bw,'holes');
    % melakukan operasi morfologi area opening
    bw = bwareaopen(bw,750);
     %segmentasi garis
   % bw= edge(bw,'roberts'); 
   
    str = strel('disk',5);
    bw = imdilate(bw,str);
   
    % melakukan ekstraksi ciri terhadap citra biner hasil thresholding
    stats1  = regionprops(bw, 'all');
    area = stats1.Area;
    perimeter = stats1.Perimeter;
    eccentricity1 = stats1.Eccentricity;
    metric1 = 4*pi*area/perimeter^2;
    ece(n) = mean(eccentricity1);
    met(n) = mean(metric1);
    X = [ece;met]';
end
 
opts = statset('Display','final');
%k-means clustering berdasarkan bentuk dan ukuran, dengan cluster berjumlah 2
[idx,C] = kmeans(X,2);
 
%tampilkan hasil clustering
axes(handles.axes1);
plot(X(idx==2,1),X(idx==2,2),'r.','MarkerSize',24)%cluster 1
hold on
plot(X(idx==1,1),X(idx==1,2),'g.','MarkerSize',24)%cluster 2
legend('Cluster 1(motor)','Cluster 2(mobil)','Location','best')%window detail
title('Cluster ')%judul
xlabel('ukuran')%kordinat x
ylabel('bentuk')%kordinat y
h = gca;
xlim(h.XLim+.5*[-1,1])%batas sumbu x
ylim(h.YLim+.5*[-1,1])%batas sumbu y
hold off
 
%klasifikasi tidak terbimbing
 
Y = cell(numel(idx),1);%menghitung elemen di matrix idx
for n = 1:numel(Y)
 if idx(n,:) == 1
 Y{n,:} = 'motor';
 elseif idx(n,:) == 2
 Y{n,:} = 'mobil';
 end
 string1 = strcat(num2str(n),'.jpg :',sprintf(Y{n,:}));
 Y{n} = string1;

end
set(handles.edit1, 'String', Y);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text3.
function text3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




