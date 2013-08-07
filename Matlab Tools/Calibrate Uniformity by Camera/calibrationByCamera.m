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
%    hG = calibrationByCamera(hG, It, Id)
%
%  ToDo:
%    1. figure out paddings
%    2. set image back to original -done
%    3. restore hG to show original image after completion - done
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
[M,N] = size(Id);
mappedImg = padarray(mappedImg,camROI(1:2)-1,'replicate','pre');
mappedImg = padarray(mappedImg,[M-camROI(1)-camROI(3) ...
               N-camROI(2)-camROI(4)],'replicate','post');

assert(all(size(mappedImg) == size(Id)));

% Blur camera image
gFilter   = fspecial('gaussian',[10 10],5); % Gaussian filter
mappedImg = imfilter(mappedImg,gFilter,'same');

% Compute total msk change ratio
mskRatio  = repmat(Id ./ mappedImg,[1 1 3]);

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

end