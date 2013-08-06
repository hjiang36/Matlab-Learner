%% Image Composing
%  Gui File for Poison Seamless composing
%  Written By HJ, 2013

function g_PoisonSeamlessComposing

% Init
tmp = findobj('Tag', 'ImageComposing_window');
if ~isempty(tmp), close(tmp); end

% Make new GUI window
hG.fig     = figure;
fig_pos    = get(hG.fig,'Position');
fig_width  = 800;
fig_height = 600;


set(hG.fig,...
    'Tag', 'ImageComposing_window',...
    'NumberTitle','Off',...
    'Resize','Off',...
    'Position',[fig_pos(1)-200,fig_pos(2)-300,fig_width,fig_height],...
    'Name','Image Composing'...
    );

% Hide Button
set(hG.fig,'Toolbar','None');
set(hG.fig,'Menu','None');

% Draw Panels
hG.main = uipanel(... % Main panel - for display composed images
    'Title', 'Combined/Composed Image',...
    'Parent',hG.fig,...
    'Position', [0.005 0.01 0.65 0.49],...
    'BackgroundColor',get(gcf,'Color')...
    );

hG.composed = uipanel(... % Edit Panel - for editing src Image
    'Title', 'Source Image',...
    'Parent', hG.fig,...
    'Position', [0.005 0.5 0.65 0.49],...
    'BackgroundColor', get(gcf,'Color')...
    );

hG.control = uipanel(... % Control panel - for user controls
    'Title','Control',...
    'Parent',hG.fig,...
    'Position', [0.66 0.01 0.32 0.98],...
    'BackgroundColor',get(gcf,'Color')...
    );

% Draw Objects - Axes to show color
axColor = [0.9 0.9 0.9];
hG.axComp = axes(...
    'Parent', hG.composed,...
    'Position', [0.05 0.05 0.7 0.9],...
    'Xtick',[], 'Xcolor', axColor,...
    'YTick',[], 'Ycolor', axColor,...
    'color', axColor,...
    'ButtonDownFcn', ''...
    );

hG.ax = axes(...
    'Parent', hG.main,...
    'Position', [0.15 0.05 0.7 0.9],...
    'Xtick',[], 'Xcolor', axColor,...
    'YTick',[], 'Ycolor', axColor,...
    'color', axColor,...
    'ButtonDownFcn', ''...
    );

set(hG.fig,'CurrentAxes',hG.ax);

% Draw Objects - Text Box
hG.infoBox = uicontrol(...% Text field to show x position
    'Parent', hG.control, ...
    'Style',  'Text', ...
    'Units',  'Normalized',...
    'Position', [0.75 0.05 0.2 0.05],...
    'String', 'X',...
    'BackgroundColor', get(gcf,'Color')...
    );

hG.infoBoxY = uicontrol(...% Text field to show current y position
    'Parent', hG.control, ...
    'Style',  'Text', ...
    'Units',  'Normalized',...
    'Position', [0.45 0.05 0.2 0.05],...
    'String', 'Y',...
    'BackgroundColor', get(gcf,'Color')...
    );
% Draw Objects - Load Src and Tgt File
hG.loadTgtImg = uicontrol(...% Button to load target file
    'Parent', hG.control,...
    'Style', 'PushButton',...
    'Units', 'Normalized',...
    'Position', [0.6 0.9 0.3 0.03],...
    'String', 'Load Tgt Img',...
    'BackgroundColor', get(gcf,'Color'),...
    'Callback', @loadImgFile ...
    );

hG.tgtFilePath = uicontrol(...% Text input field of target file
    'Parent', hG.control,...
    'Style', 'text',...
    'Units', 'Normalized',...
    'Position', [0.15 0.902 0.4 0.025],...
    'String', './sky.jpeg',...
    'Enable', 'off'...
    );

hG.loadSrcImg = uicontrol(...% Button to load target file
    'Parent', hG.control,...
    'Style', 'PushButton',...
    'Units', 'Normalized',...
    'Position', [0.6 0.8 0.3 0.03],...
    'String', 'Load Src Img',...
    'BackgroundColor', get(gcf,'Color'),...
    'Callback', @loadImgFile ...
    );

hG.srcFilePath = uicontrol(...% Text input field of target file
    'Parent', hG.control,...
    'Style', 'text',...
    'Units', 'Normalized',...
    'Position', [0.15 0.802 0.4 0.025],...
    'String', './plane.png',...
    'Enable', 'off'...
    );

