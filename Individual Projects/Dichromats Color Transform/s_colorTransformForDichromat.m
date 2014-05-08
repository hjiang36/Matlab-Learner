%% s_colorTransformForDichromat
%
%    This script generates a transformation method for dichromats
%    However, it's just for fun and nothing is validated here.
%    For research and other usage, please use brettel's mehtod to do the
%    transformation
%
%  (HJ) May, 2014

%% Create standard human observer
sensor = sensorCreate('human');
wave = sensorGet(sensor, 'wave');
spd  = sensorGet(sensor, 'spectral qe'); % lens, macular included
spd  = spd(:, 2:4); % get rid of black holes

% Normalize spd
for ii = 1 : size(spd,2)
    spd(:,ii) = spd(:,ii) / max(spd(:, ii));
end
% figure; plot(wave, spd); grid on;

%% Create differentiation matrix
n = length(wave);
Z = - eye(n);
for ii = 1 : n-1
    Z(ii, ii + 1) = 1;
end

% Get rid of last line
Z = Z(1:end-1,:);

%% Compute transformation
% Compute transformation matrix (Gamma)
Z2 = Z'*Z;
Gamma = @(A) (Z2 + A'*A - Z2*A'/(A*A')*A*Z2)\A';

% For proteranopia: MS -> L
A = spd(:,2:3)';
transL = spd(:,1)' * Gamma(A);

% For deuteranopia: LS -> M
A = spd(:,[1 3])';
transM = spd(:,2)' * Gamma(A);

% For tritanopia: LM -> S
A = spd(:, 1:2)';
transS = spd(:,3)' * Gamma(A);

%% Find anchor wavelength
%  Anchor wavlength is those whose transformed LMS are the same as the
%  original LMS

% Compute L anchor
spdDiff = spd(:,1) - spd(:, [2 3]) * transL';
pp = spline(wave, spdDiff);
f  = @(x) ppval(pp, x);
anPro(1) = fzero(f, [400 520]);
anPro(2) = fzero(f, [520 700]);

% Compute M anchor
spdDiff = spd(:,2) - spd(:, [1 3]) * transM';
pp = spline(wave, spdDiff);
f  = @(x) ppval(pp, x);
anDeu(1) = fzero(f, [400 520]);
anDeu(2) = fzero(f, [520 700]);

% Compute S anchor
spdDiff = spd(:,3) - spd(:, [1 2]) * transS';
pp = spline(wave, spdDiff);
f  = @(x) ppval(pp, x);
anTri(1) = fzero(f, [400 520]);
anTri(2) = fzero(f, [520 700]);