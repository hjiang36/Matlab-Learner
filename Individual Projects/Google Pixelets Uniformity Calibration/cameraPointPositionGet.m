function [pos, varargout] = cameraPointPositionGet( ...
                    hG, inputPos, whiteImg, adpName, devID)
%% cameraPointPositionGet(hG,inputPos,[whiteImg],[adpName],[devID])
%    get camera captured image point position for one point on input image
%
%  Inputs:
%    hG        - pixelet adjuster graph handle, see d_pixeletAdjustment
%    inputPos  - position of dots on input image
%    whiteImg  - camera captured white image, if not given, this function
%                will capture one and get it returned
%    adpName   - camera adaptor name, if not given, this function will
%                detect and ask user to choose one
%    devID     - camera device ID, if not given, this function will
%                auto-detect the list and ask user to choose one
%
%  Output:
%    pos       - position in the output image
%    varargout - optional output parameters, which include adpName, devID,
%                whiteImg
%
%  Toolbox required:
%    Image Processing Toolbox, Image Aquisition Toolbox
%  
%  Example:
%    pos = cameraPointPositionGet(hG, [50 50]);
%  
%  See also:
%    cameraPosCalibration, d_pixeletAdjustment
%
%  (HJ) Sep, 2013

%% Check inputs
%  Check number of inputs
if nargin < 1, error('pixelet Adjuster graph handle required'); end
if nargin < 2, error('Input point position required'); end
if nargin < 3, whiteImg = []; end
if nargin < 4, adpName  = []; end
if nargin < 5, devID    = []; end

%% Get photo for white
%  Capture photo for white if not given
if isempty(whiteImg)
    setPixContent(hG, ones([hG.inputImgSz 3]),true);
    [whiteImg, adpName, devID] = imgCapturing(adpName, devID);
end

% Set to varargout
varargout{1} = whiteImg;

%% Create Image with specific dot
markerImg = createMarkerImage(inputPos, hG.inputImgSz);
setPixContent(hG, markerImg, true);

%% Capture image with specific dot
markerPhoto = imgCapturing(adpName, devID);

% Set to varargout
varargout{2} = adpName;
varargout{3} = devID;

%% Compute dot position
diffImg   = abs(markerPhoto - whiteImg);
diffImgBW = im2bw(diffImg, graythresh(diffImg));
CC        = bwconncomp(diffImgBW);
pos       = regionprops(CC, 'Centroid','Area');
% Filter connected regions
idx = ([pos.Area] >= max([pos.Area]));
assert(sum(idx) == 1);

% Convert centroids to 1-by-2 matrix
pos = pos(idx);
pos = cat(1, pos.Centroid);
end