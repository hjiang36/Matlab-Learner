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
d = displayCreate('OculusDK2');
d.dpi = 100;
d = displaySet(d, 'wave', wave);

% scene = sceneFromFile(img, 'rgb', [], d, wave);
scene = sceneCreate;
scene = sceneSet(scene, 'wave', wave);
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

%% Initializing parameters
% Compute transformation matrix (Gamma)
Z2 = Z'*Z;
Gamma = @(A) (Z2 + A'*A - Z2*A'/(A*A')*A*Z2)\A';

% simulate color anomalous image (deutan-anomalous)
peakShift = [5 10 15 20 25.5 25.7 25.8 25.9];
% peakShift = 0:26;
transM = eye(3);

%
sensor = sensorCreate('human');
sensor = sensorSet(sensor, 'wave', wave);
cone = sensorGet(sensor, 'human cone');
absorbance = coneGet(cone, 'absorbance');
shiftWave = 1./(1 ./ wave + 1/530 - 1/556);
absorbance(:, 2) = interp1(shiftWave, absorbance(:, 1), wave, 'spline');
spd = sensorGet(sensor, 'spectral qe'); % shall we use energy efficiency?
spd = spd(:, 2:4);
spd = bsxfun(@rdivide, spd, max(spd));

%% Compute transforms
videoObj = VideoWriter('colorAnomalous_tmp.avi');
videoObj.FrameRate = 5;
open(videoObj);

hfig = vcNewGraphWin([], 'wide');
lms_tm = zeros(3, 3, length(peakShift));
for ii = 1 : length(peakShift)
    waveNumber = 1 ./ wave - 1/556 + 1/(556 - peakShift(ii));
    shiftWave = 1 ./ waveNumber;
    absShift = absorbance;
    absShift(:, 1) = interp1(shiftWave, absorbance(:, 1), wave, 'spline');
    absShift(absShift < 0) = 0;
    spdShift = sensorGet(sensorSet(sensor, 'human cone', ...
        coneSet(cone, 'absorbance', absShift)), 'spectral qe');
    spdShift = spdShift(:, 2:4);
    [~, indx] = max(spdShift);
    indx
    spdShift = bsxfun(@rdivide, spdShift, max(spdShift));
    
    img_lms = reshape(p * spdShift, [r,c,3]);
    transM(1, :) = spd(:, 1)' * Gamma(spdShift');
    
    img_lms_T = imageLinearTransform(img_lms, transM');
    rgb2lms = displayGet(d, 'spd')' * spdShift;
    rgb2lms_normal = displayGet(d, 'spd')' * spd;
    
    rgb2rgb = rgb2lms*transM'/rgb2lms_normal;
    rgb2rgb = bsxfun(@rdivide, rgb2rgb, sum(rgb2rgb));
    lms_tm(:, :, ii) = rgb2rgb;
    
    % subplot(1, 2, 1); plot(wave, spdShift);
    % xlabel('wavelength (nm)'); ylabel('Sensitivity');
    % subplot(1, 2, 2); imshow(img_srgb_T);
    img_srgb_T = lms2srgb(img_lms_T);
    imshow(imresize(img_srgb_T, 10));
    drawnow; writeVideo(videoObj, getframe(hfig));
end
close(videoObj);

%% Simulation using Machado method
vcNewGraphWin;
peak_wave = zeros(length(peakShift), 1);
rgb_tm = zeros(3, 3, length(peakShift));
for ii = 1 : length(peakShift)
    waveNumber = 1 ./ wave - 1/556 + 1/(556 - peakShift(ii));
    shiftWave = 1 ./ waveNumber;
    absShift = absorbance;
    absShift(:, 1) = interp1(shiftWave, absorbance(:,1), wave, 'spline');
    s = sensorSet(sensor, 'human cone', coneSet(cone, 'absorbance', absShift));
    
    % compute peak of current L
    qe = sensorGet(s, 'spectral qe'); qe = qe(:, 2:4);
    [~, pos] = max(qe); peak_wave(ii) = wave(pos(1));
    
    [img_srgb_T, t] = colorAnomalous(img, d, s, [1 1.1823 1]);
    imshow(img_srgb_T); drawnow;
    rgb_tm(:,:,ii) = t';
end

save transform.mat peak_wave rgb_tm