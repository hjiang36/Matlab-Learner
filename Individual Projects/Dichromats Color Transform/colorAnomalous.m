function [rgb_d, T] = colorAnomalous(rgb, d, sensor, gain, varargin)
% Simulate color appearance for color blind and color anomalous using
% method proposed by Machado et. al (2009)
%   colorAnomalous(rgb, d, cone)
%
% Inputs:
%   rgb    - rgb image
%   d      - ISET display model, the gamma of the display will be adjusted 
%            to linear (no gamma distortion)
%   sensor - human cone structure, see coneCreate for more details
%   gain   - gain control for L, M ans S
%
% Output:
%   rgb_d  - rgb image for dichromatic or color anamalous
%
% See also:
%   s_colorAnomalousSimulation
%
% HJ, VISTA TEAM, 2016

% Check inputs
if notDefined('rgb'), error('rgb image required'); end
if notDefined('d'), error('display structure required'); end
if notDefined('sensor'), error('cone structure required'); end
if notDefined('gain'), gain = [1 1 1]; end

% Adjust display and cone to make sure they are under same wavelength
% samples
wave = displayGet(d, 'wave');
sensor = sensorSet(sensor, 'wave', wave);

% Compute the transform matrix
T = rgb2oppMatrix(d, [], gain) \ rgb2oppMatrix(d, sensor, gain);

% Compute color appearance for specified sensor
rgb_d = imageLinearTransform(rgb, T');

end

function T = rgb2oppMatrix(d, sensor, gain, varargin)
% Comptue rgb to opponent space matrix
%   T = rgb2oppMatrix(d, sensor, gain)
%
% Inputs:
%   d      - display structure
%   sensor - human sensor structure, if not given, use default human sensor
%   gain   - gain control for L, M and S
%
% Outputs:
%   T - rgb to opponent space transform, should be applied on left T*rgb
%
% HJ, VISTA TEAM, 2016

% check inputs
if notDefined('d'), error('display structure required'); end
if notDefined('sensor'), sensor = sensorCreate('human'); end
if notDefined('gain'), gain = [1 1 1]; end
sensor = sensorSet(sensor, 'wave', displayGet(d, 'wave'));

% Compute WS, YB, RG absorption curve
qe = sensorGet(sensor, 'spectral qe');
qe = qe(:, 2:4); % get rid of K and only use L, M, S
qe = bsxfun(@rdivide, qe, max(qe)); % normalize
qe = bsxfun(@times, qe, gain(:)');  % gain control
opp = qe * [.6 .4 0; .24 .105 -.7; 1.2 -1.6 .4]';

% compute rgb to opponent transform matrix
spd = displayGet(d, 'spd');
T = opp' * spd;

% normalize T so that every line adds up to 1
T = bsxfun(@rdivide, T, sum(T, 2));

end