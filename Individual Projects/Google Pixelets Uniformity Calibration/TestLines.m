%% Init
clc; clear; close all;
AssertOpenGL;

%% Open Screen
%  Init Parameters
frameRate      = 60; % Refresh Rate
hideCursorFlag = false; % Not to Hide Cursor
screenNumber   = max(Screen('Screens')); % Using Ext-Screen if connected
bitPerPixel    = 8; % Color Depth
gammaTable     = repmat(linspace(0,1,1024)',[1 3]);
resolution     = [2880 1800];
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
Screen('TextSize',windowPtr,28);

%% Create and Draw Stimulus
keyName = '1!';
while true
    switch keyName
        case '1!'% Overlap with no blur
            I = zeros(1800,2880);
            I(600:601,:) = 255; % Reference Line
            I(900:901,1:1500) = 255;
            illu = linspace(255,186,100);
            for i = 1:100
                I(900,1500+i) = illu(i);
                I(902,1500+i) = illu(101-i);
            end
            I(901,1500:1600) = 255;
            I(901:902,1601:end) = 255;
            txt = 'Overlap with no blur';
        case '2@'% Overlap with blur
            I = zeros(1800,2880);
            I(600:601,:) = 255; % Reference Line
            I(900:901,1:1400) = 255;
            
            for i = 1 : 100
                I(898:903,1400+i) = round(255*(i/400).^(1/2.2));
                I(900:901,1400+i) = round(255*(1-i/200).^(1/2.2));
            end
            
            I(898,1500:1600) = linspace(126,0,101);
            I(899,1500:1600) = 126; % 1/4
            I(900,1500:1600) = 163; % 3/8
            I(901,1500:1600) = 186; % 1/2
            I(902,1500:1600) = 163; % 3/8
            I(903,1500:1600) = 126; % 1/4
            I(904,1500:1600) = linspace(0,126,101);
            
            for i = 0:99
                I(899:904,1700-i) = round(255*(i/400).^(1/2.2));
                I(901:902,1700-i) = round(255*(1-i/200).^(1/2.2));
            end
            I(901:902,1701:end) = 255;
            
            txt = 'Overlap with blur';
        case '3#' % White Line on black
            I = zeros(1800,2880);
            I(900:901,:) = 255;
            I_left  = I;
            I_right = circshift(I,[1 0]);
            weights = [zeros(1,1300) linspace(0,1,280) ones(1,1300)];
            weights = repmat(weights,[1800 1]);
            I = I_right .* weights + I_left .*(1-weights);
            I = uint8(255*imresize(I/255,0.5));
            [X,Y]= meshgrid(linspace(1,1440,2880),linspace(1,900,1800));
            I = interp2(double(I),X,Y,'nearest');
            I(600:601,:) = 255; % Reference Line
            I = uint8(255*(I/255).^(1/2.2));
            
            txt = 'interpolation - white line';
            
        case '4$' % Black Line on white
            I = 255*ones(1800,2880);
            I(901:902,:) = 0;
            I_left  = I;
            I_right = circshift(I,[1 0]);
            weights = [zeros(1,1300) linspace(0,1,280) ones(1,1300)];
            weights = repmat(weights,[1800 1]);
            I = I_right .* weights + I_left .*(1-weights);
            I = uint8(255*imresize(I/255,0.5));
            [X,Y]= meshgrid(linspace(1,1440,2880),linspace(1,900,1800));
            I = interp2(double(I),X,Y,'nearest');
            I(600:601,:) = 0; % Reference Line
            I = uint8(255*(I/255).^(1/2.2));
            
            txt = 'interpolation - black line';
        case '5%' % Real Picture
            I = imread('google.png'); I = double(rgb2gray(I));
            I_left  = I;
            I_right = circshift(I,[1 0]);
            weights = [zeros(1,1300) linspace(0,1,280) ones(1,1300)];
            weights = repmat(weights,[1800 1]);
            I = I_right .* weights + I_left .*(1-weights);
            I = uint8(255*imresize(I/255,0.5));
            [X,Y]= meshgrid(linspace(1,1440,2880),linspace(1,900,1800));
            I = interp2(double(I),X,Y,'nearest');
            I = uint8(255*(I/255).^(1/2.2));
            
            txt = 'Real Image';
        case '6^'
            I = zeros(900,1440,3);
            I(1:3:end,:,1) = 255;
            I(2:3:end,:,2) = 255;
            I(3:3:end,:,3) = 255;
            
        case 'q'
            break;
        otherwise
            [~,keyCode] = KbWait(-1);
            keyName = KbName(keyCode);
            continue;
    end
    stimulus = Screen('MakeTexture', windowPtr, uint8(I));
    Screen('DrawTexture', windowPtr, stimulus, [], rect);
    Screen('DrawText',windowPtr,txt,100,100,[255 0 0]);
    Screen('Flip',windowPtr);KbWait(-1);
    [~,keyCode] = KbWait(-1);
    keyName = KbName(keyCode);
end

%% Restore Display Settings
Screen('LoadNormalizedGammaTable', screenNumber, oldGamma);
Screen('CloseAll');