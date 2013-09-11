function markerImg = createMarkerImage(centroids, imageSize, varargin)
%% function createMarkerImage(centroids, varargin)
%    create an white image with marker dots on it
%
%  Inputs:
%    centroids  - centroids of marker dots, should be N-by-2 matrix
%    imageSize  - output image size, default 500 x 500
%    varargin   - name-value pairs, used to accept control parameters in
%                 the future
%
%  Outputs:
%    markerImg  - image with marker on it
%
%  Example:
%    makerImg = createMarkerImg([10 10; 20 50], [500 500]);
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('centroids poistion required'); end
if nargin < 2, imageSize = [500 500]; end

%% Create Marker
markerImg = ones([imageSize 3]);
for i = 1 : size(centroids, 1)
    markerImg = drawCircles(markerImg, centroids(i,:), 20);
end

end

%% Aux function
function img = drawCircles(img, center, radius, circleColor)
if nargin < 1, error('Canvas image is reuired'); end
if nargin < 2, error('Circle center is required'); end
if nargin < 3, error('Circle radius  is required'); end
if nargin < 4, circleColor = 0; end

[M, N, ~] = size(img);
[X, Y] = meshgrid(1:M, 1:N);
if ismatrix(img) && isscalar(circleColor)
    img((X-center(1)).^2 + (Y-center(2)).^2 <= radius^2) = circleColor;
elseif ndims(img) == 3
    if isscalar(circleColor), circleColor = repmat(circleColor,[3 1]); end
    indx = (X-center(1)).^2 + (Y-center(2)).^2 <= radius^2;
    for i = 1 : 3
        tmpImg = img(:,:,i);
        tmpImg(indx) = circleColor(i);
        img(:,:,i) = tmpImg;
    end
else
    error('Unsupported image / color combination');
end

end