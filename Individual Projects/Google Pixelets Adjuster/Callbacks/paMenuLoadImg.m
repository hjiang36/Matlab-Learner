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
[FileName,PathName] = uigetfile({'*.jpg;*.jpeg','JPEG Image';...
    '*.png','PNG Image';...
    '*.*','All Files'});

if FileName == 0, return; end
Img = im2double(imread(fullfile(PathName,FileName)));

%% Set to pixelets
hG  = setPixContent(hG, Img);
hG.inputImg = imresize(Img, hG.inputImgSz);
% Redraw
refreshPixelets(hG);

%% Save updates
setappdata(hG.fig,'handles',hG);

end