% Draw Parameter Inputs
hG.infoBoxCompParam = uicontrol(...% Text field - composing parameter
    'Parent', hG.control, ...
    'Style',  'Text', ...
    'Units',  'Normalized',...
    'Position', [0.15 0.7 0.3 0.04],...
    'String', 'Composing Parameter',...
    'BackgroundColor', get(gcf,'Color')...
    );

hG.setParams = uicontrol(...% Text input field of composing parameter
    'Parent', hG.control,...
    'Style', 'edit',...
    'Units', 'Normalized',...
    'Position', [0.45 0.7 0.3 0.04],...
    'String', ''...
    );

% Draw Checkbox - show composed Image
hG.showComposedImage = uicontrol(... % Check box
    'Parent', hG.control,...
    'Style', 'Checkbox',...
    'Value', 0,...
    'Units', 'Normalized',...
    'Position', [0.1 0.6 0.4 0.025],...
    'String', 'Show Composed Image',...
    'Callback', @showComposedImage...
    );

% Draw Button - Mark ROI
hG.markROI = uicontrol(... % Button - mark region of interest
    'Parent', hG.composed,...
    'Style', 'PushButton',...
    'String', 'Mark ROI',...
    'Units', 'Normalized',...
    'Position', [0.8 0.7 0.18 0.07],...
    'Callback', @markROI...
    );

% Draw Toggle Button - Mark foreground
hG.markForeground = uicontrol(... % Toggle Button - Mark foreground
    'Parent', hG.composed,...
    'Style', 'ToggleButton',...
    'Value', 0,...
    'String', 'Mark Foreground',...
    'Units', 'Normalized',...
    'Position', [0.8 0.6 0.18 0.07],...
    'Callback', @editSrc...
    );

% Draw Toggle Button - Mark background
hG.markBackground = uicontrol(... % Toggle Button - Mark foreground
    'Parent', hG.composed,...
    'Style', 'ToggleButton',...
    'Value', 0,...
    'String', 'Mark Background',...
    'Units', 'Normalized',...
    'Position', [0.8 0.5 0.18 0.07],...
    'Callback', @editSrc...
    );
% Draw Process Button
hG.processSrc = uicontrol(... % Process Source Image Button
    'Parent', hG.composed,...
    'Style', 'PushButton',...
    'String','Process',...
    'Units', 'Normalized',...
    'Position',[0.8 0.4 0.18 0.07],...
    'Callback',@processSrc...
    );

%% Init Panel Data
hG.tgtImg = im2double(imread('sky.jpeg'));
hG.srcImg = im2double(imread('plane.png'));
hG.srcPos = [1 1];
hG.Lf = imGradFeature(hG.tgtImg);
hG.Gf = imGradFeature(hG.srcImg);
hG.mouseDown = false;
hG.isInEdit = false;
[M,N,~] = size(hG.srcImg);
hG.L = ones(M,N);
hG.showComposedImage = false;
hG.Beta = 0.4; hG.k = 5; hG.G = 50;
hG.maxIter = 10;
hG.thresh = 0.01;
set(hG.fig,'WindowButtonMotionFcn', @mouseMove);
set(hG.fig,'WindowButtonDownFcn',@mouseDown);
set(hG.fig,'WindowButtonUpFcn',@mouseUp);
setappdata(hG.fig,'handles',hG);
imshow(hG.srcImg,'parent',hG.axComp);
composeImage;
end

