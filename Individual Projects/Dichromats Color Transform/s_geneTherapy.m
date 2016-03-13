%% s_geneTherapy
%    This script simulate the consequence of gene therapy that helps
%    dichromatic observers generate their missing cone type.
%
%    This script assumes that gene therapy only affects the cone mosaic and
%    has no effect to the rest of the nerve system
%
%  (HJ) ISETBIO TEAM, 2015

%% Init Parameters
ieInit; % initialize a new ISETBIO session

imgName  = 'hats.jpg'; % image to be used
img_rgb  = im2double(imread(imgName));
img_size = [size(img_rgb, 1) size(img_rgb, 2)];
cbType = 2;

%% Compute Image for Dichromatic Observers with Brettel's Algorithm
%  convert rgb image to XYZ
img_xyz = srgb2xyz(img_rgb);

% show original image
img_srgb = xyz2srgb(img_xyz);
vcNewGraphWin;
subplot(2, 3, 1); imshow(img_srgb);
title('Trichromats');

% set white point as an equal energy light
wave = 400 : 10 : 700;
energy = 0.002 * ones(length(wave), 1);
wp = ieXYZFromEnergy(energy', wave);

% compute and show colorblind image
% convert to LMS
img_srgb_cb = lms2srgb(xyz2lms(img_xyz, cbType, 'Brettel', wp));
    
% show image
subplot(2, 3, 3); imshow(img_srgb_cb);
title('Deuteranope');

%% Compute Image for Deuteranopia Observers with Gene Therapy
%  compute LMS image for trichromats
img_lms_T = xyz2lms(img_xyz);

% compute for protanopia with gene therapy
% set mutated cone density
md = 1/3; % one third of L cones are mutated to be mutated cones
indx = rand(img_size) < md; % randomly select mutated positions

% simulate the effect for gene therapy
img_lms_GT = img_lms_T;
M = img_lms_GT(:,:,2); L = img_lms_GT(:,:,1);
L(indx) = 2/3*L(indx) + 1/3*M(indx); img_lms_GT(:,:,1) = L;

% compute rgb image
img_lms_GT(:,:,2) = 0.6949 * img_lms_GT(:,:,1)+0.2614 * img_lms_GT(:,:,3);
img_rgb_GT = lms2srgb(img_lms_GT);

% show image 
subplot(2, 3, 4); imshow(img_rgb_GT);
title('Gene Therapy (No Adapt)');

%% plot spd for gene therapy
spd = ieReadSpectra('stockman', wave);
subplot(2, 3, 2); plot(wave, spd); xlim([400 700]); hold on;

spd(:, 2) = 1/3*spd(:, 2) + 2/3*spd(:, 1);
spd(:, 2) = spd(:, 2) / max(spd(:, 2));

plot(wave ,spd(:, 2), '--');

subplot(2, 3, 5); imshow(img_srgb); title('Gene Therapy (Adapted)');