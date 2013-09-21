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
%  Get pixelet adjuster handler
if nargin < 1
    hG = paGetHandler();
    if isempty(hG)
        error('Hanle of d_pixeletAjustment (hG) required');
    end
end
%  Get camera information
if nargin < 2
    if isfield(hG, 'adpName')
        adaptorName = hG.adpName;
    else
        adaptorName = 'macvideo'; 
    end
end

if nargin < 3
    if isfield(hG, 'devID')
        deviceID = hG.devID;
    else
        deviceID = 1;
    end
end

%  Check varargin
if mod(length(varargin),2) ~= 0
    error('Parameters should be in pairs');
end

% Init output and parameters
transS = []; dstROI = [];
varargout = {[], []};

if isfield(hG, 'gamma')
    gamma = hG.gamma;
else
    gamma = 2.2;
end

% Store original pixelet settings
pixelets = hG.pixelets;

%% Capture image with different marker set
%  Create two marker images
% This function has not been implemented yet
imgCentroids = [40 40; 40 400; 420 40; 420 400;
                160 80; 160 350; 340 80; 340 350];
markerImg1 = paCreateMarkerImage(imgCentroids, hG.inputImgSz); 
markerImg2 = paCreateMarkerImage([], hG.inputImgSz);

%  Show first image and capture first photo
%  hG = setPixContent(hG, markerImg1, true);
hG.pixelets = pixeletsFromImage(markerImg1, hG.nRows, hG.nCols, ...
                                hG.overlapSize, hG.gapSize, pixelets);
hG.dispI    = refreshPixelets(hG);

[photo1, adaptorName, deviceID] = imgCapturing( ...
    adaptorName, deviceID, 'Show Preview', false, 'Number of Frames', 10);
photo1 = photo1(:,:,:,5:end);

if isempty(photo1), return; end

%  Show second image and capture second photo
hG.pixelets = pixeletsFromImage(markerImg2, hG.nRows, hG.nCols, ...
                                hG.overlapSize, hG.gapSize, pixelets);
hG.dispI    = refreshPixelets(hG);

[photo2, adaptorName, deviceID] = imgCapturing( ...
    adaptorName, deviceID, 'Show Preview', false, 'Number of Frames', 10);
photo2 = photo2(:,:,:,5:end);

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
%diffImg   = medfilt2(diffImg, [3 3]);
diffImgBW = im2bw(diffImg, graythresh(diffImg));
% Find connected components
CC = bwconncomp(diffImgBW);
photoCentroids = regionprops(CC, 'Centroid','Area',...
                             'MajorAxisLength','MinorAxisLength');
% Filter connected regions
idx = ([photoCentroids.Area] > 50 & ...
       [photoCentroids.MajorAxisLength] ./ ...
       [photoCentroids.MinorAxisLength] < 1.5);
photoCentroids = photoCentroids(idx);
% Convert centroids to N-by-2 matrix
photoCentroids = cat(1, photoCentroids.Centroid);

% Should replace here with ROI
%If it can't find all teh fidicuals it sets an error
assert(numel(photoCentroids) == numel(imgCentroids));

%% Compute transformation matrix and region of interest
%  Sort
% This is not a good idea in real demo, but just leave it here
%left upper to left upper, if we use cameraPointPositionGet we dont need to
%worry about this
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

srcROI = [roiUlY roiUlX roiLrY roiLrX];

%  Compute transformation
transS = cp2tform(photoCentroids, imgCentroids, 'projective');

mappedImg = imtransform(photo2(roiUlY:roiLrY, roiUlX:roiLrX, :), transS);
mappedImg = mappedImg(30:end-30, 30:end-30);
mappedImg   = medfilt2(mappedImg, [5 5]);
mappedImg(mappedImg < 0.5) = nan;

mappedImg = imresize(mappedImg, hG.inputImgSz);
mappedImg = imrotate(mappedImg, 180);



% Compute total msk change ratio
mskRatio  = repmat(1 ./ mappedImg,[1 1 3]);
mskRatio  = mskRatio^(1/gamma);

% Blur camera image
%gFilter   = fspecial('gaussian',[10 10],5); % Gaussian filter
%mskRatio = imfilter(mskRatio,gFilter,'same');

mskRatio  = mskRatio ./ max(mskRatio(:));
mskRatio(isnan(mskRatio)) = 1;

%% Restore and apply to hG
for curPix = 1 : numel(hG.pixelets)
    pix = pixelets{curPix};
    UlPos = pixeletGet(pix, 'in ul pos');
    LrPos = pixeletGet(pix, 'in lr pos');
    mskRatioPix = mskRatio(UlPos(1):LrPos(1), UlPos(2):LrPos(2), :);
    %  Restore image content and save adjusted mask
    curMsk = pixeletGet(pix, 'msk');
    hG.pixelets{curPix} = pixeletSet(pix, 'msk', curMsk .* mskRatioPix);
end


end