%% Define Callbacks
function composeImage
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    [M,N,~] = size(hG.srcImg);
    [m,n,~] = size(hG.tgtImg);
    if ~hG.showComposedImage
        opacity = repmat(double(hG.L),[1 1 3]);
        I1 = padarray(hG.tgtImg,[M N],'post');
        I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:) = ...
            I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:).*opacity+...
            (1-opacity).*hG.srcImg;
        I1 = I1(1:m,1:n,:);
        imshow(I1);
    else
        I1 = padarray(hG.Lf,[M N],'post');
        hG.L = ones(M,N);
        %Find right
        gI = abs(sum(I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:,2),3)-...
            sum(hG.Gf(:,:,:,2),3));
        gI(:,1:round(N/2)) = inf; gI(~hG.fixedBG) = inf;
        hG.L = hG.L & findMinGradientBound(gI,'right');
        % Find Left
        gI = abs(sum(I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:,4),3)-...
            sum(hG.Gf(:,:,:,4),3));
        gI(:,round(N/2):end) = inf; gI(~hG.fixedBG) = inf;
        hG.L = hG.L & findMinGradientBound(gI,'left');
        % Find Top
        gI = abs(sum(I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:,3),3)-...
            sum(hG.Gf(:,:,:,3),3));
        gI(round(M/2):end,:) = inf; gI(~hG.fixedBG) = inf;
        %kk = findMinGradientBound(gI,'top');
        hG.L = hG.L & findMinGradientBound(gI,'top');
        % Find Buttom
        gI = abs(sum(I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:,5),3)-...
            sum(hG.Gf(:,:,:,5),3));
        gI(1:round(M/2),:) = inf; gI(~hG.fixedBG) = inf;
        hG.L = hG.L & findMinGradientBound(gI,'buttom');
        
        imshow(hG.srcImg*0.5+0.5*hG.srcImg.*repmat((hG.L),[1 1 3]),'parent',hG.axComp);
        set(hG.fig,'CurrentAxes',hG.ax);
        
        % Compose
        opacity = repmat(double(~hG.L),[1 1 3 5]);
        I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:,:) = ...
            I1(hG.srcPos(2):hG.srcPos(2)+M-1,hG.srcPos(1):hG.srcPos(1)+N-1,:,:).*opacity+...
            (1-opacity).*hG.Gf;
        param = buildModPoissonParam(size(I1));
        thresh = get(hG.setParams,'String');
        if ~isempty(thresh)
            thresh = str2double(thresh);
        else
            thresh = 1E-8;
        end
        Y = modPoisson(I1, param, thresh);
        Y = Y(1:m,1:n,:);
        imshow(Y);
    end
end

