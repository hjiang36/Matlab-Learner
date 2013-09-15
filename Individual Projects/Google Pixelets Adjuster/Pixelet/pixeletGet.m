function val = pixeletGet(pix, param, varargin)
%% function pixeletGet(pix, param, [varargin])
%    get pixelet parameters and derived properties
%
%  Inputs:
%    pix      - pixelet structure, refer to d_pixeletAdjustment for details
%    param    - string, parameter name / derived property name, the program
%               ignores blanks and upper / lower cases letters are treated
%               the same
%    varargin - units for some parameter, not supported now
%
%  Output:
%    val      - value for specific parameter / properties
%
%  Parameters supported:
%    Content & Data:
%      {image content, content}
%      {image content size}
%      {display image, image}
%      {mask, msk}
%      {mask size, mskSz}
%    
%    Display position & Size
%       {display size, size, sz}
%       {display width, width}
%       {display Height, height}
%       {upper left position, ul pos, disp ul pos}
%       {lower right position, lr pos, disp lr pos}
%       {display center}
%
%    Position in source image
%      {source upper left pos, in ul pos}
%      {source lower right pos, in lr pos}
%      {source center}
%
%    Overlap & blur size
%      {overlap size, overlapSz}
%      {overlap left, overlapL}
%      {overlap right, overlapR}
%      {overlap up, overlapU}
%      {overlap down, overlapD}
%      {blur size, blurSz}
%      {blur left, blurL}
%      {blur right, blurR}
%      {blur up, blurU}
%      {blur down, blurD}
%
%  Example:
%    mask = pixeletGet(pix, 'msk');
%
%  See also:
%    pixeletSet
%
%  (HJ) Sep, 2013

%% Check inputs
if nargin < 1, error('pixelet structure required'); end
if nargin < 2, error('parameter / property name required'); end

%% Get parameter value
val = [];
switch lower(strrep(param, ' ', ''))
    case {'imagecontent', 'content'}
        val = pix.imgContent;
    case {'displayimage', 'image'}
        val = pix.dispImg;
    case {'imagecontentsize'}
        val = size(pix.imgContent);
    case {'mask', 'msk'} 
        if isfield(pix, 'msk'), val = pix.msk; end
    case {'masksize', 'msksz'}
        if isfield(pix, 'msk'), val = size(pix.msk); end
    case {'displaysize', 'size', 'sz'}
        if isfield(pix, 'dispSize'), val = pix.dispSize; end
    case {'displaywidth', 'width'}
        if isfield(pix, 'dispSize'), val = pix.dispSize(2); end
    case {'displayheight', 'height'}
        if isfield(pix, 'dispSize'), val = pix.dispSize(1); end
    case {'upperleftposition', 'ulpos', 'dispulpos'}
        if isfield(pix, 'dispPos'), val = pix.dispPos; end
    case {'lowerrightposition', 'lrpos', 'displrpos'}
        val = pix.dispPos + pix.dispSize;
    case {'sourceupperleftpos', 'inulpos'}
        if isfield(pix, 'srcUl'), val = pix.srcUl; end
    case {'sourcelowerrightpos', 'inlrpos'}
        if isfield(pix, 'srcLr'), val = pix.srcLr; end
    case {'displaycenter'}
        val = pix.dispPos + pix.dispSize / 2;
    case {'sourcecenter'}
        val = (pix.srcUl + pix.srcLr) / 2;
    case {'overlapsize', 'overlapsz'}
        val = [pix.overlapL pix.overlapR ...
               pix.overlapU pix.overlapD];
    case {'overlapleft', 'overlapl'}
        if isfield(pix, 'overlapL'), val = pix.overlapL; end
    case {'overlapright', 'overlapr'}
        if isfield(pix, 'overlapR'), val = pix.overlapR; end
    case {'overlapup', 'overlapu'}
        if isfield(pix, 'overlapU'), val = pix.overlapU; end
    case {'overlapdown', 'overlapd'}
        if isfield(pix, 'overlapD'), val = pix.overlapD; end
    case {'blursize', 'blursz'}
        val = [pix.blurL pix.blurR pix.blurU pix.blurD];
    case {'blurleft', 'blurl'}
        if isfield(pix, 'blurL'), val = pix.blurL; end
    case {'blurright', 'blurr'}
        if isfield(pix, 'blurR'), val = pix.blurR; end
    case {'blurup', 'bluru'}
        if isfield(pix, 'blurU'), val = pix.blurU; end
    case {'blurdown', 'blurd'}
        if isfield(pix, 'blurD'), val = pix.blurD; end
        
    otherwise
        warning(['Unknown parameter ' param ' encountered.']);
end

end