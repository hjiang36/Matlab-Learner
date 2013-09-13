function paMouseUp(~, ~)
%% function paMouseUp
%    This is the mouse up callback function for pixelet adjuster. This
%    function just set the corresponding field in hG to indicate that mouse
%    is up
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Get pixelet adjuster handler
hG.fig = findobj('Tag','PixeletAdjustment');
if isempty(hG.fig), error('pixelet adjuster graph handler not found'); end

%% Set field
hG = getappdata(hG.fig,'handles');
hG.mouseDown = false;

%% Save
setappdata(hG.fig,'handles',hG);

end