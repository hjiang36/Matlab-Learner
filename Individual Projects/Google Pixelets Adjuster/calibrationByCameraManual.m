function hG = calibrationByCameraManual(hG, It, Id, varargin)
%% function calibrationByCameraManual(hG, It, Id, [varargin])
%    script used to calibration brightness by camera
%
%  Inputs:
%    hG       - handle of graph, created in d_pixeleAdjustment.m
%    It       - test image matrix
%    Id       - demo image matrix
%    varargin - calibration method selection
%
%  Outputs:
%    hG   - handle of graph, with adjusted mask values
%
%  Example:
%    hG = calibrationByCamera(hG, It, Id)
%
%  ToDo:
%    1. Figure out paddings
%    2. Update to two flash auto-detection transitions
%    3. Figure out how to eliminate black border
%
%  See also:
%    setPixContent, d_pixeletAdjustment, interactiveImgMapping
%
%  (HJ) Aug, 2013

%% Check Inputs
%  Check input parameter
if nargin < 1, error('Handle of pixelet graph required'); end
if nargin < 2, error('Test Img Required'); end
if nargin < 3, error('Demo Img Required'); end

% store original pixelet settings
pixelets = hG.pixelets;

%% Calibrate camera postion
%  Show test image
hG = setPixContent(hG, It, true);

%  Get camera picture
[cameraImg, adaptorName, deviceID] = imgCapturing;
if isempty(cameraImg), return; end
%  Compute transfer matrix
[~,transS,camROI,itROI] = interactiveImgMapping(cameraImg,It);

%% Calibrate uniformity
%  show second image
hG = setPixContent(hG, Id, true);

%  Get camera picture
cameraImg = imgCapturing(adaptorName, deviceID);
%  Compute tranformed image
mappedImg = interactiveImgMapping(cameraImg,Id,...
                'transS',transS,'srcROI',camROI,'dstROI',itROI);
            
% Convert to gray
% do we need to calibrate RGB independently anyway?
if size(mappedImg,3) == 3, mappedImg = rgb2gray(mappedImg); end
if size(Id,3) == 3, Id = rgb2gray(Id); end

% Extrapolate mappedImg to full size
% Just resize now
mappedImg = imresize(mappedImg,size(Id));

% Before blur the image, we need to carefully handle the black border sadly
% dataRegion = (mappedImg == 0);


% Blur camera image
gFilter   = fspecial('gaussian',[10 10],5); % Gaussian filter
mappedImg = imfilter(mappedImg,gFilter,'same');

% Set cap to mskRatio to avoid Inf
mappedImg(mappedImg < 0.2) = mean(mean(mappedImg(mappedImg>0.2)));

% Compute total msk change ratio
mskRatio  = repmat(Id ./ mappedImg,[1 1 3]);

mskRatio  = mskRatio / max(mskRatio(:));
mskRatio(isnan(mskRatio)) = 1;

% Cut msk to slices
mskRatioPix = cutImgToPix(mskRatio,hG);

% Apply to hG dispImg
for curPix = 1:length(hG.pixelets)
    hG.pixelets{curPix}.msk = hG.pixelets{curPix}.msk.*mskRatioPix{curPix};
    % Restore to original settings
    hG.pixelets{curPix}.imgContent = pixelets{curPix}.imgContent;
    hG.pixelets{curPix}.dispImg  = pixelets{curPix}.imgContent .* ...
        hG.pixelets{curPix}.msk;
end

%  Draw to screen
hG.dispI = refreshPixelets(hG);

end