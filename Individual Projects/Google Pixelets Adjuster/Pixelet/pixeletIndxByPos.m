function [pixIndx, pix] = pixeletIndxByPos(pixelets, pos)
%% function pixeletIndxByPos(pixelets, pos)
%    find out 2D pos falls in which pixelet. The index and pixelet struct 
%    of first pixelet with pos covered by its display region get returned
%    by this program
%
%  Inputs:
%    pixelets  - cell array, each cell contains a pixelet structure
%    pos       - 2D vector, containing position information
%
%  Outputs:
%    pixIndx   - pixelet index found, if not found, 0 is returned
%    pix       - pixelet structure found, if not found, reutrn empty
%
%  Example:
%    [~, pix] = pixeletIndxByPos(hG.pixelets, [10 20]);
%
%  See also:
%    pixeletGet
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('pixelets cell array required'); end
if nargin < 2, error('2D vector position required'); end

if numel(pos) ~= 2, error('position should contain 2 entries'); end

%% Find first pixelet containing pos
%  Loop over pixelets cell array
for pixIndx = 1 : length(pixelets)
    pix   = pixelets{pixIndx};
    ulPos = pixeletGet(pix, 'ul pos');
    lrPos = pixeletGet(pix, 'lr pos');
    if all(pos >= ulPos & pos <= lrPos)
        % found, return current pix and pixIndx
        return;
    end
end

% not found, return empty
pixIndx = 0;
pix = [];

end