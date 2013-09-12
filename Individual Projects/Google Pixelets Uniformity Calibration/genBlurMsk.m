function msk = genBlurMsk(blurSize, mskSize, gammaV)
%% function genBlurMsk(blurSize, mskSize, [gammaV])
%    generate blur matrix with specific size. Here, we use linear
%    transition for the blurred region. Note that blur is different from
%    the concept of overlap. Overlap size controls pixel replication while
%    blur size controls smooth transitions near the edges. Mask values will
%    be the same between channels
%
%  Inputs:
%    blurSize   - blur region size for left, right, up and down in pixels
%    mskSize    - mask size in pixels
%    gammaV     - gamma value of display, by default, 2.2
%
%  Outputs:
%    msk        - mask matrix with smooth transition set
%
%  Example:
%    msk = genBlurMsk([20 20 0 0], [100 100], 1.5);
%
%  (HJ) Aug, 2013

%% Check inputs
%  check number of inputs
if nargin < 1, error('blur region size required'); end
if nargin < 2, error('mask size required'); end
if nargin < 3, gammaV = 2.2; end

% if blurSize is less than 4, pad 0 to make it with length 4
if length(blurSize) < 4
    tmp = blurSize;
    blurSize = zeros(1, 4);
    blurSize(1 : length(tmp)) = tmp;
end

%% Create mask
%  Create mask with left and right transition region
mskLR = ones(1, mskSize(2));
mskLR(1 : blurSize(1)) = linspace(0, 1, blurSize(1));
mskLR(end - blurSize(2) + 1 : end) = linspace(1, 0, blurSize(2));
mskLR = repmat(mskLR, [mskSize(1) 1 3]);

%  Create mask with up and down transition region
mskUD = ones(mskSize(1), 1);
mskUD(1 : blurSize(3)) = linspace(0, 1, blurSize(3));
mskUD(end - blurSize(4) + 1 : end) = linspace(1, 0, blurSize(4));
mskUD = repmat(mskUD, [1 mskSize(2) 3]);

%  Combine the two masks
msk = min(mskLR, mskUD);

%  Gamma distortion
msk = msk.^(1/gammaV);
end