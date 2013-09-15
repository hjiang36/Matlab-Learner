%% s_pixeletAdjuster
%    main entrance of pixeltet adjuster GUI
%
%  Toolbox Required:
%    Image Processing Toolbox
%    Image Aquisition Toolbox
%
%  Supported functionalities:
%    Basic:
%      - Image replication and pixelet formation
%      - Settings saving / loading / clearing
%      - Export to OpenGL pixelet renderer supported format
%      - Revert last operation
%
%    Adjustments:
%      - Pixelet position adjustment (mouse dragging)
%      - Pixelet position adjustment (keyboard selection)
%      - Window position adjustment  (keyboard)
%      - Pixelet blur size adjustment
%      - Pixelet display size adjustment
%      - Pixelet mask mean value adjustment
%      - Pixelet mask region adjustment
%      - Pixelet overlap size adjustment
%      - Pixelet gap size adjustment
%
%    Calibration:
%      - Camera calibration for uniformity (semi-auto)
%      - Camera calibration for position
%      - Camera calibration for uniformity (auto)
%
%  ToDo:
%    1. Calibration by Camera
%    2. Make curve and area adjustment into menu
%    3. Auto magnification adjustment
%    4. Export to OpenGL usable format
%
%  See also:
%    pixeletsFromImage, pixeletGet, pixeletSet
%
%  (HJ) Aug, 2013

%% Clean up
clc; clear;

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
          'Horizontal Overlap Size', ...
          'Vertical Overlap Size'};
dlg_title = 'Init Parameters';
def = {'3', '1', '20', '20'};
answer = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer), return; end
hG.nCols       = str2double(answer{1});
hG.nRows       = str2double(answer{2});
hG.overlapSize = [str2double(answer{3}) str2double(answer{4})];

%% Init Pixelet Structure
hG.pixelets      = cell(hG.nRows, hG.nCols);
[M,N,K]          = size(Img);
hG.inputImgSz    = [M N];
hG.inputImg      = Img;
hG.saveWindowPos = true;
hG.gapSize       = [20 20]; % Should change to user inputs
hG.pixelets      = pixeletsFromImage(Img, hG.nRows, hG.nCols, ...
                    hG.overlapSize, hG.gapSize);

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
    'KeyPressFcn',@paKbPressed,...
    'Interruptible', 'off', ...
    'CloseRequestFcn',@paOnCloseRequest...
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
uimenu(mh, 'Label', 'Adj Overlap','Callback', @paAdjOverlap);
uimenu(mh, 'Label', 'Adj Total Size', 'Callback', @paAdjTotalSize);
uimenu(mh, 'Label', 'Adj Gap Size', 'Callback', @paAdjGapSize);

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
set(hG.fig, 'WindowButtonDownFcn', @paMouseDown);
set(hG.fig, 'WindowButtonUpFcn',@paMouseUp);
set(hG.fig, 'CurrentAxes', hG.ax);

% Init display image
hG.dispI = zeros(round(1.2*M), round(1.2*N), K);


% Draw Pixelets
hG.dispI = refreshPixelets(hG);
setappdata(hG.fig,'handles',hG);