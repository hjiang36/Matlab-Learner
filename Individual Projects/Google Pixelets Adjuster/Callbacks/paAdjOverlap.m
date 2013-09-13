function paAdjOverlap(~, ~)
%% function paAdjOverlap
%    This is the callback function for Menu -> Adjust -> AdjOverlap in
%    pixelet adjuster
%    This function adjust the overlap size of each pixelet and basically
%    recreates all the pixelets
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Get pixelet adjuster handler
hG = paGetHandler();
if isempty(hG), return; end

%% Get new overlap size
prompt = {'Overlap Size (pixels)'};
dlg_title = 'Adjust Overlap';
def = {num2str(hG.overlapSize)};
answer = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer), return; end
overlapSize = str2double(answer{1});

%% Recreate pixelets
if overlapSize ~= hG.overlapSize
    hG.overlapSize = overlapSize;
    hG = initPixelets(hG);
end
% Redraw all here
hG.dispI = refreshPixelets(hG);

% Save hG
setappdata(hG.fig,'handles',hG);
end