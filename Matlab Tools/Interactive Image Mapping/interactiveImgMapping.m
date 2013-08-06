function [mappedImg, transS] = interactiveImgMapping(srcImg,dstImg)
%% function interactiveImgMapping
%    Interactively mark corresponding points in two images and compute the
%    linear transformation matrix from srcImg to dstImg
%
%  Inputs:
%    srcImg - source image matrix
%    dstImg - destination image matrix
%
%  Outputs
%    mappedImg - transformed source image
%    transs    - transfrom structure, to be used in tformfwd and tforminv
%
%  Examples:
%    Im = interactiveImgMapping(srcImg,dstImg)
%
%  (HJ) Aug, 2013

%% Check Inputs & Init
if nargin < 1, error('Src Image Required'); end
if nargin < 2, error('Dst Image Required'); end

%% Mark ROI & Crop Image
%  Crop Src & Dst Img
srcImg = imcrop(srcImg);
dstImg = imcrop(dstImg);
close(gcf);

%  Mark Corresponding Points
hF = figure('Name','Mark Correspondence',...
       'NumberTitle','off',...
       'Menubar','none',...
       'KeyPressFcn',@keyPressed);
subplot(1,2,1); imshow(srcImg);
subplot(1,2,2); imshow(dstImg);

% Use global now, change to setappdata later
global mappedPoints;
mappedPoints = [];
dcm_obj = datacursormode;
set(dcm_obj,...
    'SnapToDataVertex','on',...
    'UpdateFcn', @dataCursorUpdate);

% Wait for figure exit
waitfor(hF);

% Compute transformation
dstPoints = mappedPoints(1:2:end,:);
srcPoints = mappedPoints(2:2:end,:);

% show image
t = cp2tform(srcPoints,dstPoints,'similarity');

% tranform srcImg to dstImg
u = [0 1]; 
v = [0 0]; 
[x, y] = tformfwd(t, u, v); 
dx = x(2) - x(1); 
dy = y(2) - y(1); 
angle = (180/pi) * atan2(dy, dx); 
scale = 1 / sqrt(dx^2 + dy^2);
disp(num2str(angle)); disp(num2str(scale));

end

function outputText = dataCursorUpdate(~,evt)
    outputText = '';
    global mappedPoints;
    mappedPoints = [mappedPoints; get(evt,'Position')];
end

function keyPressed(~,evt)
    disp(evt);
end