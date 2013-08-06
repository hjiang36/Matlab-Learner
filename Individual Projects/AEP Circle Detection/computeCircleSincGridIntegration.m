function c = computeCircleSincGridIntegration(r, pos)
% Axualary function
% Numerically compute the circle integration of a sinc/jinc function
% Inputs:
%   r    - scaler, indicating the radius of circle
%   pos  - n-by-2 matrix, each row corresponds to one grid location
% Output:
%   c    - Integration result, the size is the same as dsqr

%% Init Parameters & Check Inputs
if nargin < 1, error('Radius should be provided'); end
if nargin < 2, error('Position should be provided'); end
if size(pos,2)~=2, error('Position should be n-by-2 matrix');end
if ~isscalar(r), error('radius should be scalar'); end

n    = 360;
theta= linspace(0,359,n)*pi/180;

%% Compute Integration
M      = size(pos,1);
theta  = repmat(reshape(theta,[1 1 n]),[M 1 1]);
relPos = repmat(pos,[1 1 n]) - [r*cos(theta) r*sin(theta)];
c      = sum(prod(sinc(relPos),2),3)/n;


%% End
end