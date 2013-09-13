function hG = paGetHandler(paTagName)
%% function paGetHandler([paTagName])
%    get pixelet adjuster handler with specific tag name. If the disired
%    handler could not be found, return empty
%
%  Input:
%    paTagName  - pixelet figure tag name, default 'PixeletAdjustment'
%
%  Output:
%    hG         - pixelet adjuster structure
%
%  Example:
%    hG = paGetHandler();
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Sep, 2013

%% Check inputs
if nargin < 1, paTagName = 'PixeletAdjustment'; end

%% Get handle of graph
hG.fig = findobj('Tag', paTagName);

if isempty(hG.fig)
    hG = [];
else
    hG = getappdata(hG.fig,'handles');
end

end