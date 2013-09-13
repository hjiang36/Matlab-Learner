%% This function has not been completed yet.
%  HJ will make modification to this one soon
%
%  (HJ) Aug, 2013
function paCalMagnification(~, ~)
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
    hG.pixelets{1}.msk = hG.pixelets{1}.msk * 0.01;
    hG.pixelets{3}.msk = hG.pixelets{3}.msk * 0.01;
    hG.pixelets{1}.dispImg = imresize(hG.pixelets{1}.imgContent,...
            hG.pixelets{1}.dispSize).*hG.pixelets{1}.msk;
    hG.pixelets{3}.dispImg = imresize(hG.pixelets{3}.imgContent,...
            hG.pixelets{3}.dispSize).*hG.pixelets{3}.msk;
    refreshPixelets(hG);
    
    [baseSz, blankImg] = pixeletSizeInPhoto(hG, 'macvideo',1);
    
    % Move to left
    ratio = 1;
    while ratio > 0.98
        hG.pixelets{2}.dispPos(2) = hG.pixelets{2}.dispPos(2) - 5;
        refreshPixelets(hG);
        curSz = pixeletSizeInPhoto(hG, 'macvideo', 1, blankImg);
        ratio = curSz / baseSz;
    end
    
    % Enlarge to fit to right
    ratio  = 1.1;
    while ratio > 1.01
        hG.dispI = erasePixelet(hG.dispI,hG.pixelets{2});
        hG.pixelets{2}.dispSize = [hG.pixelets{2}.dispSize(1) ...
                                   hG.pixelets{2}.dispSize(2) + 5];
        hG.pixelets{2}.msk = imresize(hG.pixelets{2}.msk,...
            hG.pixelets{2}.dispSize);
        hG.pixelets{2}.dispImg = imresize(hG.pixelets{2}.imgContent,...
            hG.pixelets{2}.dispSize).*hG.pixelets{2}.msk;
        refreshPixelets(hG, [1 3 2]);
        curSz  = pixeletSizeInPhoto(hG, 'macvideo', 1, blankImg);
        ratio  = curSz / baseSz;
        baseSz = curSz;
        fprintf('%d\t%f\n',curSz, ratio);
    end
end

function [sz, blankImg, diffImg] = pixeletSizeInPhoto(hG, adpName, devID, blankImg)
    if nargin < 2, adpName = []; end
    if nargin < 3, devID = []; end
    if nargin < 4, blankImg = []; end
    
    if nargin < 1
        hG.fig = findobj('Tag','PixeletAdjustment');
        hG = getappdata(hG.fig,'handles');
    end
    
    if isempty(blankImg)
        % Turn off pixelet
        hG.pixelets{2}.dispImg = hG.pixelets{2}.dispImg * 0.01;
        refreshPixelets(hG);
        % Capture
        blankImg = imgCapturing(adpName, devID, 'show preview', false);
        % Restore
        hG.pixelets{2}.dispImg = hG.pixelets{2}.dispImg * 100;
        refreshPixelets(hG);
    end
    pixeletImg = imgCapturing(adpName, devID, 'show preview', false);
    diffImg = abs(pixeletImg - blankImg);
    if size(diffImg, 3) == 3, diffImg = rgb2gray(diffImg); end
    diffImg = medfilt2(diffImg, [4 4]); % denoise
    diffImgBW = im2bw(diffImg, graythresh(diffImg));
    % Find connected components
    CC = bwconncomp(diffImgBW);
    photoSz = regionprops(CC,'Area');
    sz = max([photoSz.Area]);
end