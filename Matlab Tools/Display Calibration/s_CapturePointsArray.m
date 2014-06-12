%% s_CapturePointsArray
%  This is a tutorial script for Psych 221.
%  In this tutorial, we will show how to set up certain stimulus to screen
%  and how to get and analyze camera images.
%
%  Several external packages are needed. Please see the comments in each
%  section for more detailed information
%
%  (HJ) Feb, 2014

%% Show stimulus to screen
%  This part will show the stimulus to screen with Psychtoolbox
%  Psychtoolbox can be downloaded from
%    http://psychtoolbox.org/PsychtoolboxDownload
%
%  Here, we mainly use 'Screen' command to handle the window and stimulus.
%  To see help file any subcommand, type Screen('SubCommandName?')
%
%  The stimulus will ba a grid of points with values sampled from an image.
%  Or if you want to estimate PSF functions for different part of the
%  camera, you could use all white image to do this.

% Init screen parameters
scrNum = max(Screen('Screens'));
scrRes  = Screen('Resolution', scrNum); % use current display resolution
frameRate = 30; % Hz
gTable = repmat(((0:255)'/256).^(1/1.9719), [1 3]); % Should use real gTable

% Init stimulus
%Img = im2double(imread('~/Desktop/Killua.jpg')); % Load any image you like
Img = ones([100 100 3]);
Img = imresize(Img, [scrRes.height scrRes.width]); % Resize to full screen

% Skip flickering warning
Screen('Preference','SkipSyncTests',1);

% Set the resolution
try
    % Try to set spatial resolution, then spatial and temporal
    Screen('Resolution', scrNum, scrRes.width, scrRes.height);
    Screen('Resolution', scrNum, scrRes.width, scrRes.height, frameRate);
catch ME
    warning(ME.identifier, ME.message)
end

% Normalized gamma table
oldGammaTable = Screen('LoadNormalizedGammaTable', scrNum, gTable);

% Open screen
% We opoen a full screen window with black background and two buffers
[scrPtr, rect] = Screen('OpenWindow', scrNum, 0, [], [], 2);

% Hide cursor
HideCursor(scrNum);

% Get subsample of the image
I = zeros(size(Img));
I(1:20:end, 1:20:end, :) = Img(1:20:end, 1:20:end, :);

textureID = Screen('MakeTexture', scrPtr, I, [], [], 2); % double precision

% Draw stimulus to screen
% We draw it to full screen. If we need to have the original resolution, we
% can ignore the 'rect' parameter.
Screen('DrawTexture', scrPtr, textureID);

% Flip buffer to show stimulus
Screen('Flip', scrPtr);

%% Capture image with camera
%  Here we use gPhoto to control the camera to take a photo and read it
%  back. gPhoto software can be found at
%    http://www.gphoto.org/
%  gPhoto is not a matlab software. However, we could call and handle it
%  with system() command in matlab after proper installation.
%
%  If your camera is not supported by gPhoto, please try using library
%  provided by its manufacture or taking photo with remote and supply the
%  raw image to the rest of the program
%  Note that it's possible that your gphoto2 is installed to some other
%  directory. Thus, please make sure to change it to right directory before
%  running the program

% set gphoto2 path
gphoto   = '/opt/local/bin/gphoto2 ';
fName = 'cameraPhoto';
% kill threads that are using the camera
system('killall -SIGINT PTPCamera');

% set parameters of camera
try
catch ME
    warning(ME.identifier, ME.message);
end

% capture image and download
cmd = sprintf('--capture-image-and-download --filename "%s.nef"', fName);
[~, ~] = system([gphoto cmd]);


%% Read Raw Image and Demosaic
%  Raw image data (e.g. .NEF for Nikon cameras) are loaded with dcraw
%  software. Dcraw software can be found at
%    http://www.cybercom.net/~dcoffin/dcraw/
%  Executables for Linux and Windows can be directly downloaded. For mac,
%  the following command can be used to compile the dcraw.c into
%  executables:
%    llvm-gcc -o dcraw dcraw.c -lm -DNO_JPEG -DNO_LCMS -DNO_JASPER
%
%  From dcraw, we extract the demosaiced TIFF image. For simplicity, we use
%  by linear demosaicing algorithm there. Dcraw supports other demosaicing
%  algorithms, see option '-o'. Also, you could get unscaled documentary
%  CFA data by using '-D' instead of '-o' and then do camera / light
%  scaling and demosaicing yourself. If you want to get a .pgm or .ppm
%  formated file, don't use the '-T' option
%
%  If you just want to read the original data without any scaling, you
%  could use dcrawImageRead function
[~, ~] = system(sprintf('~/PDCSoft/dcraw/dcraw -o 0 -4 -T %s.nef', fName));

%% Analyze and get the points value
%  In this section, we will do two different things
%    1) Get and plot point spread function (PSF)
%    2) Find peaks for each PSF and generate a sharp image (by STORM idea)
%  This section is just an illustration, to have the real sharp image, the
%  tutorial needs to be ran serveral times for stimulus composed of
%  different part of the image
I = im2double(imread([fName '.tiff']));

% Find local maxima in grayscale image
grayI = rgb2gray(I);

dMask = ones(15); % dilation mask
dMask(8, 8) = 0;
dilatedI = imdilate(grayI, dMask);

BW = (grayI > dilatedI); % Or, you could use grayI - dilatedI > threshold
BW = repmat(BW, [1 1 3]);

% Build new image composed only of the local maximas
Ipeaks = I.*BW;

%% Clean up
%  After doing all stuff, please remember to close screen and disconnect
%  with your camera

% Delete captured and generated photos
delete([fName '.nef']);
%delete([fName '.tiff']);

% Restore gamma table
Screen('LoadNormalizedGammaTable', scrNum, oldGammaTable);

% Close PTB window
Screen('CloseAll');

% Show Cursor
ShowCursor([], scrNum);