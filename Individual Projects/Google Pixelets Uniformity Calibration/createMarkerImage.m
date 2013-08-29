function markerImg = createMarkerImage(centroids, varargin)
%% function createMarkerImage
%  
%    Should update some comments here
%
%  (HJ) Aug, 2013
markerImg = ones(500,500,3);
for i = 1 : length(centroids)
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