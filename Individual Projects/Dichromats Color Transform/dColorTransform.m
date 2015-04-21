function LMS = dColorTransform(dLMS, cbType, temperature)
%% function dColorTransform
%    transform LMS color to a dichromatic eye to dLMS value in trichromatic
%    eye
%    The principal of the transformation is 1) smoothness 2) non-negative
%  
%  Inputs:
%    dLMS   - N x 3 matrix, each line contains an LMS value for dichromatic
%             observers
%    cbType - colorblind type, could choose values from
%             1: proteranopia, missing L cones
%             2: deuteranopia, missing M cones
%             3: tritanopia,   missing S cones
%    temperature - white point (black body temperature)
%
%  Outputs:
%    LMS    - transformed color (equivalent color) for trichromatic
%             observer
%
%  Example:
%    LMS = dColorTransform([0 0.1 0], 2);
%
%  See also:
%    s_colorTransformForDichromat
%
%  (HJ) ISETBIO TEAM, 2015

%% Check inputs
if notDefined('dLMS'), error('LMS value required'); end
if notDefined('cbType'), error('colorblind type required'); end
if notDefined('temperature'), temperature = 6500; end

if numel(dLMS) == 3, dLMS = dLMS(:)'; end

%% Init parameters
% sensor = sensorCreate('human');
% wave = sensorGet(sensor, 'wave');
% spd  = sensorGet(sensor, 'spectral qe'); % lens, macular included
% spd  = spd(:, 2:4); % get rid of black holes

% Normalize spd
% for ii = 1 : size(spd,2)
%     spd(:,ii) = spd(:,ii) / max(spd(:, ii));
% end
wave  = 400:10:700; wave = wave(:);
spd   = ieReadSpectra('stockman', wave);
% white = blackbody(wave, temperature, 'energy');

% create differentiate matrix
n = length(wave);
Z = - eye(n);
for ii = 1 : n-1
    Z(ii, ii + 1) = 1;
end

% Get rid of last line
Z = Z(1:end-1,:);

%% Solve LMS with CVX
LMS = dLMS; % init LMS
fprintf('Computing for row 0000');
for ii = 1 : size(dLMS, 1)
    fprintf('\b\b\b\b%04d', ii);
    A = spd'; h = A(cbType,:); A(cbType, :) = [];
    c = dLMS(ii, :)'; c(cbType) = [];
    cvx_begin quiet
        variable w(n)
        minimize(norm(Z*w, 2))
        subject to
            A * w == c
            h * w >= 0
            % spd(:, cbType)' * w >= 0
    cvx_end
    LMS(ii, cbType) = spd(:, cbType)' * w;
end
fprintf('...Done...\n');

end