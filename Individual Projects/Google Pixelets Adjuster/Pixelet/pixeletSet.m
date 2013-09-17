function pix = pixeletSet(pix, param, val, varargin)
%% function pixeletSet(pix, param, val, [varargin])
%    get pixelet parameters and derived properties
%
%  Inputs:
%    pix      - pixelet structure, refer to d_pixeletAdjustment for details
%    param    - string, parameter name / derived property name, the program
%               ignores blanks and upper / lower cases letters are treated
%               the same
%    val      - value to be set to parameter param
%    varargin - used to support some input for certain parameters
%
%  Output:
%    pix      - pixelet structure with parameter / properties set
%
%  Parameters supported:
%    Content & Data:
%      {image content, content, img content}        % set content image
%      {mask, msk}                                  % set mask matrix
%    
%    Display position & Size
%       {display size, size, sz}       % display image size   (resize)
%       {display width, width}         % display image width  (resize)
%       {display Height, height}       % display image height (resize)
%       {upper left position, ul pos}  % upper left corner position (move)
%       {lower right position, lr pos} % lower right corner position(move)
%       {display center}               % center position (move)
%
%    Blur size
%      {blur size}
%      {blur left, blurL}
%      {blur right, blurR}
%      {blur up, blurU}
%      {blur down, blurD}
%
%  Example:
%    pix = pixeletSet(pix, 'msk', mask);
%
%  See also:
%    pixeletGet
%
%  (HJ) Sep, 2013

%% Check inputs
if nargin < 1, error('pixelet structure required'); end
if nargin < 2, error('parameter / property name required'); end
if nargin < 3, error('parameter value required'); end

%% Set parameters
switch lower(strrep(param, ' ', ''))
    case {'imagecontent', 'content', 'imgcontent'}
        if any(size(val) ~= size(pix.imgContent))
            warning('Resize new image content size to old one');
            val = imresize(val, size(pix.imgContent));
        end
        pix.imgContent = val;
        pix.dispImg = pix.imgContent .* pix.msk;
        pix.dispImg = imresize(pix.dispImg, pix.dispSize);
    case {'mask', 'msk'}
        if any(size(val) ~= size(pix.msk))
            warning('Resize new mask to old mask size');
            val = imresize(val, size(pix.msk));
        end
        pix.msk = val;
        pix.dispImg = pix.imgContent .* pix.msk;
        pix.dispImg = imresize(pix.dispImg, pix.dispSize);
    case {'displaysize', 'size', 'sz'}
        % set display size, display image get recomputed and the new image
        % get refreshed to screen if possible
        if all(pix.dispSize == val), return; end
        pix.dispSize = val;
        pix.dispImg  = imresize(pix.dispImg, val);
    case {'displaywidth', 'width'}
        if pix.dispSize(2)== val, return; end
        pix.dispSize(2) = val;
        pix.dispImg  = imresize(pix.dispImg, val);
    case {'displayheight', 'height'}
        if pix.dispSize(1) == val, return; end
        pix.dispSize(1) = val;
        pix.dispImg = imresize(pix.dispImg, val);
    case {'upperleftposition', 'ulpos'}
        pix.dispPos = val;
    case {'lowerrightposition', 'lrpos'}
        pix.dispPos = val - pix.dispSize;
    case {'displaycenter'}
        pix.dispPos = val - pix.dispSize / 2;
    case {'blursize'}
        pix = pixeletAdjBlurSize(pix, val);
        return;
    case {'blurleft', 'blurl'}
        blurSize = pixeletGet(pix, 'blur size');
        blurSize(1) = val;
        pix = pixeletAdjBlurSize(pix, blurSize);
        return;
    case {'blurright', 'blurr'}
        blurSize = pixeletGet(pix, 'blur size');
        blurSize(2) = val;
        pix = pixeletAdjBlurSize(pix, blurSize);
        return;
    case {'blurup', 'bluru'}
        blurSize = pixeletGet(pix, 'blur size');
        blurSize(3) = val;
        pix = pixeletAdjBlurSize(pix, blurSize);
        return;
    case {'blurdown', 'blurd'}
        blurSize = pixeletGet(pix, 'blur size');
        blurSize(4) = val;
        pix = pixeletAdjBlurSize(pix, blurSize);
        return;
        
    otherwise
        warning(['Unknown parameter ' param ' encountered.']);
end

end