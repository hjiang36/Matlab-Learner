function hG = initPixelets(hG)
%% function initPixelets(hG)
%  This function is deprecated and will not be used in future program.
%  Please try to use pixeletsFromImage instead.
%
%  This function sets up pixlets structure based on the prameters in handle
%  of pixelet adjuster structure (hG). This function only supports 1D
%  pixelet topology. For 2D, please us pixeletFromImage instead.
%
%  See also:
%    pixeletsFromImage
%
%  (HJ) Sep, 2013

M     = hG.inputImgSz(1); 
N     = hG.inputImgSz(2);
Img   = hG.inputImg;
nCols = hG.nCols;

overlapSize = hG.overlapSize;
nonOverlapSize = [M ceil((N - (nCols-1)*overlapSize)/nCols)];

for curPix = 1 : nCols
    % Init Left and Right overlap size
    if curPix == 1
        hG.pixelets{curPix}.overlapL = 0;
    else
        hG.pixelets{curPix}.overlapL = overlapSize;
    end
    if curPix == nCols
        hG.pixelets{curPix}.overlapR = 0;
    else
        hG.pixelets{curPix}.overlapR = overlapSize;
    end
    % Init Blur Region Size
    hG.pixelets{curPix}.blurL = hG.pixelets{curPix}.overlapL; 
    hG.pixelets{curPix}.blurR = hG.pixelets{curPix}.overlapR;
    
    % Init Position
    if ~isfield(hG.pixelets{curPix},'dispPos')
        hG.pixelets{curPix}.dispPos = [1 ...
            (curPix-1)*(nonOverlapSize(2)+overlapSize)+1];
    end
    
    % Init image content size
    hG.pixelets{curPix}.imgContent = ...
        Img(:,(curPix-1)*(nonOverlapSize(2)+overlapSize)+1 ...
            -hG.pixelets{curPix}.overlapL:...
        min(curPix*(nonOverlapSize(2)+overlapSize),N),:);
    
    % Init pixlets display size
    hG.pixelets{curPix}.dispSize = size(hG.pixelets{curPix}.imgContent);
    hG.pixelets{curPix}.dispSize = hG.pixelets{curPix}.dispSize(1:2);
    % Init Mask
    hG.pixelets{curPix}.msk = genBlurMsk([hG.pixelets{curPix}.overlapL...
         hG.pixelets{curPix}.overlapR],size(hG.pixelets{curPix}.imgContent));
    
    % Compute display image
    hG.pixelets{curPix}.dispImg  = hG.pixelets{curPix}.imgContent .* ...
        hG.pixelets{curPix}.msk;
end

end % End of function initPixelets