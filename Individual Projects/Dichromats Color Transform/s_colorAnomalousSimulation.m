%% s_colorAnomalousSimulation
%
%    This script simulates the image in the eye of color anomalous
%
%  (HJ) ISETBIO TEAM, 2015

%% load cone sensitiviy
wave = 400:700;
spd  = ieReadSpectra('stockman', wave);
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
vcNewGraphWin;
peakShift = 5:5:25;
transM = eye(3);
for ii = 1:length(peakShift);
    A = spd';
    A(2,:) = circshift(A(2,:), peakShift(ii), 2);
    img_lms = reshape(p * A', [r,c,3]);
    transM(2, :) = spd(:,2)' * Gamma(A);
    
    img_lms_T = imageLinearTransform(img_lms, transM');
    img_srgb_T = lms2srgb(img_lms_T);
    subplot(1, length(peakShift), ii); imshow(img_srgb_T);
end