function mouseDown(~,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    if strcmp(get(gca,'units'),'normalized')
        set(gca,'units','pixels');
        pos = get(gca,'CurrentPoint');
        set(gca,'units','normalized');
    else
        pos = get(gca,'CurrentPoint');
    end
    if gca == hG.ax
        [M,N,~] = size(hG.tgtImg);
    else
        [M,N,~] = size(hG.srcImg);
    end
    if pos(1,1)>1 && pos(1,1)<=N && pos(1,2) > 1 && pos(1,2) <= M 
        hG.mouseDown = true;
        hG.downPos = round(pos(1,1:2));
        setappdata(hG.fig,'handles',hG);
    end
    
end

function mouseUp(~,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    hG.mouseDown = false;
    hG.maxIter = 1;
    hG.k = 2;
    if hG.isInEdit
        if get(hG.markForeground,'Value')
            hG.L = GCAlgo(255*hG.srcImg,hG.fixedBG - hG.L +1,hG.k,hG.G,hG.maxIter,...
                hG.Beta, hG.thresh);
        else
            hG.L = GCAlgo(255*hG.srcImg,hG.fixedBG,hG.k,hG.G,hG.maxIter,...
                hG.Beta, hG.thresh);
        end
        hG.fixedBG = hG.L;
        imshow(hG.srcImg.*repmat(1+double(~hG.L),[1 1 3])*0.5,'parent',hG.axComp);
        set(hG.fig,'CurrentAxes', hG.ax);
    end
    setappdata(hG.fig,'handles',hG);
end

function mouseMove(~,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    C = round(get(gca, 'CurrentPoint'));
    if hG.mouseDown
        if gca == hG.ax % Adjust Src Position
            [M,N,~] = size(hG.tgtImg);
            %[m,n,~] = size(hG.srcImg);
            hG.srcPos = hG.srcPos + C(1,1:2) - hG.downPos;
            hG.downPos = C(1,1:2);
            hG.srcPos = min(max([1 1],hG.srcPos),[N M]);
            setappdata(hG.fig,'handles',hG);
            composeImage;
        elseif hG.isInEdit % Mark Src
            hold on;
            plot(C(1,1),C(1,2),['.' hG.markPenColor],'MarkerSize',12);
            hold off;
            if get(hG.markForeground,'Value')
                hG.fixedBG(C(1,2)-2:C(1,2)+2,C(1,1)-2:C(1,1)+2) = -1;
            else
                hG.fixedBG(C(1,2)-2:C(1,2)+2,C(1,1)-2:C(1,1)+2) = 1;
            end
            setappdata(hG.fig,'handles',hG);
        end
    end
end

function loadImgFile(src,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    [fn,fp]=uigetfile({'*.png','PNG'},'Select Image');
    if fn == 0
        return;
    end
    if src == hG.loadTgtImg
        hG.tgtImg = im2double(imread([fp fn]));
        hG.Lf = imGradFeature(hG.tgtImg);
    else
        hG.srcImg = im2double(imread([fp fn]));
        hG.Gf = imGradFeature(hG.srcImg);
        hG.srcPos = [1 1];
        imshow(hG.srcImg,'parent',hG.axComp);
        set(hG.fig,'CurrentAxes',hG.ax);
        [M,N,~] = size(hG.srcImg);
        hG.fixedBG = ones(M,N); % Used in image segment
    end
    setappdata(hG.fig,'handles',hG);
    composeImage;
end

function markROI(~,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    set(hG.fig,'CurrentAxes', hG.axComp);
    hG.fixedBG = ~roipoly(hG.srcImg);
    hG.L = hG.fixedBG;
    
    imBounds = hG.srcImg.*repmat(double(~hG.fixedBG)+1,[1 1 3])*.5;
    bounds = double(abs(edge(hG.fixedBG)));
    se = strel('square',2);
    bounds = 1 - imdilate(bounds,se);
    
    imBounds(:,:,2) = imBounds(:,:,2).*double(bounds);
    imBounds(:,:,3) = imBounds(:,:,3).*double(bounds);
    imshow(imBounds);
    set(hG.fig,'CurrentAxes', hG.ax);
    setappdata(hG.fig,'handles',hG);
    composeImage();
end

function showComposedImage(src,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    if get(src,'Value')
        hG.showComposedImage = true;
    else
        hG.showComposedImage = false;
    end
    setappdata(hG.fig,'handles',hG);
    composeImage;
end

function editSrc(src,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    if get(src,'Value')
        set(hG.fig,'CurrentAxes',hG.axComp);
        hG.isInEdit = true;
    else
        set(hG.fig,'CurrentAxes',hG.ax);
        hG.isInEdit = false;
    end
    if src == hG.markForeground % Mark foreground
        hG.markPenColor = 'g';
        set(hG.markBackground,'Value',0);
    else % Mark background
        hG.markPenColor = 'r';
        set(hG.markForeground,'Value',0);
    end
    setappdata(hG.fig,'handles',hG);
end

function processSrc(~,~)
    hG.fig = findobj('Tag','ImageComposing_window');
    hG = getappdata(hG.fig,'handles');
    hG.L = GCAlgo(255*hG.srcImg,hG.fixedBG,hG.k,hG.G,hG.maxIter, hG.Beta,hG.thresh);
    imshow(hG.srcImg.*repmat(1+double(~hG.L),[1 1 3])*0.5,'parent',hG.axComp);
    set(hG.fig,'CurrentAxes', hG.ax);
    setappdata(hG.fig,'handles',hG);
    composeImage;
end

function val = findMinGradientBound(gI,param)
    param = lower(param); 
    switch param
        case {'left','l'}
            % do nothing
        case {'right', 'r'}
            gI = fliplr(gI);
        case {'top','t'}
            gI = gI';
            %gI = fliplr(gI);
        case {'buttom','b'}
            gI = gI';
    end
    [M,N,~] = size(gI);
    % Now find a line on left
    tracePos = ones(M,N)*2;
    val = zeros(M,N);
    val(1,:) = gI(1,:);
    for i = 2 : M
        tmp(1,:) = [inf val(i-1,1:end-1)];
        tmp(2,:) = val(i-1,:);
        tmp(3,:) = [val(i-1,2:end) inf];
        [minV, ind] = min(tmp,[],1);
        tracePos(i,:) = ind;
        val(i,:) = minV + gI(i,:);
    end
    [~,pos] = min(val(end,:));
    val = zeros(M,N);
    val(end,pos:end) = 1;
    for i = M-1:-1:1
        pos = pos + tracePos(i+1,pos) - 2;
        val(i,pos:end) = 1;
    end
    switch param
        case {'left','l'}
            % do nothing
        case {'right', 'r'}
            val = fliplr(val);
        case {'top','t'}
            val = val';
            %val = fliplr(val);
        case {'buttom','b'}
            val = (~val)';
    end
end