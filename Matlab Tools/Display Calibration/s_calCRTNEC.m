%% Init
clear all; close all

%% Open Window
whichScreen=max(Screen('Screens'));
[winPtr,screenRect] = Screen('OpenWindow',whichScreen,255,[],32,2);
%  Load normalized gamma table, we do this just to make sure that T-lock
%  scheme works
Screen('LoadNormalizedGammaTable',winPtr,linspace(0,1,256)'*ones(1,3));
Clut = [0:255; 0:255; 0:255]' * 256;
BitsPlusSetClut(winPtr,Clut);

%% Create simple display structure
d.type  = 'display';
d.name  = 'CRT-NEC';
d.wave  = 380:4:1068;
d.spd   = zeros(173, 3);
d.bits  = 14;
d.gamma = zeros(65536, 3);
d.dpi   = 0; % unknown
d.dist  = 0.5;

%% Init PR715
port = pr715init;

%% Start spd measurement
%  Measure Red
fprintf('Measuring spd of red...');
Screen('FillRect',winPtr, [255 0 0]);
Screen('Flip', winPtr);
d.spd(:,1) = pr715spectrum(port);
fprintf('Done\n');
WaitSecs(0.5);
%  Measure Green
fprintf('Measuring spd of green...');
Screen('FillRect',winPtr, [0 255 0]);
Screen('Flip', winPtr);
d.spd(:,2) = pr715spectrum(port);
fprintf('Done\n');
WaitSecs(0.5);
%  Measure Blue
fprintf('Measuring spd of blue...');
Screen('FillRect',winPtr, [0 0 255]);
Screen('Flip', winPtr);
d.spd(:,3) = pr715spectrum(port);
fprintf('Done\n');
WaitSecs(0.5);
plot(d.wave, d.spd); drawnow;
save CRT-NEC.mat d

%% Start gamma measurement
intensity = randperm(225) + 30;
for level = 1 : 225
    fprintf('Measuring intensity %d...', intensity(level));
    % set color lookup table
    Clut = intensity(level) * ones(256,3) * 256;
    BitsPlusSetClut(winPtr,Clut);
    % measure xyz
    % XYZ = pr715xyz(port);
    spd = pr715spectrum(port);
    XYZ = ieXYZFromEnergy(spd',d.wave);
    d.gamma(intensity(level)*256) = XYZ(2);
    fprintf('%f...Done\n', XYZ(2));
    plot(d.wave, spd); drawnow;
end
save CRT-DELL_Left.mat d
%% 14 bit validation
intensity = 1:255;
for level = 1 : 5
    fprintf('Measuring intensity %d...', intensity(level));
    % set color lookup table
    Clut = ones(256,3) * 256 * 200 + intensity(level);
    BitsPlusSetClut(winPtr,Clut);
    % measure xyz
    % XYZ = pr715xyz(port);
    spd = pr715spectrum(port);
    XYZ = ieXYZFromEnergy(spd',d.wave);
    fprintf('%f...Done\n', XYZ(2));
    plot(d.wave, spd); drawnow;
end
%% Send mail
sendMailAsHJ({'hjiang36@gmail.com'},'lalala','lalala',{'CRT-DELL_Left.mat'});

%% Clean up & save results
fclose(port);
Screen('CloseAll');

