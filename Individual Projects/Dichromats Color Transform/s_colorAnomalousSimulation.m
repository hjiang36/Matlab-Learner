%% s_colorAnomalousSimulation
%
%    This script simulates the image in the eye of color anomalous
%
%  (HJ) ISETBIO TEAM, 2015


%% Init
ieInit;

%% load cone sensitiviy
wave = 400:700;
img  = im2double(imread('hats.jpg'));
d = displayCreate('LCD-Apple');
scene = sceneFromFile(img, 'rgb', [], d, wave);
p = sceneGet(scene, 'photons');
[p, r, c] = RGB2XWFormat(p);

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

% simulate color anomalous image (deutan-anomalous)
hfig = vcNewGraphWin([], 'wide');
peakShift = 0:29;
transM = eye(3);
% sensor = sensorCreate('human');
% sensor = sensorSet(sensor, 'wave', wave);

videoObj = VideoWriter('colorAnomalous.avi');
videoObj.FrameRate = 5;
open(videoObj);

% normalM = sensorGet(sensor, 'spectral qe');
% normalM = normalM(:, 3);
% normalM = normalM / max(normalM);
spd = ieReadSpectra('stockman', wave);
normalM = spd(:,2);

for ii = 1:length(peakShift);
    % cone = coneCreate('human', 'wave', wave);
    % coneSpd = coneGet(cone, 'absorptance');
    
    % coneSpd(:, 2) = circshift(coneSpd(:, 2), peakShift(ii), 1);
    % coneAbsorbance = -log10(1 - coneSpd) * diag(1./coneGet(cone, 'pods'));
    % cone = coneSet(cone, 'absorbance', coneAbsorbance);
    % sensor = sensorSet(sensor, 'human cone', cone);
    
    % spd = sensorGet(sensor, 'spectral qe');
    % spd = spd(:, 2:4); % get rid of K and only use L,M,S
    % spd = bsxfun(@rdivide, spd, max(spd));
    waveNumber = 1 ./ wave - 1/540 + 1/(540 + peakShift(ii));
    shiftWave = 1 ./ waveNumber;
    spdShift = spd;
    spdShift(:, 2) = interp1(shiftWave, spd(:,2), wave, 'linear', 0);

    
    img_lms = reshape(p * spdShift, [r,c,3]);
    transM(2, :) = normalM' * Gamma(spdShift');
    
    img_lms_T = imageLinearTransform(img_lms, transM');
    img_srgb_T = lms2srgb(img_lms_T);
    
    subplot(1, 2, 1); plot(wave, spdShift);
    xlabel('wavelength (nm)'); ylabel('Sensitivity');
    subplot(1, 2, 2); imshow(img_srgb_T);
    
    drawnow; writeVideo(videoObj, getframe(hfig));
end
close(videoObj);