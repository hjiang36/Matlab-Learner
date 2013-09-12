%% ClipImages
%    This script loads an input image and convert it to pixelet
%    representations according to some pre-set perameters
%
%  Required Toolbox:
%    PsychToolbox, Image Processing Toolbox
%
% (HJ) Jul, 2013


%% Init
clc; clear; close all;
AssertOpenGL;

%% Open Screen
%  Init Parameters
frameRate      = 60; % Refresh Rate
hideCursorFlag = false; % Not to Hide Cursor
screenNumber   = max(Screen('Screens')); % Using Ext-Screen if connected
bitPerPixel    = 8; % Color Depth
gammaTable     = repmat(linspace(0,1,256)',[1 3]);
resolution     = [1920 1200];
numBuffers     = 2;

% Skip the annoying blue flickering warning
Screen('Preference','SkipSyncTests',1);

% Save Gamma & Set it to new Gamma Table
oldGamma = Screen('ReadNormalizedGammaTable', screenNumber);
Screen('LoadNormalizedGammaTable', screenNumber, gammaTable);

% Set Resolution and Refresh Rate
% Set Resolution first, then try frame rate
try
    Screen('Resolution', screenNumber, resolution(1), resolution(2));
    Screen('Resolution',screenNumber,resolution(1),resolution(2),frameRate);
catch ME
    warning(ME.identifier, ME.message);
end     

% Open the screen and save the window pointer and rect
[windowPtr,rect] = Screen('OpenWindow',screenNumber,...
    [0.5 0.5 0.5], [], [], numBuffers);

%% Slice image / video to be displayed
%  Load Image
I = double(imread('google.jpg'));
%  Init Parameters
nBlkRows     = 2; % Number of LEDs in rows
nBlkCols     = 10; % Number of LEDs in cols
disLED2LCD   = 10; % Distance from LED to LCD, units mm
disLCD2Frost = 2 ; % Distance from LCD to frosters, units mm
disRatio     = disLCD2Frost/disLED2LCD;
[M,N,~]      = size(I);

gapRatio   = 1/16;
pixPerBlk  = round([M/nBlkRows N/nBlkCols]);
gapSize    = round(gapRatio*pixPerBlk);
overlapPix = round(disRatio*pixPerBlk - gapRatio*pixPerBlk*(1+disRatio));
assert(all(overlapPix >= 0));

% Padding Image
I = padarray(I,[overlapPix 0],0);

% Init Mask
if ~exist('mskFile.mat','file')
    msk = cell(nBlkRows,nBlkCols);
    for i = 1 : nBlkRows
        for j = 1 : nBlkCols
            msk{i,j} = ones(pixPerBlk-overlapPix)*3/8;
            msk{i,j} = padarray(padarray(msk{i,j},[overlapPix(1) 0],1/4),[0 overlapPix(2)])+...
                padarray(padarray(msk{i,j},[0 overlapPix(2)],1/4),[overlapPix(1) 0])+1/4;
            msk{i,j} = repmat(msk{i,j},[1 1 3]);
        end
    end
    save mskFile.mat msk
else
    c = load('mskFile.mat');
    msk = c.msk;
end

%  Build Sliced Image
[m,n,~] = size(msk);
mm      = m + gapSize(1);
nn      = n + gapSize(2);
slicedI = zeros(mm*nBlkRows-gapSize(1), nn*nBlkCols-gapSize(2),3);

% Init Pixelet Position Rectangles
pixeletRect = zeros(nBlkRows,nBlkCols,4);

pixeletRect(:,:,1) = repmat(mm*(0:nBlkRows-1)'+1,[1 nBlkCols]); 
pixeletRect(:,:,2) = repmat(nn*(0:nBlkCols-1)+1,[nBlkRows 1]); 

pixeletRect(:,:,3) = m;
pixeletRect(:,:,4) = n;

for i = 1 : nBlkRows
    for j = 1 : nBlkCols
        slicedI(pixeletRect(i,j,1):pixeletRect(i,j,1)+pixeletRect(i,j,3)-1,...
                pixeletRect(i,j,2):pixeletRect(i,j,2)+pixeletRect(i,j,4)-1,:) = ...
            I(pixPerBlk(1)*(i-1)+1:pixPerBlk(1)*(i-1)+m,...
              pixPerBlk(2)*(j-1)+1:pixPerBlk(2)*(j-1)+n ,:).*msk{i,j};
    end
end

% Get Grid of Black Cover
outI = slicedI(overlapPix(1)+1:end-overlapPix(1),...
                  overlapPix(2)+1:end-overlapPix(2),:);

%% Show Image to Screen
stimulus = Screen('MakeTexture', windowPtr, uint8(outI));
Screen('DrawTexture', windowPtr, stimulus, [], rect);
Screen('Flip',windowPtr);

%% User Adjustable
%  Init Parameters
%selectedPixelet = [1 1];
while true % Listen to mouse click event
    [nClicks,x,y,wButtom] = GetClicks(windowPtr,0.5);
    if wButtom == 1 % Left Click
        % Compute which one selected
        selectedPixelet = [ceil(x*nBlkCols/resolution(1)) ...
                           ceil(y*nBlkRows/resolution(2))];
    else % Right Click
        break;
    end
    i = selectedPixelet(2);
    j = selectedPixelet(1);
    % Double Click for editing Mask 
    if nClicks > 1
        imagesc(msk{i,j}(:,:,1)); axis off;
        selectedBW = roipoly;
        prompt = {'Enter new avg','Smooth out?(1-Yes, 0-No)'};
        dlg_title = 'Edit Mask';
        num_lines = 1;
        def = {'20','hsv'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
    end
    % Single Click for editing Position
    inEdit = true;
    while inEdit
        slicedI(pixeletRect(i,j,1):pixeletRect(i,j,1)+pixeletRect(i,j,3)-1,...
            pixeletRect(i,j,2):pixeletRect(i,j,2)+pixeletRect(i,j,4)-1,:) = ...
            zeros(m,n,3); % Clear to Black
        [~,keyCode] = KbWait(-1);
        keyName = KbName(keyCode);
        switch keyName
            case 'ESCAPE' % Finish Editing
                inEdit = false;
            case 'LeftArrow'
                pixeletRect(i,j,2) = max(pixeletRect(i,j,2)-1,1);
            case 'RightArrow'
                pixeletRect(i,j,2) = min(pixeletRect(i,j,2)+1,resolution(1));
            case 'UpArrow'
                pixeletRect(i,j,1) = max(pixeletRect(i,j,1)-1,1);
            case 'DownArrow'
                pixeletRect(i,j,1) = min(pixeletRect(i,j,1)+1,resolution(2));
        end
        slicedI(pixeletRect(i,j,1):pixeletRect(i,j,1)+pixeletRect(i,j,3)-1,...
                pixeletRect(i,j,2):pixeletRect(i,j,2)+pixeletRect(i,j,4)-1,:) = ...
            I(pixPerBlk(1)*(i-1)+1:pixPerBlk(1)*(i-1)+m,...
              pixPerBlk(2)*(j-1)+1:pixPerBlk(2)*(j-1)+n ,:).*msk{i,j}; % Draw new
        outI = slicedI(overlapPix(1)+1:end-overlapPix(1),...
                  overlapPix(2)+1:end-overlapPix(2),:);
        stimulus = Screen('MakeTexture', windowPtr, uint8(outI));
        Screen('DrawTexture', windowPtr, stimulus, [], rect);
        Screen('Flip',windowPtr);
    end
end

%% Restore Display Settings
Screen('LoadNormalizedGammaTable', screenNumber, oldGamma);
Screen('CloseAll');