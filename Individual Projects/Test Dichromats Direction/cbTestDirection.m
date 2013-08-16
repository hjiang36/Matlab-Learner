function angle = cbTestDirection(bitDepth, showPlot)
%% s_testCbDirection
%
%  experiment script that can be used to test colorblind direction
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, bitDepth = 8; end
if nargin < 2, showPlot = false; end

%% Init Experiment Parameters
%  Set fixed parameters
cbParams.nTrials  = 1;
cbParams.bgColor  = [0.5 0.5 0.5]*255; % Background color
cbParams.refColor = [0.5 0.5 0.5]*255; % Reference color

% Init random parameters
cbParams.initDir = round(rand(cbParams.nTrials,1)*360); % initial direction
cbParams.dist    = rand(cbParams.nTrials,1)*0.04 + 0.01; % distance in LM

% Malloc for output
angle = zeros(cbParams.nTrials,1);

%% Init PsychToolbox Window
%  Load display
display  = cbInitDisplay;
display.wave = display.wavelength;

switch bitDepth
    case 8  %  8 bits
        display.backColorRgb = [127 127 127];
        display   = openScreen(display,false);
        winPtr    = display.windowPtr;
    case 10 %  Enable 10 bits
        % This should be updated to openScreen function anyway
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask','General','FloatingPoint32BitIfPossible');
        PsychImaging('AddTask','General','EnableNative10BitFrameBuffer');

        %  Open Window
        scNumber = max(Screen('Screens'));
        winPtr   = PsychImaging('OpenWindow',scNumber,0);
    otherwise
        error('Unrecoginzed bitDepth, only support 8 bit or 10 bit');
end

%% Start Trial
for curTrial = 1 : cbParams.nTrials
     cbParams.curTrial = curTrial;
     % Do trial
     angle(curTrial) = doCbDirTrial(display, winPtr, cbParams);
end

%% Close PsychToolbox Window
switch bitDepth
    case 10
        Screen('CloseAll');
    case 8
        closeScreen(display);
end

%% Plot
if showPlot
    
end
%% Save results


end
%%END