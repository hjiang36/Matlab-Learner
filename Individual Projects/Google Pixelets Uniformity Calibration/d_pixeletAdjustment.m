%% d_pixeletAdjustment
%
%  Adjust Position and uniformity
%
%  ToDo:
%    1. Save settings
%    2. Load settings
%    3. Calibration by Camera
%    4. Make curve and area adjustment into menu
%
%  See also:
%    calibrationByCamera, setPixContent, imgCapturing
%
%  (HJ) Aug, 2013

function d_pixeletAdjustment
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
prompt = {'Number of Columns','Overlap Size (pixels)'};
dlg_title = 'Init Parameters';
num_lines = 1;
def = {'3','20'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer), return; end
nCols       = str2double(answer{1});
overlapSize = str2double(answer{2});

%% Init Pixelet Structure
hG.pixelets = cell(nCols,1); % Assuming one line at this time
[M,N,K]     = size(Img);
hG.inputImgSz  = [M N];
hG.overlapSize = overlapSize; % store in hG for further use
hG.nCols       = nCols;
hG.inputImg    = Img;
hG             = initPixelets(hG);

%% Display Image on Black Background
tmp = findobj('Tag', 'PixeletAdjustment');
if ~isempty(tmp), close(tmp); end

hG.fig     = figure;
if exist('d_pixeletAdjConfig.mat','file')
    c = load('d_pixeletAdjConfig.mat');
    fig_pos    = c.Pos(1:2);
    fig_width  = c.Pos(3);
    fig_height = c.Pos(4);
else
    fig_pos    = get(hG.fig,'Position')-[200 300 0 0];
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
    'CloseRequestFcn',@onCloseRequest...
    );

% Hide Button
set(hG.fig,'Toolbar','None');
set(hG.fig,'Menu','None');

% Create custom menu bar
mh = uimenu(hG.fig,'Label','File'); 
uimenu(mh,'Label','Load Image','Callback',@loadNewImg);
uimenu(mh,'Label','Save Settings','Callback',@saveSettings);
uimenu(mh,'Label','Load Settings','Callback',@loadSettings);
uimenu(mh,'Label','Quit','Callback','close(gcf); return;',... 
           'Separator','on','Accelerator','Q');

mh = uimenu(hG.fig,'Label','Calibration');
uimenu(mh,'Label','Adj Overlap','Callback',@adjOverlap);
uimenu(mh,'Label','By Camera','Callback',@calByCamera);

