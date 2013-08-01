%% Small Game - Mine Sweeping
%    A old but famous computer game, aiming at identifying mine areas from
%    safe areas
%
%  Control:
%    left click  - clear the area
%    Right click - mark the area as mine
%
%  To Do:
%    1. Un-mark an area if it is already marked
%    2. Check and open nearby area
%
%  Update History:
%    (HJ) Oct, 2012 - Build framework
%    (HJ) Jul, 2013 - clean up code

function mineSweeping()
%% Clean-up current workspace
clear; clc;

tmp = findobj('Tag','hjiang_window');
if ~isempty(tmp), close(tmp); end
%% Init Figure
hG.fig     = figure;
fig_pos    = get(hG.fig,'Position');
fig_width  = 800;
fig_height = 600;

% Set window name and position
set(hG.fig,...
    'Tag', 'hjiang_window',...
    'NumberTitle','Off',...
    'Resize','Off',...
    'Position',[fig_pos(1)-200,fig_pos(2)-300,fig_width,fig_height],...
    'Name','Small Game - Mining'...
    );

% Set window selection property to handle right click
set(hG.fig,'SelectionType','Alt');

% Hide menu bar
set(hG.fig, 'menubar', 'none');

% Draw main panel
hG.main = uipanel(... % Main panel
    'Parent',hG.fig,...
    'Position', [0.005 0.01 0.99 0.89],...
    'BackgroundColor',get(gcf,'Color')...
    );
% Draw control panel
hG.control = uipanel(... %Control panel
    'Parent',hG.fig,...
    'Position',[0.005 0.90 0.99 0.09],...
    'BackgroundColor',get(gcf,'Color')...
    );

% Draw Text field in control Panel
hG.minesRemained = uicontrol(...%Text field showing mines remained
    'Parent', hG.control,...
    'Style', 'Text',...
    'Units', 'Normalized',...
    'Position', [0.15 0.2 0.15 0.4],...
    'String', '99',...
    'FontSize',15,...
    'HorizontalAlignment', 'Center',...
    'BackgroundColor', get(gcf,'Color'),...
    'UserData',99 ...
    );

hG.timePast = uicontrol(...%Text field for showing time passed
    'Parent', hG.control,...
    'Style','Text',...
    'Units','Normalized',...
    'Position',[0.7 0.2 0.15 0.4],...
    'String','0',...
    'FontSize',15,...
    'HorizontalAlignment','Center',...
    'BackgroundColor',get(gcf,'Color')...
    );
% Draw Refresh Button
hG.refresh = uicontrol(...%Refresh button
    'Parent', hG.control,...
    'Style', 'PushButton',...
    'Units','Normalized',...
    'Position',[0.475 0.1 0.05 0.8],...
    'String', '',...
    'HorizontalAlignment','Center',...
    'BackgroundColor',get(gcf,'Color'),...
    'Callback',@refreshCallback ...
    );
% Set Image to Refresh button
set(hG.refresh,'Units','Pixels');
pos = floor(get(hG.refresh,'Position'));
img = imresize(im2double(imread('refresh.jpg')),[pos(4) pos(3)]);
img(img>1) = 1;
set(hG.refresh,'CData',img);
set(hG.refresh,'Units','Normalized');

% Draw buttons on main panel
nRows = 24;
nCols = 32;
buttonHeight = 0.9/nRows;
buttonWidth  = 0.9/nCols;
buttonSpacingX = 0.1/(nCols+1);
buttonSpacingY = 0.1/(nRows+1);

for currentRow = 1:nRows
    for currentCol = 1:nCols
        
        xPos = buttonSpacingX + ...
            (currentCol-1)*(buttonWidth+buttonSpacingX);
        yPos = buttonSpacingY + ...
            (currentRow-1)*(buttonHeight+buttonSpacingY);
        
        pIndex = sub2ind([nRows,nCols],currentRow,currentCol);
        
        hG.points(pIndex) = uicontrol(...
            'Parent', hG.main,...
            'Style','PushButton',...
            'Units','Normalized',...
            'Position',[xPos yPos buttonWidth buttonHeight],...
            'String', '',...
            'HorizontalAlignment','Center',...
            'Enable','inactive',...
            'ButtonDownFcn',@mineSweepingCallbacks...
            );
        
    end % for - nCols
end % for - nRows

% Load flag data
set(hG.points(1),'Units','pixels');
pos = floor(get(hG.points(1),'Position'));
global flagImage;
flagImage = imresize(im2double(imread('flag.png')),[pos(4) pos(3)]);
flagImage(flagImage>1) = 1;
flagImage(flagImage<0) = 0;
set(hG.points(1),'Units','Normalized');

%% Init Mine Position
initMineData(nRows,nCols);

%% Init Timer
initTimer();

setappdata(hG.fig,'handles',hG);

end


%% Init mine positions
function initMineData(nRows,nCols)
    if (nargin < 1)
        nRows = 24;
    end
    if (nargin < 2)
        nCols= 32;
    end
    pos = randperm(nRows*nCols,99);
    minePos = zeros(nRows,nCols);
    global mineData;
    mineData = zeros(nRows,nCols);
    minePos(pos) = 1;
    for currentRow = 1:nRows
        for currentCol = 1:nCols
            if (minePos(currentRow,currentCol) == 1)
                mineData(currentRow,currentCol) = -1;
            else
                xul = max(1,currentRow-1); xlr = min(nRows,currentRow+1);
                yul = max(1,currentCol-1); ylr = min(nCols,currentCol+1);
                mineData(currentRow,currentCol) = sum(sum(minePos(xul:xlr,yul:ylr)));
            end
        end
    end
    global pointStats;
    pointStats = zeros(nRows,nCols);
