function angle = cbTestDirection(bitDepth, showPlot)
%% function angle = cbTestCbDirection([bitDepth = 8],[showPlot = false])
%
%  experiment script that can be used to test colorblind direction
%
%  Inputs:
%    bitDepth - bitDepth of the screen, can be either 8 or 10
%    showPlot - bool, whether or not to show plot for result
%
%  Output:
%    angle    - angle vector of each trial result
%
%  See also:
%    doCbDirTrial
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, bitDepth = 8; end
if nargin < 2, showPlot = false; end

% Check bitDepth
if bitDepth ~= 8 && bitDepth ~= 10
    error('Unknown color bit depth, can be either 8 or 10');
end

%% Init Experiment Parameters
%  Set fixed parameters
cbParams.nTrials  = 3;
cbParams.bgColor  = [0.5 0.5 0.5]; % Background color
cbParams.refColor = [0.5 0.5 0.5]; % Reference color

% Init random parameters
cbParams.initDir = round(rand(cbParams.nTrials,1)*360); % initial direction
cbParams.dist    = rand(cbParams.nTrials,1)*0.04 + 0.01; % distance in LM
cbParams.patchSz = [8 8]; % patch size in degrees

% Malloc for output
angle = zeros(cbParams.nTrials,1);

%% Init PsychToolbox Window
%  Load display
display  = cbInitDisplay;

display.backColorRgb = [.5 .5 .5]*255;
display   = openScreen(display,'hideCursor',false, 'bitDepth',bitDepth);
winPtr    = display.windowPtr;

%% Start Trial
for curTrial = 1 : cbParams.nTrials
     cbParams.curTrial = curTrial;
     % Do trial
     angle(curTrial) = doCbDirTrial(display, winPtr, cbParams);
end

%% Close PsychToolbox Window
closeScreen(display);

%% Plot
if showPlot
end

end
%%END