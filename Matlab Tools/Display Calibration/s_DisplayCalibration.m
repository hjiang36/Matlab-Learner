%% s_DisplayCalibration
%  This script can help auto-calibrate a display and generate an ISET
%  compatible display calibration file. More specifically, the script will
%  measure
%    1) 8bit (256 level) gamma table
%    2) Spectral distribution of primaries
%
%  Before running this script, please make sure that the spectrometer has
%  been connected correctly
%
%  Note: For some small DAC values, it's hard to measure the exact radiance
%        by spectrometer and we sometimes replace them by the theoretical
%        values from the fitted gamma curve
%
% (HJ) Feb, 2014

%% Init
close all; clear all; 

%% Get display info from user
%  Create display structure
d.type = 'display';
d.bits  = 8; % display color bit depth
d.gamma = zeros(256, 3); % display gamma table
d.dist  = 0.5;

%  Get display name
d.name = input('Display name:', 's');

%  List of Supported Spectrometers
deviceList{1} = 'PR650';
deviceList{2} = 'PR715';

%  Get which spectrometer is now using
fprintf('\n Please choose which spectrometer are you using: \n');
for ii = 1 : length(deviceList)
    fprintf('\t %d. %s\n', ii, deviceList{ii});
end
choice = input('Which spectrometer is connected?');
if ~isnumeric(choice), error('Your choice should be integer'); end
devName = deviceList{choice};

%  Get connection port
serialInfo = instrhwinfo('serial'); % Instrument Control Toolbox required
fprintf('\n Please choose which port is connected with %s\n', devName);
for ii = 1 : length(serialInfo.AvailableSerialPorts)
    fprintf('\t %d. %s \n', ii, serialInfo.AvailableSerialPorts{ii});
end
choice = input('Which spectrometer is connected?');
if ~isnumeric(choice), error('Your choice should be integer'); end
portName = serialInfo.AvailableSerialPorts{choice};

%  Get display DPI
d.dpi = input('Display DPI? (Type 0 for unknown)');
assert(isnumeric(d.dpi) && d.dpi >= 0, 'DPI must be positive number');

%% Open Window
scrNum = max(Screen('Screens'));
[winPtr,screenRect] = Screen('OpenWindow', scrNum, 255, [], [], 2);

%% Set up for measurement with different spectrometer
switch devName
    case 'PR650'
        d.wave = 380:4:780;
        measureSpd = @pr650spectrum;
    case 'PR715'
        d.wave = 380:4:1068;
        measureSpd = @pr715spectrum;
    otherwise
        error('Unkown device name');
end

%% Create simple display structure
d.spd   = zeros(length(d.wave), 3);


%% Init spectrometer
port = spectrometerInit(portName);

%% Spd measurement for display primaries 
primaryName = {'red', 'green', 'blue'}; % color channel name
d.spd = zeros(length(d.wave), length(primaryName));

for ii = 1 : length(primaryName) % current color channel
    fprintf('Measuring spd of %s...', primaryName{ii});
    color = zeros(1,length(primaryName)); color(ii) = 255;
    
    % Show primary on screen
    Screen('FillRect',winPtr, color);
    Screen('Flip', winPtr);
    
    % Measure SPD
    d.spd(:,ii) = measureSpd(port);
    
    fprintf('Done\n');
    WaitSecs(0.2);
end

plot(d.wave, d.spd);
save(d.name, 'd');

%% Gamma measurement
intensity = randperm(226) + 30;
for level = 1 : length(intensity)
    fprintf('[%d/226]Measuring intensity %d...', level, intensity(level));
    
    % Show stimulus to screen
    color = intensity(level) * ones(1,length(primaryName));
    Screen('FillRect',winPtr, color);
    Screen('Flip', winPtr);
    WaitSecs(0.5);
    
    % measure xyz
    spd = measureSpd(port);
    XYZ = ieXYZFromEnergy(spd',d.wave);
    d.gamma(intensity(level)) = XYZ(2);
    
    fprintf('%f...Done\n', XYZ(2));
    plot(d.wave, spd); drawnow;
end
% Normalize gamma table
d.gamma = d.gamma / max(d.gamma);
d.gamma = repmat(d.gamma, [1, length(primaryName)]);
save(d.name, 'd');

%% Fit gamma curve and set for small DAC value
gammaValue = mean(log(d.gamma(31:255,1))./log((30:254)'/255));
d.gamma(1:30, 1) = ((0:29)'/255).^gammaValue;
d.gamma = repmat(d.gamma(:,1), [1 length(primaryName)]);

save(d.name, 'd');

%% Send mail
emailSubject = sprintf('Display Calibration for %s', d.name);
sendMailAsHJ({'hjiang36@gmail.com'},emailSubject,[],{[d.name '.mat']});

%% Clean up & save results
fclose(port);
delete(port);
clear port;
Screen('CloseAll');

