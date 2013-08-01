function ellipse = fitEllipses(dataPoints, params)
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
%    MajorAxDir  - scaler, indicating direction of major axes
%    MajorAxLen  - scaler, indicating major axes length
%    MinorAxLen  - scaler, indicating minor axes length
%    FocalPos    - ???
%   
%  Example:
%
%  Note:
%    Currently, I only support LMS fitting with no constraints, features
%    will be added soon
%  (HJ) July, 2013

%% Check inputs and init
if nargin < 1, error('DataPoints should be specified'); end
if size(dataPoints,2) ~= 2, error('DataPoints should be N-by-2'); end
if size(dataPoints,1)  < 6, error('Not enough data points'); end

if nargin < 2, params = []; end

%% Parse parameters
for i = 1 : 2 : length(params)
    switch params
    end
end

%% Fit ellipses
%  build matrix
X = dataPoints(:,1); Y = dataPoints(:,2);
dtMatrix = [X.^2 Y.^2 X.*Y X Y];
% Find LMS best fit by pseudo-inverse
ellipse = -inv(dtMatrix'*dtMatrix)*dtMatrix'*ones(5,1);

%% Plot
end