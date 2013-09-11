function Img = erasePixelet(Img, pix)
%% function erasePixelet(Img, pix)
%    erase pixelet from canvas image
%
%  Inputs:
%    Img   - canvas image matrix
%    pix   - pixelet structure, should contain as least 
%           .dispPos  (display position)
%           .dispSize (display size in pixels)
%
%  Outpus:
%    Img   - canvas image with pixelet pix erased
%
%  See also:
%    drawPixelet, refreshPixelets
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('Canvas image required'); end
if nargin < 2, error('pixelet structure required'); end

%% Erase from canvas
Img(pix.dispPos(1):pix.dispPos(1)+pix.dispSize(1),...
    pix.dispPos(2):pix.dispPos(2)+pix.dispSize(2),:) = 0;
end