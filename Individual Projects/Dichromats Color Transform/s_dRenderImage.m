%% s_dRenderImage
%    render image with pre-computed data
%
%  (HJ) ISETBIO TEAM, 2015

%% Init
ieInit;
load dColorTransformPre.mat

%% Load image
I = im2double(imread('hats.jpg'));
LMS = xyz2lms(srgb2xyz(I));
vcNewGraphWin;
subplot(2, 2, 1); imshow(I); title('original');

%% Transform for protanopia
[dLMS, r, c] = RGB2XWFormat(LMS);
dLMS(:, 1) = 0; % remove L
s = sum(dLMS, 2); % scale factor
dM = dLMS(:, 2) ./ s;

sPoints = linspace(0, 1, N);
dLMS(:, 1) = interp1(sPoints, L, dM, 'linear') .* s;
dLMS = XW2RGBFormat(dLMS, r, c);

% show image
subplot(2, 2, 2); imshow(lms2srgb(dLMS)); title('Protan');

%% Transform for deuteranopia
[dLMS, r, c] = RGB2XWFormat(LMS);
dLMS(:, 2) = 0; % remove M
s = sum(dLMS, 2); % scale factor
dL = dLMS(:, 1) ./ s;

sPoints = linspace(0, 1, N);
dLMS(:, 2) = interp1(sPoints, M, dL, 'linear') .* s;
dLMS = XW2RGBFormat(dLMS, r, c);

% show image
subplot(2, 2, 3); imshow(lms2srgb(dLMS)); title('Deutan');

%% Transform for tritanopia
[dLMS, r, c] = RGB2XWFormat(LMS);
dLMS(:, 3) = 0; % remove S
s = sum(dLMS, 2); % scale factor
dL = dLMS(:, 1) ./ s;

sPoints = linspace(0, 1, N);
dLMS(:, 3) = interp1(sPoints, S, dL, 'linear') .* s;
dLMS = XW2RGBFormat(dLMS, r, c);

% show image
subplot(2, 2, 4); imshow(lms2srgb(dLMS)); title('Tritan');