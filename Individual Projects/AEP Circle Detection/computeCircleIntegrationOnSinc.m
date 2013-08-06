function c = computeCircleIntegrationOnSinc(r,dsqr)
% Axualary function
% Numerically compute the circle integration of a sinc/jinc function
% Inputs:
%   r    - scaler, indicating the radius of circle
%   dsqr - square distance between circle center and origin
% Output:
%   c    - Integration result, the size is the same as dsqr

%% Init Parameters & Check Inputs
if nargin < 1, error('Radius should be provided'); end
if nargin < 2, error('Squared distance should be provided'); end
if ~isscalar(r), error('radius should be scalar'); end

d    = dsqr.^0.5;
n    = 360;
theta= linspace(0,359,n)*pi/180;

%% Compute Integration
if isscalar(d) % case: d is scaler
    dist = sqrt(d^2 + r^2 - 2*d*r*cos(theta));
    c    = sum(sinc(dist))*pi/180;
else % case: d is matrix
    [M,N] = size(d);
    theta = repmat(reshape(theta,[1 1 n]),[M N 1]);
    dist  = sqrt(repmat(d.^2,[1 1 n]) + r^2 - 2*repmat(d,[1 1 n])*r.* cos(theta));
    c     = sum(sinc(dist),3)*pi/180;
end

%% End
end