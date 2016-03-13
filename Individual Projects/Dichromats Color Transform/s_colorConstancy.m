% s_colorConstancy
%   Illustrate color constancy under spectral estimation theory
%
% HJ, VISTA TEAM, 2015

% Init
ieInit;

% create a macbeth color checker
scene = sceneCreate;
wave = sceneGet(scene, 'wave');
n = length(wave);

% human spectral quanta efficiency
spd = ieReadSpectra('stockman', wave);

% differentiator
Z = - eye(n);
for ii = 1 : n-1, Z(ii, ii + 1) = 1; end
Z = Z(1:end-1,:);

% specify video writer
vObj = VideoWriter('colorConstancy.avi');
vObj.FrameRate = 10;
open(vObj);

% loop through illuminant from D30 to D80
vcNewGraphWin([], 'wide');
bb65 = blackbody(wave, 6500);
for temp = 3000 : 100 : 8000
    % print info
    fprintf('Processing Illuminant ');
    % adjust scene illuminant
    bb = blackbody(wave, temp);
    s = sceneAdjustIlluminant(scene, bb);
    
    % get scene energy of the color patches
    energy = sceneGet(s, 'energy');
    patchEnergy = energy(8:16:end, 8:16:end, :);
    
    % compute lms
    lms = RGB2XWFormat(patchEnergy) * spd;
    est = zeros(size(lms, 1), length(wave)); % estimated spectra
    for ii = 1 : size(lms, 1)
        msg = sprintf('%d: %d/24', temp, ii);
        fprintf(msg);
        cvx_begin quiet
            variable w(n)
            minimize(norm(Z*(w./bb), 2))
            subject to
                w' * spd == lms(ii, :)
        cvx_end
        est(ii, :) = w ./ bb .* bb65;
        fprintf(repmat('\b', [1 length(msg)]));
    end
    fprintf('Done...\n');
    
    % upsample to form an image
    est = reshape(est, [4 6 n]);
    est_image = zeros(size(energy));
    for ii = 1 : n
        est_image(:,:,ii) = kron(est(:,:,ii), ones(16));
    end
    s_est = sceneSet(scene, 'energy', est_image);
    
    % show image
    subplot(1, 2, 1);
    imshow(sceneGet(s, 'rgb image')); title('Scene Image');
    subplot(1, 2, 2); imshow(sceneGet(s_est, 'rgb image'));
    title('Estimated Reflectance Under D65');
    
    writeVideo(vObj, getframe(gcf));
end

close(vObj);

% Suppose we don't know what is the illuminant spd, but we know which patch
% is white

% specify video writer
vObj = VideoWriter('colorConstancy_estWhite.avi');
vObj.FrameRate = 10;
open(vObj);
for temp = 3000 : 100 : 8000
    % print info
    fprintf('Processing Illuminant ');
    % adjust scene illuminant
    bb = blackbody(wave, temp);
    s = sceneAdjustIlluminant(scene, bb);
    
    % get scene energy of the color patches
    energy = sceneGet(s, 'energy');
    patchEnergy = energy(8:16:end, 8:16:end, :);
    
    % compute lms
    lms = RGB2XWFormat(patchEnergy) * spd;
    est = zeros(size(lms, 1), length(wave)); % estimated spectra
    
    % estimate illuminant using white patch
    whiteIndx = 4;
    cvx_begin quiet
        variable w(n)
        minimize(norm(Z*w, 2))
        subject to
            w' * spd == lms(whiteIndx, :)
    cvx_end
    whiteSPD = w;
    
    for ii = 1 : size(lms, 1)
        msg = sprintf('%d: %d/24', temp, ii);
        fprintf(msg);
        cvx_begin quiet
            variable w(n)
            minimize(norm(Z*(w./whiteSPD), 2))
            subject to
                w' * spd == lms(ii, :)
        cvx_end
        est(ii, :) = w ./ bb .* bb65;
        fprintf(repmat('\b', [1 length(msg)]));
    end
    fprintf('Done...\n');
    
    % upsample to form an image
    est = reshape(est, [4 6 n]);
    est_image = zeros(size(energy));
    for ii = 1 : n
        est_image(:,:,ii) = kron(est(:,:,ii), ones(16));
    end
    s_est = sceneSet(scene, 'energy', est_image);
    
    % show image
    subplot(1, 2, 1);
    imshow(sceneGet(s, 'rgb image')); title('Scene Image');
    subplot(1, 2, 2); imshow(sceneGet(s_est, 'rgb image'));
    title('Estimated Reflectance Under D65');
    
    writeVideo(vObj, getframe(gcf));
end