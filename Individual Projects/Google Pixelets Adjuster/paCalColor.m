function paCalColor(~, ~)
%% function paCalColor
%    This routine is the callback function for pixelet adjust
%    Menu->Calibration->By Camera (Color)
%    This function calibrates the color and mean brightness between
%    pixelets in pixelet adjuster
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Sep, 2013

%% Get pixelet adjuster handle & init camera
hG = paGetHandler();
if isempty(hG), error('pixelet adjuster window not found'); end
if isfield(hG, 'adpName')
    adpName = hG.adpName;
else
    adpName = 'macvideo';
end

if isfield(hG, 'devID'), devID = hG.devID; else devID = 1; end
if isfield(hG, 'gamma'), gamma = hG.gamma; else gamma = 2.2; end

%% Get mean color and brightness for each pixelet
pixeletChannelMean = zeros(numel(hG.pixelets), 3);

%  Turn off all pixelets
[M, N, ~] = size(hG.dispI);
dispImg   = zeros(M, N, 3);
imshow(dispImg); drawnow;
blankImg  = imgCapturing(adpName, devID, 'show preview', false, ...
                         'number of frames', 10);
blankImg  = mean(blankImg(:, :, :, 3:end),4)/255;

for curPix = 1 : numel(hG.pixelets)
    % Turn off all pixelts except current one
    dispImg   = zeros(M, N, 3);
    pix = hG.pixelets{curPix};
    pix = pixeletSet(pix, 'image content', ...
                     ones(pixeletGet(pix, 'image content size')));
    dispImg = drawPixelet(dispImg, pix);
    imshow(dispImg); drawnow;
    
    % Capture image
    photoImg = imgCapturing(adpName, devID, 'show preview', false, ...
                            'number of frames', 10);
    photoImg = mean(photoImg(:, :, :, 3:end), 4)/255;
    
    % Computre Region size
    diffImg = abs(photoImg - blankImg);
    grayDiffImg = rgb2gray(diffImg);
    bwImg   = im2bw(grayDiffImg, graythresh(grayDiffImg));
    CC = bwconncomp(bwImg);
    pixeletArea = regionprops(CC, 'Area');
    pixeletArea = max([pixeletArea.Area]);
    disp(num2str(pixeletArea));
    
    % Compute mean value for each channel
    pixeletChannelMean(curPix, :) =  sum(sum(diffImg)) / pixeletArea;
end

%% Adjust
baseColor = min(pixeletChannelMean);
for curPix = 1 : numel(hG.pixelets)
    pix   = hG.pixelets{curPix};
    scale = (baseColor ./ pixeletChannelMean(curPix, :)).^(1/gamma);
    msk   = pixeletGet(pix, 'msk');
    for i = 1 : 3
        msk(:,:,i) = msk(:,:,i) * scale(i);
    end
    hG.pixelets{curPix} = pixeletSet(pix, 'msk', msk);
end

%% Save the adjustment
hG.dispI = refreshPixelets(hG);
setappdata(hG.fig,'handles',hG);

end