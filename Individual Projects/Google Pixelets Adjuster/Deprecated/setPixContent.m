function hG = setPixContent(hG, Img, isRedraw)
%% function setPixContent(hG, Img, [isRedraw])
%    set new image to pixelet adjustment window
%
%  Inputs:
%    hG       - handle of graph, created in d_pixeleAdjustment.m
%    Img      - new image to be used, should be the same size as orginal
%               one, otherwise, we resize it
%    isRedraw - indicating whether or not to redraw to screen now
%               by default, it's set to false
%
%  Outputs:
%    hG  - handle of graph, with new image set
%
%  Example:
%    hG = setPixContent(hG, Img)
%
%  See also:
%    cutImgToPix, calibrationByCamera
%
%  (HJ) Aug, 2013

%% Check Inputs
if nargin < 1, error('Handle of graph required'); end
if nargin < 2, error('New image to diplay required'); end
if nargin < 3, isRedraw = false; end

if size(Img,1) ~= hG.inputImgSz(1) || size(Img,2) ~= hG.inputImgSz(2)
    Img = imresize(Img, hG.inputImgSz);
end

%% Cut Img to pixelets
pixContent = cutImgToPix(Img, hG);

%% Set new image to hG
for curPix = 1 : length(pixContent)
    %  set image content
    hG.pixelets{curPix}.imgContent = pixContent{curPix};
    %  set dispImg
    hG.pixelets{curPix}.dispImg  = imresize(pixContent{curPix}, ...
        hG.pixelets{curPix}.dispSize) .* hG.pixelets{curPix}.msk;
end

%% Redraw to screen if needed
if isRedraw
    hG.dispI = zeros(size(hG.dispI));
    for curPix = 1 : length(hG.pixelets)
        hG.dispI = drawOnCanvas(hG.dispI, hG.pixelets{curPix});
    end
    
    imshow(hG.dispI);
end


end

%% Aux Functions
function Img = drawOnCanvas(Img,pix)
    Img(pix.dispPos(1):pix.dispPos(1)+pix.dispSize(1)-1,...
        pix.dispPos(2):pix.dispPos(2)+pix.dispSize(2)-1,:) = pix.dispImg;
end