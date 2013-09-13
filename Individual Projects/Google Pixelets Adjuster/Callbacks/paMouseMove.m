function paMouseMove(~, ~)
%% function paMouseMove
%    This is the mouse move callback function for pixelet adjuster
%    This function process the dragging effect when mouse left button is
%    down
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Get pixelet adjuster handler
hG.fig = findobj('Tag','PixeletAdjustment');
hG = getappdata(hG.fig,'handles');
if ~exist('hG','var') || isempty(hG) || ~isfield(hG,'mouseDown')
    return;
end
if ~hG.mouseDown, return; end

%% Process drag request
curPoint = round(get(gca, 'CurrentPoint'));
curPix   = hG.selected;
% erase pixelet being dragged
hG.dispI = erasePixelet(hG.dispI,hG.pixelets{curPix});

% Check if position is valid
if hG.pixelets{curPix}.dispPos >= hG.downPos - curPoint(1,[2 1])
    hG.pixelets{curPix}.dispPos = hG.pixelets{curPix}.dispPos+...
        curPoint(1,[2 1]) - hG.downPos;
    hG.downPos = curPoint(1,[2 1]);

    hG.dispI   = drawPixelet(hG.dispI,hG.pixelets{curPix});
    imshow(hG.dispI);
end

setappdata(hG.fig,'handles',hG);

end