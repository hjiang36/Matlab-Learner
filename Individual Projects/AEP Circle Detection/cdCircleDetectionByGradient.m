function [center, radius] = cdCircleDetectionByGradient(Image, estRange, opt)
% Detect cirlce in the image. Circles are detected by maximize the average
% gradience along the circle
%
% [center, radius] = cdCircleDetectionByGradient(Image, estRange, tol, showPlot)
%
% General Process:
%   1. Load / Generate the pre-computed sinc integration dictionary
%   2. Estimate center and radius by Hough Transform
%   3. Compute the sum of all pixel cicle integrations for nearby pixels
%   4. Interpolation and find the minimum point
%
% Input Parameters:
%   Imgae     - matrix, grayscale image file
%   estRange  - estimated radius range / estimated center and radius
%   opt       - structure, containing flags for circle detection
%       opt.showPlot - bool, indicating whether or not to show the plot
%       opt.isQuiet  - bool, indicating whether or not to output info
%
% Output Parameter:
%   center    - 2d turple (x,y), indicating center position in pixels
%   radius    - scaler, indicating the radius of circle in pixels
% 
% Written by HJ
% May, 2013

%% Check Inputs
if nargin<1, error('Input Image Required'); end
if nargin<2 || isempty(estRange), estRange = [20 50]; end
if nargin<3, opt.showPlot = false; opt.isQuiet = true; end
if ~isfield(opt,'showPlot'), opt.showPlot = false; end
if ~isfield(opt,'isQuiet'),  opt.isQuiet  = true; end

if ~isa(Image,'double')
    Image = im2double(Image);
end

if size(Image,3) > 1
    Image = rgb2gray(Image);
end
I_o = Image;

%% Estimate center and radius by Hough Transform
if length(estRange) == 2
    [estC_p,estR_p] = imfindcircles(Image,estRange);
    estC = round(estC_p(1,:)); 
    estR = round(estR_p(1));
    houghEst = true;
    if ~opt.isQuiet
        disp(['estC:' num2str(estC_p) ' estR:' num2str(estR_p)]);
    end
elseif length(estRange) == 3
    estC = estRange(1:2);
    estR = estRange(3);
    estC_p = estC; estR_p = estR;
    houghEst = false;
else
    error('estRange should be either length 2 or 3');
end
%% Interpolate Image to Double Size
%[M,N]  = size(Image);
%I_spec = zeros(2*M,2*N);
%I_spec(1:M,1:N) = dct2(Image)*2;
%Image  = idct2(I_spec);

%% Find circle for maximum gradient
gI = computeGradientImg(Image,estC);
[center, radius] = cdCircleDetectionByMinimum(-gI, round([estC estR]));
% Adjust Center by Half a pixel
center = center -0.5;
%% Plot
if opt.showPlot
    imshow(I_o);
    hold on;
    theta = linspace(0,2*pi,1000);
    plot(center(1)+radius*cos(theta),center(2)+radius*sin(theta),'r');
    plot(estC_p(1,1)+estR_p(1)*cos(theta),estC_p(1,2)+estR_p(1)*sin(theta),'--g');
    if houghEst
        legend('Max Gradient','Hough Circle Detection');
    else
        legend('Max Gradient','Input Circle Position');
    end
end

end

function gI = computeGradientImg(Image,estC)
% Auxilary function
% Compute radial gradient map for 'Image'
% Inputs:
%   Image - M-by-N matrix, representing the grayscale image
%   estC  - estimated center, used to define direction of gradience
% Outputs:
%   gI    - gradience image

% Compute gradience for x,y axis
Gx = diff(Image,1,2); Gx = padarray(Gx,[0 1],'replicate','pre');
Gy = diff(Image,1,1); Gy = padarray(Gy,[1 0],'replicate','pre');

[M,N,~] = size(Image);
[X,Y] = meshgrid(1:M,1:N);
gI = sqrt(Gx.^2 + Gy.^2).*sign(Gx.*(estC(1)-X)+Gy.*(estC(2)-Y));

end