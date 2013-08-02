function ellipseCoef = fitEllipses(dataPoints, varargin)
%% function fitEllipses
%    Fit dataPoints to an ellipses with least mean square error
%  Inputs:
%    dataPoints - N-by-2 matrix, indicating the X and Y position of data
%    params     - parameters to be applied, should be paired in name and
%                 value
%  Outputs:
%    ellipses   - 5-by-1 vector, indicating estimated coefficient for
%                 ellipses in form: ax^2+by^2+cxy+dx+ey+1 = 0
%  
%  Supported Parameters:
%    ShowPlot   - bool, indicating whether or not to plot fitted ellipses
%    Center     - 2-by-1 vector, indicating [x,y] position of center
%  
%  Parameters to be supported:
%    AxDirection - scaler, indicating direction of major (minor) axes
%    MajorAxLen  - scaler, indicating major axes length
%    MinorAxLen  - scaler, indicating minor axes length
%    FocalPos    - ???
%   
%  Example:
%
%  Note:
%    Currently, I only support LMS fitting with no constraints, features
%    will be added soon
%    By my testing, it still has some problem. Don't use it until this line
%    is removed
%  (HJ) July, 2013

%% Check inputs and init
if nargin < 1, error('DataPoints should be specified'); end
if size(dataPoints,2) ~= 2, error('DataPoints should be N-by-2'); end
if size(dataPoints,1)  < 6, error('Not enough data points'); end

if mod(length(varargin),2) ~= 0, error('Parameters should in pairs'); end
if isempty(varargin)
    warning('Use fitEllipses() for better performance with no constraints'); 
end

doCenterCheck = false; auxData = [];
showPlot = false;

%% Parse parameters
for i = 1 : 2 : length(varargin)
    switch lower(varargin{i})
        case 'center'
            % I didn't have a very good idea on how to do fixed center
            % fitting, sadly. If I got something in the future, I'll be
            % back and fix this
            center = varargin{i+1};
            auxData = repmat(2*center,[size(dataPoints,1) 1])-dataPoints;
            doCenterCheck = true;
        case 'showplot'
            showPlot = varargin{i+1};
        otherwise
            warning('unsupported parameters found. Ignored');
    end
end

%% Fit ellipses
%  build matrix
dtPoints = unique([dataPoints; auxData],'rows');
X = dtPoints(:,1); Y = dtPoints(:,2);
dtMatrix = [X.^2 Y.^2 X.*Y X Y];
% Find LMS best fit by pseudo-inverse
ellipseCoef = -inv(dtMatrix'*dtMatrix)*dtMatrix'*ones(size(dtMatrix,1),1);

%% Check
if doCenterCheck
    if any(ellipseGet(ellipseCoef,'Center')-center > 1e-3) % Some tolerance
        warning('Fitting for center failed...Sadly');
    end
end
%% Plot
if showPlot
    fH = @(x,y) [x.^2 y.^2 x.*y x y]*ellipseCoef+1;
    ezplot(fH); hold on;
    scatter(dtPoints(:,1),dtPoints(:,2),'.r');
end
end