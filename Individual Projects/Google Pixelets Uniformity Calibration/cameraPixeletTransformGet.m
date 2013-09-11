function [transS, err] = cameraPixeletTransformGet(hG, pixIndx)
%% function pixeletCameraTransformaGet(hG, pixIndx)
%    find transformation matrix between input image and camera photo for
%    one pixelet
%
%  Inputs:
%    Img     - canvas image matrix
%    pixIndx - index of pixelet, refer to d_pixeletAdjustment for details
%              about pixelet structure
%
%  Outputs:
%    transS  - structure for transformation, refer to cp2tform for more
%              detailed information
%    err     - estimated error in the tranformation
%  
%  Example:
%    transS = cameraPixeletTransformGet(hG, 1);
%
%  See also:
%    cp2tform, cameraPointPositionGet
%
%  (HJ) Sep, 2013

%% Check inputs & init
if nargin < 1, error('pixelet adjuster handle required'); end
if nargin < 2, error('pixelet index required'); end

pix = hG.pixelets{pixIndx};

%% Get test point position on input image
pixCenter = pixeletGet(pix, 'Center');
theta = (0 : 90 : 359)' * pi / 180;
inputPointPos = pixCenter + round([0 0; cos(theta) sin(theta)] * 10);

%% Get correspoding position on photo
photoPointPos = zeros(size(inputPointPos));
whiteImg = []; 
adpName = 'macvideo'; devID = 1; % should change this, maybe add to hG
for curPoint = 1 : length(inputPointPos)
    [photoPointPos(curPoint, :), whiteImg] = cameraPointPositionGet(hG, ...
        inputPointPos(curPoint,:),whiteImg, adpName, devID);
end

%% Compute transformation
transS = cp2tform(photoPointPos, inputPointPos, 'projective');

%% Validation
err = 0;

end