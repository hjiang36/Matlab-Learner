function [hG, transS, srcROI, dstROI, varargout] = cameraPosCalibration(...
                                      hG, adaptorName, deviceID, varargin)
%% function cameraPosCalibration([adaptorName], [deviceID])
%    Find transformation matrix between original input image and camera
%    captured image
%
%  General process:
%    1. Show image 1 with marker set A, capture photo 1 on screen with
%       an in focus and fixed position camera
%    2. Change marker set to B and generate image 2. Marker position should
%       be exactly the same and markers should have different color
%    3. Show image 2 and caputure corresponding photo 2 with camera
%    4. Compare photo 1 and photo 2 and find out marker position
%    5. Compute transformation matrix and figure out region of interest
%  
%  Inputs:
%    hG          - handle of graph
%    adaptorName - string, adaptor name of the camera to be used. If empty,
%                  program would detect supported cameras
%    devID       - scaler, device ID, if empty, use the first one available
%    varargin    - not used now, left for future input name-value parameter
%                  control pairs
%
%  Outputs:
%    hG        - handle of graph, with mask value adjusted
%    transS    - transfrom structure, to be used in tformfwd and tforminv
%    srcROI    - region of interest in source image
%    dstROI    - region of interest in destination image
%    varargout - contains adaptorName and deviceID in case they're needed
%
%  Example:
%    transS = cameraPosCalibration('macvideo', 1);
%
%  See also:
%    calibrationByCamera, imgCapturing, d_pixeletAdjustment
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('Hanle of d_pixeletAjustment (hG) required'); end
if nargin < 2, adaptorName = 'macvideo'; end
if nargin < 3, deviceID = 1; end
if mod(length(varargin),2) ~= 0
    error('Parameters should be in pairs');
end

% Init output
transS = []; srcROI = []; dstROI = [];
varargout = {[], []};

% Store original pixelet settings
pixelets = hG.pixelets;

%% Capture image with different marker set
%  Create two marker images
% This function has not been implemented yet
imgCentroids = [40 40; 40 460; 460 40; 460 460;
                160 160; 160 340; 340 160; 340 340];
markerImg1 = createMarkerImage(imgCentroids); 
markerImg2 = createMarkerImage([]);

%  Show first image and capture first photo
hG = setPixContent(hG, markerImg1, true); WaitSecs(0.1);
[photo1, adaptorName, deviceID] = imgCapturing( ...
    adaptorName, deviceID, 'Show Preview', false, 'Number of Frames', 10);

if isempty(photo1), return; end

%  Show second image and capture second photo
hG = setPixContent(hG, markerImg2, true); WaitSecs(0.1);
[photo2, adaptorName, deviceID] = imgCapturing( ...
    adaptorName, deviceID, 'Show Preview', false, 'Number of Frames', 10);

if isempty(photo2), return; end

%  Set adaptorName and deviceID to output
varargout{1} = adaptorName;
varargout{2} = deviceID;

%  Average photos for denoising
photo1 = mean(double(photo1), 4)/255;
photo2 = mean(double(photo2), 4)/255;

%% Find position of marker on photos
diffImg = abs(photo1 - photo2);
if size(diffImg, 3) == 3, diffImg = rgb2gray(diffImg); end
% Denoise image by a median filter
diffImg   = medfilt2(diffImg, [3 3]);
diffImgBW = im2bw(diffImg, graythresh(diffImg));
% Find connected components
CC = bwconncomp(diffImgBW);
photoCentroids = regionprops(CC, 'Centroid','Area',...
                             'MajorAxisLength','MinorAxisLength');
% Filter connected regions
idx = ([photoCentroids.Area] > 20 & ...
       [photoCentroids.MajorAxisLength] ./ ...
       [photoCentroids.MinorAxisLength] < 2);
photoCentroids = photoCentroids(idx);
% Convert centroids to N-by-2 matrix
photoCentroids = cat(1, photoCentroids.Centroid);

% Should replace here with ROI
assert(numel(photoCentroids) == numel(imgCentroids));

%% Compute transformation matrix and region of interest
%  Sort
% This is not a good idea in real demo, but just leave it here
photoCentroids(:,[3 4]) = round(photoCentroids / 50) * 50;
photoCentroids = sortrows(photoCentroids,[3 4]);
photoCentroids = photoCentroids(:, [1 2]);
imgCentroids   = sortrows(imgCentroids, [1 2]);

roiUlX = round(min(photoCentroids(:,1)));
roiUlY = round(min(photoCentroids(:,2)));
roiLrX = round(max(photoCentroids(:,1)));
roiLrY = round(max(photoCentroids(:,2)));

photoCentroids(:,1) = round(photoCentroids(:,1) - roiUlX);
photoCentroids(:,2) = round(photoCentroids(:,2) - roiUlY);

%  Compute transformation
transS = cp2tform(photoCentroids, imgCentroids, 'projective');

mappedImg = imtransform(photo2(roiUlY:roiLrY, roiUlX:roiLrX), transS);
mappedImg = mappedImg(30:end-30, 30:end-30);
mappedImg = padarray(mappedImg, [46 55], 'replicate', 'post');
mappedImg = padarray(mappedImg, [47 55], 'replicate', 'pre');
mappedImg = imresize(mappedImg, hG.inputImgSz);

% Compute total msk change ratio
mskRatio  = repmat(1 ./ mappedImg,[1 1 3]);
mskRatio  = mskRatio.^1.5;

% Blur camera image
%gFilter   = fspecial('gaussian',[10 10],5); % Gaussian filter
%mskRatio = imfilter(mskRatio,gFilter,'same');

mskRatio  = mskRatio ./ max(mskRatio(:));
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
hG.dispI = zeros(size(hG.dispI));
for curPix = 1 : length(hG.pixelets)
    hG.dispI = drawOnCanvas(hG.dispI, hG.pixelets{curPix});
end

imshow(hG.dispI);



%% Restore to original image
hG.pixelets = pixelets;

end

%% Aux Functions
function Img = drawOnCanvas(Img,pix)
    Img(pix.dispPos(1):pix.dispPos(1)+pix.dispSize(1)-1,...
        pix.dispPos(2):pix.dispPos(2)+pix.dispSize(2)-1,:) = pix.dispImg;
end