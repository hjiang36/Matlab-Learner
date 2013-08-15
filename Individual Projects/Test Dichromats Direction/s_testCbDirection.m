%% s_testCbDirection
%
%  experiment script that can be used to test colorblind direction
%
%  (HJ) Aug, 2013

%% Init Experiment Parameters
%  Set fixed parameters
cbParams.nTrials = 30;
cbParams.bgColor = [0.5 0.5 0.5]; % Background color

% Init random parameters
cbParams.initDir = round(rand(cbParams.nTrials,1)*360); % initial direction
cbParams.dist    = rand(cbParams.nTrials,1)*0.35 + 0.05; % distance in LM

% Malloc for output
angle = zeros(cbParams.nTrials,1);

%% Init PsychToolbox Window
%  Set up 10 bits

%  Open Window
scNumber = 

%% Start Trial
for curTrial = 1 : nTrials
    cbParams.curTrial = curTrial;
    % Do trial
    angle(curTrial) = doCbDirTrial(winPtr, cbParams);
end

%% Close PsychToolbox Window

%% Plot



%%END