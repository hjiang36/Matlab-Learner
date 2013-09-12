function Img = drawPixelet(Img, pix)
%% function erasePixelet(Img, pix)
%    draw pixelet on canvas image
%
%  Inputs:
%    Img   - canvas image matrix
%    pix   - pixelet structure, should contain as least 
%           .dispPos  (display position)
%           .dispSize (display size in pixels)
%           .dispImg  (display image content)
%
%  Outpus:
%    Img   - canvas image with pixelet pix drawn
%
%  See also:
%    erasePixelet, refreshPixelets
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('Canvas image required'); end
if nargin < 2, error('pixelet structure required'); end

%% Draw pixelet
Img(pix.dispPos(1):pix.dispPos(1)+pix.dispSize(1)-1,...
    pix.dispPos(2):pix.dispPos(2)+pix.dispSize(2)-1,:) = pix.dispImg;
end