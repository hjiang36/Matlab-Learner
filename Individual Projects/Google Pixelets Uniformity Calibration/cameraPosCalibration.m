function [transS, srcROI, dstROI, varargout] = cameraPosCalibration(...
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
if nargin < 2, adaptorName = []; end
if nargin < 3, deviceID = []; end
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
hG = setPixContent(hG, markerImg1, true);
[photo1, adaptorName, deviceID] = imgCapturing(adaptorName, deviceID);

if isempty(photo1), return; end

%  Show second image and capture second photo
hG = setPixContent(hG, markerImg2, true);
[photo2, adaptorName, deviceID] = imgCapturing(adaptorName, deviceID);

if isempty(photo2), return; end

%  Set adaptorName and deviceID to output
varargout{1} = adaptorName;
varargout{2} = deviceID;


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
       [photoCentroids.MinorAxisLength] < 1.15);
photoCentroids = photoCentroids(idx);
% Convert centroids to N-by-2 matrix
photoCentroids = cat(1, photoCentroids.Centroid);

% Should replace here with ROI
assert(numel(photoCentroids) == numel(imgCentroids));

%% Compute transformation matrix and region of interest
%  Sort
photoCentroids = sortrows(photoCentroids,[1 2]); % This is not a good idea in real demo, but just leave it here
imgCentroids   = sortrows(imgCentroids, [1 2]);

%  Compute transformation
transS = cp2tform(photoCentroids, imgCentroids, 'similarity');

%% Restore to original image
hG.pixelets = pixelets;

end