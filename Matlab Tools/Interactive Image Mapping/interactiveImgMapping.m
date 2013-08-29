function [mappedImg,transS,srcROI,dstROI]=interactiveImgMapping(...
                                                  srcImg, dstImg, varargin)
%% function interactiveImgMapping
%    Interactively mark corresponding points in two images and compute the
%    linear transformation matrix from srcImg to dstImg
%
%  Inputs:
%    srcImg   - source image matrix
%    dstImg   - destination image matrix
%    varargin - name-values pairs for roi and other parameters
%
%  Outputs
%    mappedImg - transformed source image
%    transs    - transfrom structure, to be used in tformfwd and tforminv
%    srcROI    - region of interest in source image
%    dstROI    - region of interest in destination image
%
%  Variable Input:
%    'showDebug' - bool, whether or not to show debug info (scale / angle)
%    'showPlot'  - bool, whether or not to show mappedImg
%    'srcROI'    - 4-value rect, region of interest in sourc image
%    'dstROI'    - 4-value rect, region of interest in destination image
%  
%  Examples:
%    Im = interactiveImgMapping(srcImg,dstImg,'showDebug',true)
%  
%  ToDo:
%    1. Check one left one right
%
%  (HJ) Aug, 2013

%% Check Inputs & Init
if nargin < 1, error('Source Image Required'); end
if nargin < 2, error('Destination Image Required'); end
if mod(length(varargin),2)~=0, error('Parameters should be in pairs'); end

%% Parse input parameters
%  Init parameters
showDebug = false; showPlot = false;
srcROI = []; dstROI = []; transS = [];

% Parse varargin and set corresponding field
for i = 1 : 2 : length(varargin)
    switch lower(varargin{i})
        case 'showdebug'
            showDebug = varargin{i+1};
        case 'showplot'
            showPlot = varargin{i+1};
        case 'srcroi'
            srcROI = varargin{i+1};
        case 'dstroi'
            dstROI = varargin{i+1};
        case 'transs'
            transS = varargin{i+1};
        otherwise
            warning('Unrecognized parameters encountered, ignored');
    end
end

%% Mark ROI & Crop Image
%  Crop Src & Dst Img
if isempty(srcROI)
    figure;
    [srcImg,srcROI] = imcrop(srcImg);
    close(gcf);
else
    srcImg = imcrop(srcImg,srcROI);
end

if isempty(dstROI)
    figure;
    [dstImg,dstROI] = imcrop(dstImg);
    close(gcf);
else
    dstImg = imcrop(dstImg,dstROI);
end


%%  Mark Corresponding Points
if isempty(transS)
    hF = figure('Name','Mark Correspondence',...
        'NumberTitle','off',...
        'Menubar','none');
    subplot(1,2,1); imshow(srcImg); hold on;
    subplot(1,2,2); imshow(dstImg); hold on;
    
    % mappedPoints work as our session data
    mappedPoints = [];
    setappdata(0,'mpPoints',mappedPoints);
    dcm_obj = datacursormode;
    set(dcm_obj,...
        'SnapToDataVertex','on',...
        'DisplayStyle','window',...
        'UpdateFcn', @dataCursorUpdate);
    
    % Wait for figure exit
    waitfor(hF);
    mappedPoints = getappdata(0,'mpPoints');
    
    % Compute transformation
    dstPoints = mappedPoints(1:2:end,:);
    srcPoints = mappedPoints(2:2:end,:);
    
    transS = cp2tform(dstPoints,srcPoints,'similarity');
end

% tranform srcImg to dstImg
mappedImg = imtransform(srcImg,transS);

%% Compute scale and rotation angle for testing
if showDebug
    u = [0 1];
    v = [0 0];
    [x, y] = tformfwd(transS, u, v);
    dx = x(2) - x(1);
    dy = y(2) - y(1);
    angle = (180/pi) * atan2(dy, dx);
    scale = 1 / sqrt(dx^2 + dy^2);
    disp(['Rotation angle:' num2str(angle)]); 
    disp(['Scale:' num2str(scale)]);
end

if showPlot
    imshow(mappedImg);
end

end

function outputText = dataCursorUpdate(~,evt)
    outputText = ' ';
    mappedPoints = getappdata(0,'mpPoints');
    mappedPoints = [mappedPoints; get(evt,'Position')];
    setappdata(0,'mpPoints',mappedPoints);
end