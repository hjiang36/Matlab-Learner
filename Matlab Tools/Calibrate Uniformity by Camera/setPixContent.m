function hG = setPixContent(hG, Img)
%% function setPixContent
%    set new image to pixelet adjustment window
%
%  Inputs:
%    hG  - handle of graph, created in d_pixeleAdjustment.m
%    Img - new image to be used, should be the same size as orginal one,
%          otherwise, we resize it
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

if size(Img,1) ~= hG.inputImgSz(1) || size(Img,2) ~= hG.inputImgSz(2)
    Img = imresize(Img, hG.inputImgSz);
end

%% Cut Img to pixelets
pixContent = cutImgToPix(Img,hG);

%% Set new image to hG
for curPix = 1 : length(pixContent)
    %  set image content
    hG.pixelets{curPix}.imgContent = pixContent{curPix};
    %  set dispImg
    hG.pixelets{curPix}.dispImg  = hG.pixelets{curPix}.imgContent .* ...
        hG.pixelets{curPix}.msk;
end


end