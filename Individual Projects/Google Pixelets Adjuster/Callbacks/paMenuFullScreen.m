function paMenuFullScreen(~, ~)
%% function paMenuFullScreen
%    This is the callback function for pixelet adjuster
%    Menu->File->FullScreen(PTB)
%    This function get the current display image and window position and
%    render it with OpenGL in PsychToolbox in full screen mode
%
%  Control:
%    ESC   - exit full screen and get back to pixelet adjuster window
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Sep, 2013

%% Get handler
hG = paGetHandler();
if isempty(hG), error('pixelet adjuster window not found'); end

AssertOpenGL;

%% Get position and display image
%  Get window position in window coodinates
%  Note here, the lower left corner is (0, 0)
set(hG.fig, 'Units', 'Pixel');
winRect = get(hG.fig, 'Position');
set(hG.fig, 'Units', 'Normalized');

%  Get pannel position
set(hG.main, 'Units', 'Pixel');
panelPos = get(hG.main, 'Position');
set(hG.main, 'Units', 'Normalized');

%  Get axes position
set(gca, 'Units', 'Pixel');
axesPos = get(gca, 'Position');
set(gca, 'Units', 'Normalized');

%  Compute axes region
winRect(1:2) = winRect(1:2) + axesPos(1:2) + panelPos(1:2) - 1;
dispImgSz = size(hG.dispI);
winRect(3:4) = [dispImgSz(2) dispImgSz(1)];

%  Get Screen Resolution
winNumber  = max(Screen('Screens'));
resolution = Screen('Resolution', winNumber);

%  Convert to PsychToolbox coordinates, where upper left corner is (0,0)
winRect(2) = resolution.height - winRect(2) - winRect(4);
winRect(3) = winRect(1) + winRect(3);
winRect(4) = winRect(2) + winRect(4);
dispImage   = hG.dispI;
if max(dispImage(:)) > 5, dispImage = double(dispImage) / 255; end

%% Open window and draw texture
winPtr    = Screen('OpenWindow', winNumber, 0, winRect);

texImg = Screen('MakeTexture', winPtr, dispImage, [], [], 2);
Screen('DrawTexture', winPtr, texImg);

Screen('Flip', winPtr);

%% Wait until exit
WaitSecs(5);

%% Close screen
Screen('CloseAll');


end