function data = cdSincCircleIntegration(gridSize, r)
% Load / Create Pre-computed dictionary for circle integration on 2D sinc
% fucntion
%
% dict = cdSincCircleIntegration(gridSize)
%
% General Process:
%   1. Try to load the pre-computed grid map
%   2. If no pre-computed grid map found, create a dictionary and save it 
%      a) For each gridpoint, compute relative center position (x,y) and
%      radius (r)
%      b) Numerically compute the sinc integration on the circle
%      c) Save to dictionary with key (r)
%
% Input Parameters:
%   gridSize     - scalar, indicating the size of gridmap
%   showBar      - bool, indicating whether or not to show the progress bar
%
% Output Parameter:
%   dict         - dictionary containing information for circle integration
%                  for each (d,r)
% 
% Written by HJ
% May, 2013

%% Check inputs
if nargin < 1 || isempty(gridSize), gridSize = 128; end
if nargin < 2, error('Radius should be provided'); end
if mod(gridSize,2) ~= 0, gridSize = gridSize +1; end

%% Try Load dictionary
fileName = sprintf('./Pre-Compute/cirleIntegration_%d_Radius_%d.mat',gridSize,r);
if exist(fileName,'file')
    data = load(fileName);
    data = data.data;
    return;
end

%%
% Compute circle center relative distance
[X,Y] = meshgrid(0:gridSize,0:gridSize);
pos   = [X(:) Y(:)];

c = computeCircleSincGridIntegration(r,pos);
data = full(sparse(X(:)+1,Y(:)+1,c)); % Add 1 to avoid 0 in index

% Save pre-computed data
eval(['save ' fileName ' data;']);

%% END
end