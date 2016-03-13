%% s_colorAnomalous
%    simulating color appearance anomalous using spectral estimation theory
%
%  HJ, VISTA TEAM, 2015

%% Init
ieInit;

%% load cone sensitiviy
wave = 400:700;
img  = im2double(imread('hats.jpg'));
d = displayCreate('LCD-Apple');
scene = sceneFromFile(img, 'rgb', [], d, wave);
p = sceneGet(scene, 'photons');
[p, r, c] = RGB2XWFormat(p);

%% Create differentiation matrix
n = length(wave); Z = - eye(n);
for ii = 1 : n-1, Z(ii, ii + 1) = 1; end

% Get rid of last line
Z = Z(1:end-1,:);

%% Compute transformation
% Compute transformation matrix (Gamma)
Z2 = Z'*Z;
Gamma = @(A) (Z2 + A'*A - Z2*A'/(A*A')*A*Z2)\A';

% simulate color anomalous image (deutan-anomalous)
peakShift = [0 15 20 25 25];
transM = eye(3);

spd = ieReadSpectra('stockman', wave);
normalM = spd(:,2);

vcNewGraphWin; hSPD = subplot(2, 3, 2); hold on;
plot(wave, spd); xlim([400 700]);
for ii = 1 : length(peakShift)
    waveNumber = 1 ./ wave - 1/540 + 1/(540 + peakShift(ii));
    shiftWave = 1 ./ waveNumber;
    spdShift = spd;
    spdShift(:, 2) = interp1(shiftWave, spd(:,2), wave, 'linear', 0);
    if ii > 1 && ii < 5, plot(hSPD, wave, spdShift(:,2), '--'); end
    
    img_lms = reshape(p * spdShift, [r,c,3]);
    transM(2, :) = normalM' * Gamma(spdShift');
    
    img_lms_T = imageLinearTransform(img_lms, transM');
    img_srgb_T = lms2srgb(img_lms_T);
    
    if ii == 1
        subplot(2, 3, 1); imshow(img_srgb_T);
        title('Trichromats');
    elseif ii == 5
        subplot(2, 3, 3); imshow(img_srgb_T);
        title('Deuteranope');
    else
        subplot(2, 3, ii+2); imshow(img_srgb_T);
        title(num2str(540+peakShift(ii)));
    end
end