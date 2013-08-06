function hG = calibrationByCamera(hG, It, Id)
%% function calibrationByCamera
%    script used to calibration brightness by camera
%
%  Inputs:
%    hG   - handle of graph, created in d_pixeleAdjustment.m
%    It   - test image matrix
%    Id   - demo image matrix
%
%  Outputs:
%    hG   - handle of graph, with adjusted mask values
%
%  Example:
%
%
%  (HJ) Aug, 2013

%% Check Inputs
%  Check input parameter
if nargin < 1, error('Handle of pixelet graph required'); end
if nargin < 2, error('Test Img Required'); end
if nargin < 3, error('Demo Img Required'); end

%% Calibrate camera postion
%  Show test image
hG = setPixContent(hG,It);
%  Get camera picture
cameraImg = imgCapturing;
%  Compute transfer matrix
[~,transS,camROI,itROI] = interactiveImgMapping(cameraImg,It);

%% Calibrate uniformity
%  show second image
hG = setPixContent(hG,Id);
%  Get camera picture
cameraImg = imgCapturing;
%  Compute tranformed image
mappedImg = interactiveImgMapping(cameraImg,Id,...
                'transS',transS,'srcROI',camROI,'dstROI',itROI);
            
% Convert to gray
% do we need to calibrate RGB independently anyway?
if size(mappedImg,3) == 3, mappedImg = rgb2gray(mappedImg); end
if size(Id,3) == 3, Id = rgb2gray(Id); end

% Extrapolate mappedImg to full size
% Just padding now


% Blur camera image
gFilter   = fspecial('gaussian',[10 10],5); % Gaussian filter
mappedImg = imfilter(mappedImg,gFilter,'same');

% Compute total msk change ratio
mskRatio  = Id ./ mappedImg;

% Cut msk to slices
mskRatioPix = cutImgToPix(mskRatio,hG);

% Apply to hG dispImg
for curPix = 1:length(hG.pixelets)
    hG.pixelets{curPix}.msk = hG.pixelets{curPix}.msk.*mskRatioPix{curPix};
    hG.pixelets{curPix}.dispImg  = hG.pixelets{curPix}.imgContent .* ...
        hG.pixelets{curPix}.msk;
end

end

%% Aux Function - setPixContent
%    set new image to pixelet adjustment window
%
%  Inputs:
%    hG  - handle of graph, created in d_pixeleAdjustment.m
%    Img - new image to be used, should be the same size as orginal one,
%          otherwise, we resize it
%  Outputs:
%    hG  - handle of graph, with new image set

function hG = setPixContent(hG, Img)
end

%% Aux Function - cutImgToPix
%  Compute image content for each pixelet
%
%  Inputs:
%
%  Outputs:
%

function content = cutImgToPix(Img, params)
end