% Draw Panels
hG.main = uipanel(... % Main panel - for display composed images
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
set(hG.fig,'WindowButtonMotionFcn', @mouseMove);
set(hG.fig,'WindowButtonDownFcn',@mouseDown);
set(hG.fig,'WindowButtonUpFcn',@mouseUp);
set(hG.fig,'CurrentAxes',hG.ax);

% Init display image
hG.dispI = zeros(round(1.5*M),round(1.5*N),K);


% Draw Pixelets
for curPix = 1 : nCols
    hG.dispI = drawOnCanvas(hG.dispI, hG.pixelets{curPix});
end

% Show Image
hG.imgHandle = imshow(hG.dispI);
%truesize;
%set(hG.imgHandle,'EraseMode','none')

setappdata(hG.fig,'handles',hG);

end

%% Aux Functions
function hG = initPixelets(hG)

M     = hG.inputImgSz(1); 
N     = hG.inputImgSz(2);
Img   = hG.inputImg;
nCols = hG.nCols;
overlapSize = hG.overlapSize;
nonOverlapSize = [M ceil((N - (nCols-1)*overlapSize)/nCols)];

for curPix = 1 : nCols
    % Init Left and Right overlap size
    if curPix == 1
        hG.pixelets{curPix}.overlapL = 0;
    else
        hG.pixelets{curPix}.overlapL = overlapSize;
    end
    if curPix == nCols
        hG.pixelets{curPix}.overlapR = 0;
    else
        hG.pixelets{curPix}.overlapR = overlapSize;
    end
    % Init Blur Region Size
    hG.pixelets{curPix}.blurL = hG.pixelets{curPix}.overlapL; 
    hG.pixelets{curPix}.blurR = hG.pixelets{curPix}.overlapR;
    
    % Init Position
    if ~isfield(hG.pixelets{curPix},'dispPos')
        hG.pixelets{curPix}.dispPos = [1 ...
            (curPix-1)*(nonOverlapSize(2)+overlapSize)+1];
    end
    
    % Init image content size
    hG.pixelets{curPix}.imgContent = ...
        Img(:,(curPix-1)*(nonOverlapSize(2)+overlapSize)+1 ...
            -hG.pixelets{curPix}.overlapL:...
        min(curPix*(nonOverlapSize(2)+overlapSize),N),:);
    
    % Init pixlets display size
    hG.pixelets{curPix}.dispSize = size(hG.pixelets{curPix}.imgContent);
    hG.pixelets{curPix}.dispSize = hG.pixelets{curPix}.dispSize(1:2);
    % Init Mask
    hG.pixelets{curPix}.msk = genBlurMsk([hG.pixelets{curPix}.overlapL...
         hG.pixelets{curPix}.overlapR],size(hG.pixelets{curPix}.imgContent));
    
    % Compute display image
    hG.pixelets{curPix}.dispImg  = hG.pixelets{curPix}.imgContent .* ...
        hG.pixelets{curPix}.msk;
end

end % End of function initPixelets

function Img = drawOnCanvas(Img,pix)
    Img(pix.dispPos(1):pix.dispPos(1)+pix.dispSize(1)-1,...
        pix.dispPos(2):pix.dispPos(2)+pix.dispSize(2)-1,:) = pix.dispImg;
end

function Img = eraseFromCanvas(Img,pix)
    Img(pix.dispPos(1):pix.dispPos(1)+pix.dispSize(1),...
        pix.dispPos(2):pix.dispPos(2)+pix.dispSize(2),:) = 0;
end

function [pixInd,pix] = findPixelet(pixelets, clickPos)
    for pixInd = 1 : length(pixelets)
        pix = pixelets{pixInd};
        if clickPos(1) >= pix.dispPos(1) && ...
           clickPos(1) <= pix.dispPos(1) + pix.dispSize(1) && ...
           clickPos(2) >= pix.dispPos(2) && ...
           clickPos(2) <= pix.dispPos(2) + pix.dispSize(2)
            break;
        end
    end
end


%% Mouse Callbacks
function mouseMove(~,~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    if ~hG.mouseDown, return; end
    curPoint = round(get(gca, 'CurrentPoint'));
    curPix = hG.selected;
    hG.dispI = eraseFromCanvas(hG.dispI,hG.pixelets{curPix});
    hG.pixelets{curPix}.dispPos = hG.pixelets{curPix}.dispPos+...
                                  curPoint(1,[2 1]) - hG.downPos;
    hG.downPos = curPoint(1,[2 1]);
    hG.dispI = drawOnCanvas(hG.dispI,hG.pixelets{curPix});
    %set(hG.imgHandle,'CData',hG.dispI);
    %drawnow;
    imshow(hG.dispI);
    setappdata(hG.fig,'handles',hG);
end

function mouseDown(~,~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    
    if strcmp(get(gca,'units'),'normalized')
        set(gca,'units','pixels');
        pos = get(gca,'CurrentPoint');
        set(gca,'units','normalized');
    else
        pos = get(gca,'CurrentPoint');
    end
    
    [curPix,pix] = findPixelet(hG.pixelets,pos(1,[2 1]));
    if ~curPix, return; end
    
    % Save History
    hG.history.pixelets = hG.pixelets;

    if strcmpi(get(hG.fig,'selectiontype'),'alt') % Right click
        prompt = {'Blur Size (Left)','Blur Size (Right)',...
            'Display Size (Height)', 'Display Size (Width)'};
        dlg_title = 'Adjust Parameters';
        num_lines = 1;
        def = {num2str(pix.blurL),num2str(pix.blurR),...
               num2str(pix.dispSize(1)), num2str(pix.dispSize(2))};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        % Check inputs
        if isempty(answer), return; end
        if any(isnan(str2double(answer))), return; end
        % Deal with Blue Size
        newBlur = str2double(answer(1:2));
        if any(newBlur ~= [pix.blurL; pix.blurR])
            hG.pixelets{curPix}.msk = adjPixBlurSize(pix,newBlur);
            hG.pixelets{curPix}.blurL = newBlur(1);
            hG.pixelets{curPix}.blurR = newBlur(2);
            hG.pixelets{curPix}.dispImg = hG.pixelets{curPix}.imgContent.*...
                    hG.pixelets{curPix}.msk;
        end
        % Deal with dispSize
        if any(pix.dispSize ~= str2double(answer(3:4)'))
            hG.dispI = eraseFromCanvas(hG.dispI,hG.pixelets{curPix});
            hG.pixelets{curPix}.dispSize = [str2double(answer{3})...
                                        str2double(answer{4})];
            hG.pixelets{curPix}.msk = imresize(hG.pixelets{curPix}.msk,...
                hG.pixelets{curPix}.dispSize);
            hG.pixelets{curPix}.dispImg = imresize(hG.pixelets{curPix}.imgContent,...
                hG.pixelets{curPix}.dispSize).*hG.pixelets{curPix}.msk;
        end
        % Draw to Screen
        hG.dispI = drawOnCanvas(hG.dispI,hG.pixelets{curPix});
        imshow(hG.dispI);
        %truesize;
    elseif strcmpi(get(hG.fig,'selectiontype'),'normal') % Left click
        hG.mouseDown = true;
        hG.downPos  = round(pos(1,[2 1]));
        hG.selected = curPix;
    elseif strcmpi(get(hG.fig,'selectiontype'),'open') % Double click
        prompt = {'Mean Luminance (Avg Msk)',...
            'Adjust Direction (0-Horizontal, 1-Vertical 2-Skip)'};
        dlg_title = 'Adjust Msk';
        num_lines = 1;
        originalMean = mean(pix.msk(:));
        def = {num2str(originalMean),'2'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        if isempty(answer), return; end
        scalar = str2double(answer{1})/originalMean;
        hG.pixelets{curPix}.msk = hG.pixelets{curPix}.msk * scalar;
        hG.pixelets{curPix}.dispImg = imresize(hG.pixelets{curPix}.imgContent,...
            hG.pixelets{curPix}.dispSize).*hG.pixelets{curPix}.msk;
        % Draw to Screen
        hG.dispI = drawOnCanvas(hG.dispI,hG.pixelets{curPix});
        imshow(hG.dispI);
        %truesize;
        % Adjust by Curve
        direction = str2double(answer{2});
        if direction == 0 || direction == 1
            hG.pixelets{curPix}.msk = ...
                adjMskByCurve(hG.pixelets{curPix}.msk,direction);
        end
        
        % Adjust by Region
        hG.pixelets{curPix}.msk = adjMskByRegion(hG.pixelets{curPix}.msk);
        hG.pixelets{curPix}.dispImg = imresize(hG.pixelets{curPix}.imgContent,...
            hG.pixelets{curPix}.dispSize).*hG.pixelets{curPix}.msk;
        % Draw to Screen
        hG.dispI = drawOnCanvas(hG.dispI,hG.pixelets{curPix});
        imshow(hG.dispI);
        %truesize;
    end
    setappdata(hG.fig,'handles',hG);
end

function mouseUp(~,~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    hG.mouseDown = false;
    setappdata(hG.fig,'handles',hG);
end

function msk = adjMskByCurve(curMsk, direction)
    fig = figure;
    %[M,N,K] = size(curMsk);
    msk = curMsk;
    if direction == 0
        plot(curMsk(1,:,1),'LineWidth',2);
    else
        plot(curMsk(:,1,1),'LineWdith',2);
    end
    ylim([0 1.1]);
    dcm_obj = datacursormode(fig);
    set(dcm_obj,'DisplayStyle','datatip',...
    'SnapToDataVertex','on','Enable','on');
end

function msk = adjPixBlurSize(pix,newBlur) % New blur contains only l/r now
    msk = pix.msk;
    oldBlurMsk = genBlurMsk([pix.blurL pix.blurR],size(msk));
    newBlurMsk = genBlurMsk(newBlur,size(msk));
    oldBlurMsk(oldBlurMsk == 0) = Inf;
    msk = msk .* newBlurMsk ./ oldBlurMsk;
end

function msk = genBlurMsk(blurSize,mskSize)
    msk = ones(1,mskSize(2));
    msk(1:blurSize(1)) = linspace(0,1,blurSize(1));
    msk(end-blurSize(2)+1:end) = linspace(1,0,blurSize(2));
    msk = repmat(msk,[mskSize(1) 1 mskSize(3)]);
    msk = msk.^(1/2.2);
end

function msk = adjMskByRegion(curMsk)
    img = curMsk(:,:,1); figure;
    imagesc(img); axis off;
    selectedRect = round(getrect); close(gcf);
    selectedBW = zeros(size(img));
    % Constrain Region
    lx = max(selectedRect(2),1);
    ly = max(selectedRect(1),1);
    rx = min(selectedRect(2)+selectedRect(4),size(curMsk,1));
    ry = min(selectedRect(1)+selectedRect(3),size(curMsk,2));
    selectedBW(lx:rx,ly:ry)=1;
    selectedBW = selectedBW > 0;
    prompt = {'Enter new avg','Smooth X', 'Smooth Y', 'Smooth Std'};
    dlg_title = 'Edit Mask';
    num_lines = 1;
    def = {num2str(mean(img(selectedBW>0))),'50','50','15'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if isempty(answer), msk = curMsk; return; end
    % Check input
    if any(isnan(str2double(answer)))
        warning('Only numeric value accepted!');
        return;
    end
    
    % Set and Smooth
    smoothParams = str2double(answer(2:4));
    img(selectedBW) = img(selectedBW) + ...
        str2double(answer{1})-mean(img(selectedBW));
    if all(smoothParams >= 1) 
        gaussFilter = fspecial('gaussian',[50 50],10);
        img = imfilter(img,gaussFilter,'replicate');
    end
    msk = repmat(img,[1 1 3]);
end

%% Keyboard callback
function keyPress(~,evt)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');

    persistent inEdit;
    if isempty(inEdit), inEdit = false; end
    
    curPix = hG.kbSelected;
    if ~curPix
        curPos = get(hG.fig,'Position');
    else
        curPos = hG.pixelets{curPix}.dispPos;
    end
    switch evt.Key
        case 'uparrow'
            if ~inEdit, return; end
            if ~curPix
                set(hG.fig,'Position',[curPos(1) curPos(2)+1 curPos(3:4)]);
                return;
            elseif curPos(1)>1
                hG.pixelets{curPix}.dispPos(1) = curPos(1) - 1;
            end
        case 'downarrow'
            if ~inEdit, return; end
            if ~curPix
                set(hG.fig,'Position',[curPos(1) curPos(2)-1 curPos(3:4)]);
                return;
            elseif curPos(1) < size(hG.dispI,1)
                hG.pixelets{curPix}.dispPos(1) = curPos(1) + 1;
            end
        case 'leftarrow'
            if ~inEdit, return; end
            if ~curPix
                set(hG.fig,'Position',[curPos(1)-1 curPos(2:4)]);
                return;
            elseif curPos(2) > 1
                hG.pixelets{curPix}.dispPos(2) = curPos(2) - 1;
            end
        case 'rightarrow'
            if ~inEdit, return; end
            if ~curPix
                set(hG.fig,'Position',[curPos(1)+1 curPos(2:4)]);
                return;
            elseif curPos(2) < size(hG.dispI,2)
                hG.pixelets{curPix}.dispPos(2) = curPos(2) + 1;
            end
        case 'z'
            % Command Z - revert last operation
            if length(evt.Modifier) == 1 && strcmp(evt.Modifier{1},'command')
                if ~isempty(hG.history)
                    hG.pixelets = hG.history.pixelets;
                    inEdit = false;
                    hG.mouseDown  = false;
                    hG.kbSelected = 1;
                else
                    warning('No steps to be reverted');
                end
            end
        case 'escape'
            inEdit = false;
            return;
        otherwise % Should be number keys - for selecting pixelets
            curPix = floor(str2double(evt.Key));% make sure curPix is int
            if isnan(curPix), return; end
            if curPix ~= 0 && ~isValidPixIndex(curPix) % 0 for whole figure
                return; 
            end
            inEdit = true;
            hG.kbSelected = curPix;
            setappdata(hG.fig,'handles',hG);
            return;
    end
    % Redraw all here
    hG.dispI = zeros(size(hG.dispI));
    for curPix = 1 : length(hG.pixelets)
        hG.dispI = drawOnCanvas(hG.dispI, hG.pixelets{curPix});
    end
    imshow(hG.dispI);
    %truesize;
    setappdata(hG.fig,'handles',hG);
end

function result = isValidPixIndex(pixIndex)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    maxIndx = length(hG.pixelets);
    if pixIndex >= 1 && pixIndex <= maxIndx
        result = true;
    else
        result = false;
    end
end

function onCloseRequest(~,~)
    Pos = get(gcf,'Position');
    save d_pixeletAdjConfig Pos
    delete(gcf);
end

%% Menu bar callbacks
function loadNewImg(~,~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    [FileName,PathName] = uigetfile({'*.jpg;*.jpeg','JPEG Image';...
                                 '*.png','PNG Image';...
                                 '*.*','All Files'});

    if FileName == 0, return; end
    Img = im2double(imread(fullfile(PathName,FileName)));
    hG  = setPixContent(hG,Img);
    % Redraw all here
    hG.dispI = zeros(size(hG.dispI));
    for curPix = 1 : length(hG.pixelets)
        hG.dispI = drawOnCanvas(hG.dispI, hG.pixelets{curPix});
    end
    imshow(hG.dispI);
    %truesize;
    setappdata(hG.fig,'handles',hG);
end

function saveSettings(~,~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    save pixeletSettings.mat hG
    msgbox('Saved');
end

function loadSettings(~,~)
    if exist('pixeletSettings.mat','file');
        c  = load('pixeletSettings.mat');
        hG = c.hG;
        imshow(hG.dispI);
        setappdata(hG.fig,'handles',hG);
    else
        msgbox('Cannot find settings file');
    end
end

function calByCamera(~,~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    It = im2double(imread('google_s.jpg'));
    Id = ones(size(It));
    hG = calibrationByCamera(hG,It,Id);
    setappdata(hG.fig,'handles',hG);
end

function adjOverlap(~,~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    prompt = {'Overlap Size (pixels)'};
    dlg_title = 'Adjust Overlap';
    num_lines = 1;
    def = {num2str(hG.overlapSize)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
   
    if isempty(answer), return; end
    overlapSize = str2double(answer{1});
    if overlapSize ~= hG.overlapSize
        hG.overlapSize = overlapSize;
        hG = initPixelets(hG);
    end
    % Redraw all here
    hG.dispI = zeros(size(hG.dispI));
    for curPix = 1 : length(hG.pixelets)
        hG.dispI = drawOnCanvas(hG.dispI, hG.pixelets{curPix});
    end
    imshow(hG.dispI);
    setappdata(hG.fig,'handles',hG);
end