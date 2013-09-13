%% s_pixeletAdjuster
%    main entrance of pixeltet adjuster GUI
%
%  Toolbox Required:
%    Image Processing Toolbox
%    Image Aquisition Toolbox
%
%  Supported functionalities:
%
%
%  ToDo:
%    1. Calibration by Camera
%    2. Make curve and area adjustment into menu
%    3. Auto magnification adjustment
%    4. Export to OpenGL usable format
%
%  See also:
%    calibrationByCamera, setPixContent, imgCapturing
%
%  (HJ) Aug, 2013

function s_pixeletAdjuster
%% Load Image File
[FileName,PathName] = uigetfile({'*.jpg;*.jpeg','JPEG Image';...
                                 '*.png','PNG Image';...
                                 '*.*','All Files'});

if FileName == 0, return; end

Img = im2double(imread(fullfile(PathName,FileName)));

%% Crop Image if too large
maxRes = [600 800];

if size(Img,1) > maxRes(1) || size(Img,2) > maxRes(2)
    Img = Img(1:maxRes(1),1:maxRes(2),:);
end

%% Load Init Parameters
prompt = {'Number of Columns', ...
          'Number of Rows', ...
          'Overlap Size (pixels)'};
dlg_title = 'Init Parameters';
def = {'3', '1', '20'};
answer = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer), return; end
hG.nCols       = str2double(answer{1});
hG.nRows       = str2double(answer{2});
hG.overlapSize = str2double(answer{3});

%% Init Pixelet Structure
hG.pixelets      = cell(hG.nRows, hG.nCols);
[M,N,K]          = size(Img);
hG.inputImgSz    = [M N];
hG.inputImg      = Img;
hG.saveWindowPos = true;
hG               = initPixelets(hG);
% hG.pixelets = pixeletsFromImage(Image, [nRows nCols], overlap);

%% Display Image on Black Background
%  if pixelet adjuster exist, close it
tmp = findobj('Tag', 'PixeletAdjustment');
if ~isempty(tmp), close(tmp); end

%  create figure
hG.fig     = figure;
iptsetpref('ImshowBorder','tight');
if exist('pixeletSettings.mat','file')
    c = load('pixeletSettings.mat');
    c.Pos(1:2) = max(c.Pos(1:2),[0 0]);
    fig_pos    = c.Pos(1:2);
    fig_width  = c.Pos(3);
    fig_height = c.Pos(4);
else
    fig_pos    = [400 0];
    fig_width  = 800;
    fig_height = 600;
end

set(hG.fig,...
    'Tag', 'PixeletAdjustment',...
    'NumberTitle','Off',...
    'Resize','on',...
    'Position',[fig_pos(1),fig_pos(2),fig_width,fig_height],...
    'Name','Pixelets Adjustment Demo',...
    'KeyPressFcn',@keyPress,...
    'Interruptible', 'off', ...
    'CloseRequestFcn',@onCloseRequest...
    );

% Hide Button
set(hG.fig,'Toolbar','None');
set(hG.fig,'Menu','None');

% Create custom menu bar
mh = uimenu(hG.fig,'Label','File'); 
uimenu(mh, 'Label', 'Load Image', 'Callback',    @paMenuLoadImg);
uimenu(mh, 'Label', 'Save Settings', 'Callback', @paMenuSaveSettings);
uimenu(mh, 'Label', 'Load Settings', 'Callback', @paMenuLoadSettings);
uimenu(mh, 'Label', 'Clear Settings', 'Callback',@paMenuClearSettings);
uimenu(mh, 'Label', 'Clear Window Pos', 'Callback', @paMenuClearWindowPos);
uimenu(mh, 'Label', 'Quit','Callback', 'close(gcf); return;',... 
           'Separator', 'on', 'Accelerator', 'Q');

mh = uimenu(hG.fig,'Label','Calibration');
uimenu(mh, 'Label', 'By Camera (Manual)','Callback',@paCalByCameraManual);
uimenu(mh, 'Label', 'By Camera (Auto)', 'Callback', @paCalByCameraAuto);
uimenu(mh, 'Label', 'Magnification', 'Callback',    @paCalMagnification);

mh = uimenu(hG.fig, 'Label', 'Adjustment');
uimenu(mh,'Label','Adj Overlap','Callback',@adjOverlap);
uimenu(mh, 'Label', 'Adj Total Size', 'Callback', @adjTotalSize);

% Draw Panels
hG.main = uipanel(... % Main panel
    'Title', 'Dispaly Area',...
    'Parent',hG.fig,...
    'Position', [0.005 0.01 0.99 0.98],...
    'BackgroundColor',get(gcf,'Color')...
    );
% Draw Axis
axColor = [0.9 0.9 0.9];
hG.ax = axes(...
    'Parent', hG.main,...
    'Position', [0.01 0.01 0.98 0.98],...
    'Xtick',[], 'Xcolor', axColor,...
    'YTick',[], 'Ycolor', axColor,...
    'color', axColor,...
    'ButtonDownFcn', ''...
    );

% Init Parameters
hG.history    = [];
hG.mouseDown  = false;
hG.kbSelected = 1;

% Set Callbacks
set(hG.fig, 'WindowButtonMotionFcn', @paMouseMove);
set(hG.fig, 'WindowButtonDownFcn', @mouseDown);
set(hG.fig, 'WindowButtonUpFcn',@paMouseUp);
set(hG.fig, 'CurrentAxes', hG.ax);

% Init display image
hG.dispI = zeros(round(1.2*M),round(1.2*N),K);


% Draw Pixelets
hG.dispI = refreshPixelets(hG);
setappdata(hG.fig,'handles',hG);

end