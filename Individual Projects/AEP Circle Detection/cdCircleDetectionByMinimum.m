function [center, radius] = cdCircleDetectionByMinimum(Image, estRange, opt)
% Detect cirlce in the image. By default, the circle in the image should be
% darker than other part
%
% [center, radius] = cdCircleDetectionByMinimum(Image, estRange, showPlot)
%
% General Process:
%   1. Load / Generate the pre-computed sinc integration dictionary
%   2. Estimate center and radius by Hough Transform
%   3. Compute the sum of all CGL values for nearby pixels
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
% See also:
%   cdCircleDetectionByGradient, cdCircleSincGridIntegration
%
% Written by HJ
% May, 2013

%% Check Inputs
if nargin<1, error('Input Image Required'); end
if nargin<2 || isempty(estRange), estRange = [10 30]; end
if nargin<3, opt.showPlot = false; opt.isQuiet = true; end
if ~isfield(opt,'showPlot'), opt.showPlot = false; end
if ~isfield(opt,'isQuiet'),  opt.isQuiet  = true; end

if ~isa(Image,'double')
    Image = im2double(Image);
end

if size(Image,3) > 1
    Image = rgb2gray(Image);
end

%% Estimate center and radius by Hough Transform
[nRow, nCol] = size(Image);
if nRow ~= nCol
    warning('Input image is not a square. Code was not tested for this');
end
if length(estRange) == 2
    [estC_p,estR_p] = imfindcircles(Image,estRange);
    estC = round(estC_p(1,:)); 
    estR = round(estR_p(1))+3; % Radius of min CGL is a little larger than hough transform
    houghEst = true;
    if ~opt.isQuiet
        disp(['estC:' num2str(estC_p) ' estR:' num2str(estR_p)]);
    end
elseif length(estRange) == 3
    estC = round(estRange(1:2));
    estR = round(estRange(3));
    estC_p = estC; estR_p = estR; % Just for plotting
    houghEst = false;
else
    error('estRange should be either length 2 or 3');
end

if ~opt.isQuiet
    tic; 
end

%% Compute CGL for Grid Points around Potential Points
sRange     = 5; % search Range, in pixels
[pX,pY,pR] = meshgrid(-sRange:sRange,-sRange:sRange,-sRange:sRange);

dataTable = zeros(nRow+1,nCol+1,2*sRange+1);
for R = estR-sRange:estR+sRange
    dataTable(:,:,R-estR+sRange+1) = cdSincCircleIntegration(max(nRow,nCol),R);
end
position   = [pX(:) pY(:) pR(:)];
val        = zeros(length(position),1);
tmp        = zeros(nRow, nCol);

for ii = 1:length(position)
    orig    = estC + position(ii,1:2);
    R       = estR + position(ii,3);
    dat     = dataTable(:,:,R-estR+sRange+1);
    
    tmp(orig(2):end,orig(1):end) = dat(1:nRow-orig(2)+1,1:nCol-orig(1)+1);
    tmp(1:orig(2),orig(1):end) = flipud(dat(1:orig(2), 1:nCol-orig(1)+1));
    tmp(orig(2):end,1:orig(1)) = fliplr(dat(1:nRow-orig(2)+1,1:orig(1)));
    tmp(1:orig(2),1:orig(1)) = rot90(dat(1:orig(2),1:orig(1)),2);
    
    val(ii) = tmp(:)'*Image(:);
end

% Find Minimun point and get the indx of 3*3*3 gridpoint around it
[~,ind] = min(val);
indx    = (pX >= pX(ind)-1) & (pX <= pX(ind) +1) & ...
          (pY >= pY(ind)-1) & (pY <= pY(ind) +1) & ...
          (pR >= pR(ind)-1) & (pR <= pR(ind) +1);

%% Interpolation and find minimum
% Construct data matrix for second order polynomial 
xdata = position(indx,:);
xdata(:,1) = xdata(:,1) - pX(ind);
xdata(:,2) = xdata(:,2) - pY(ind);
xdata(:,3) = xdata(:,3) - pR(ind);
ydata = val(indx);
dat = [xdata.^2 xdata.*circshift(xdata,[0 -1]) xdata];
dat = [dat ones(size(dat,1),1)];
% Fit coeficients by pseudo-inverse
coef = (dat'*dat)\dat'*ydata;

% Find Minimum point by solving linear equation of partial deriatives
minPoint = -inv([2*coef(1) coef(4) coef(6); 
             coef(4) 2*coef(2) coef(5);
             coef(6) coef(5) 2*coef(3)])*[coef(7);coef(8);coef(9)];
center  = estC + minPoint(1:2)'+[pX(ind) pY(ind)];
radius  = estR + minPoint(3)+pR(ind);

% Display Results
if ~opt.isQuiet
    disp(['Time' num2str(toc) ': Estimated Center: [' num2str(center) ...
        '], Radius: ' num2str(radius)]);
end

%% Plot
if opt.showPlot
    figure;
    imshow(Image);
    hold on;
    theta = linspace(0,2*pi,1000);
    plot(center(1)+radius*cos(theta),center(2)+radius*sin(theta),'r');
    plot(estC_p(1,1)+estR_p(1)*cos(theta),estC_p(1,2)+estR_p(1)*sin(theta),'--g');
    if houghEst
        legend('Min CGL','Hough Circle Detection');
    else
        legend('Min CGL','Input Circle Position');
    end
end

end