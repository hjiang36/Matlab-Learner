function pix = pixeletAdjBlurSize(pix, blurSize)
%% function pixeletAdjBlurSize(pix, newBlurSize)
%    adjust blur size of one pixelet to some new value. Note that blur size
%    here is different from the concept of overlap size
%
%  Inputs:
%    pix      - pixelet structure, refer to d_pixeletAdjustment for details
%    blurSize - new blur size for left, right, up and down edges
%
%  Outputs:
%    pix      - pixelet structure with new blur size adjusted
%
%  Example:
%    pix = pixeletAdjBlurSize(pix, [20 20 10 10])
%
%  See also:
%    genBlurMsk
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('pixelet structure required'); end
if nargin < 2, error('new blur size required'); end

%% Compute masks
oldBlurMsk = genBlurMsk(pixeletGet(pix, 'blur size'), ...
                        pixeletGet(pix, 'mask size'));
newBlurMsk = genBlurMsk(blurSize, pixeletGet(pix, 'mask size'));
oldBlurMsk(oldBlurMsk == 0) = Inf;

%% Adjust
pix = pixeletSet(pix, 'mask', ...
    pixeletGet(pix, 'mask').* newBlurMsk ./ oldBlurMsk);
pix.blurSize = blurSize;

end