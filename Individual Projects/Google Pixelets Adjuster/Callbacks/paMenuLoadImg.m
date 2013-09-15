function paMenuLoadImg(~, ~)
%% function paMenuLoadImg
%    This is the callback for Menu -> File -> Load Image. This function
%    loads an new image and set it to pixelets with current pixelets
%    settings
%    
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Get pixelet adjuster graph handle
hG.fig = findobj('Tag','PixeletAdjustment');
if isempty(hG.fig), error('pixelet adjuster window not found'); end

hG = getappdata(hG.fig,'handles');

%% Load new image
%  Get image name
[FileName,PathName] = uigetfile({'*.jpg;*.jpeg','JPEG Image';...
    '*.png','PNG Image';...
    '*.*','All Files'});

if FileName == 0, return; end

%  Load image
Img = im2double(imread(fullfile(PathName,FileName)));

%  Resize it if needed
Img = imresize(Img, hG.inputImgSz);

%% Set to pixelets
hG.pixelets = pixeletsFromImage(Img, hG.nRows, hG.nCols, ...
                                hG.overlapSize, hG.gapSize, hG.pixelets);
hG.inputImg = Img;

% Redraw
hG.dispI = refreshPixelets(hG);

%% Save updates
setappdata(hG.fig,'handles',hG);

end