end
%% Callbacks For Mine Sweeping

% Callback for button clicked in main pannel
function mineSweepingCallbacks(src, ~)
    figHandle = ancestor(src, 'figure');
    clickType = get(figHandle, 'SelectionType');
    hG.fig = findobj('Tag','hjiang_window');
    hG = getappdata(hG.fig,'handles');
    
    %check timer
    global isTimerRunning;
    if (~isTimerRunning)
        isTimerRunning = true;
        hG.timer = timer('TimerFcn',@timerCallback,...
            'Period', 1.0,...
            'UserData',0, ...
            'StartDelay',0, ...
            'ExecutionMode','fixedRate',...
            'Tag', 'hjiang_timer'...
        );
        start(hG.timer);
    end
    
    %find point index
    [currentRow currentCol] = findPointIndex(src);
    global pointStats;
    
    if (pointStats(currentRow,currentCol) > 0)
        return;
    end
    
    global mineData;
    global flagImage;
    switch (clickType)
        case 'normal'
            % Handle left click
            numMines = mineData(currentRow,currentCol);
            if (numMines(1) == -1)
                gameEnd(-1);
            else
                openPoint(src,currentRow,currentCol);
            end
        case 'alt'
            % Handle right click
            set(src,'CData',flagImage);
            n = get(hG.minesRemained,'UserData');
            set(hG.minesRemained,'UserData',n-1);
            set(hG.minesRemained,'String',num2str(n-1));
            pointStats(currentRow,currentCol) = 2;
    end
end

% Callback for timer
function timerCallback(src,~)
    t = get(src,'UserData');
    set(src,'UserData',t+1);
    
    hG.fig = findobj('Tag','hjiang_window');
    hG = getappdata(hG.fig,'handles');
    
    set(hG.timePast,'String',num2str(t+1));
    
end

% Callback for fresh
function refreshCallback(~,~)
    initMineData();
    % Reset main Panel
    nRows = 24; nCols = 32;
    hG.fig = findobj('Tag','hjiang_window');
    hG = getappdata(hG.fig,'handles');
    for currentRow = 1:nRows
        for currentCol = 1:nCols
            pIndex = sub2ind([nRows,nCols],currentRow,currentCol);
            set(hG.points(pIndex),'Enable','Inactive',...
                'String','',...
                'BackgroundColor',[0.95 0.95 0.95],...
                'CData',[] ...
                );
        end
    end
    % Reset Control Panel
    set(hG.minesRemained,'UserData',99,...
        'String', '99' ...
        );
    set(hG.timePast,'String',0);
    % Reset Timer
    global isTimerRunning;
    if isTimerRunning
        t = timerfind('Tag','hjiang_timer');
        stop(t);
        ht = findobj('Tag','hjiang_timer');
        set(ht,'UserData',0);
        isTimerRunning = false;
    end
end

%% Ends the Game
function gameEnd(isWin)
    nRows = 24; nCols = 32;
    global pointStats;
    global isTimerRunning;
    hG.fig = findobj('Tag','hjiang_window');
    hG = getappdata(hG.fig,'handles');
    if (isWin < 0)
        %Game Lost
        msgbox('You clicked on a mine.','You Lose..');
        t = timerfind('Tag','hjiang_timer');
        stop(t);
        ht = findobj('Tag','hjiang_timer');
        set(ht,'UserData',0);
        for currentRow = 1:nRows
            for currentCol = 1:nCols
                pIndex = sub2ind([nRows,nCols],currentRow,currentCol);
                set(hG.points(pIndex),'Enable','off');
                if (pointStats(currentRow,currentCol) == 0)
                    pointStats(currentRow,currentCol) = 1;
                end
            end
        end
        isTimerRunning = false;
    else
        %Game Won
        msgbox('Mission Completed','You Win...');
    end
end

%% Open one Point
function openPoint(src,currentRow,currentCol)
    nRows = 24; nCols = 32;
    global pointStats;
    if (pointStats(currentRow,currentCol) > 0)
        return;
    end
    global mineData;
    numMines = mineData(currentRow,currentCol);
    
    % Mark point as opened
    pointStats(currentRow,currentCol) = 1;
    if (numMines == 0)
        hG.fig = findobj('Tag','hjiang_window');
        hG = getappdata(hG.fig,'handles');
        
        % Open Current Point
        set(src,'backgroundColor',[0.8 0.8 0.8]);
        
        % Open Iteratively
        for i = max(1,currentRow-1):min(nRows,currentRow+1)
            for j = max(1,currentCol-1):min(nCols,currentCol+1)
                if (pointStats(i,j) == 0)
                    pIndex = sub2ind([nRows,nCols],i,j);
                    openPoint(hG.points(pIndex),i,j);
                end
            end
        end
    else
        set(src,'backgroundColor',[0.8 0.8 0.8]);
        set(src,'String',num2str(numMines));
    end
end

%% Find Point Index
%find point index
function [currentRow currentCol] = findPointIndex(src)
    nRows = 24; nCols = 32;
    hG.fig = findobj('Tag','hjiang_window');
    hG = getappdata(hG.fig,'handles');
    for currentRow = 1:nRows
        for currentCol = 1:nCols
            pIndex = sub2ind([nRows,nCols],currentRow,currentCol);
            if (hG.points(pIndex) == src)
                return;
            end
        end
    end
end

%% Init Timer
function initTimer()
    % Clear Timer
    t = findobj('Tag','hjiang_timer');
    if (~isempty(t))
        stop(t);
        set(t,'UserData',0);
    end
    % Clear Flag
    global isTimerRunning;
    isTimerRunning = false;
end