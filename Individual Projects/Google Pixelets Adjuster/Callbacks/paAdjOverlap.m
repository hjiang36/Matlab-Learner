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
prompt = {'Horizontal Overlap Size', 'Vertical Overlap Size'};
dlg_title = 'Adjust Overlap';
def = {num2str(hG.overlapSize(1)), num2str(hG.overlapSize(2))};
answer = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer), return; end
overlapH = str2double(answer{1});
overlapV = str2double(answer{2});

%% Recreate pixelets
if any([overlapH, overlapV] ~= hG.overlapSize)
    hG.overlapSize = [overlapH, overlapV];
    hG.pixelets    = pixeletsFromImage(hG.inputImg, hG.nRows, hG.nCols, ...
        hG.overlapSize, hG.gapSize);
end
% Redraw all here
hG.dispI = refreshPixelets(hG);

% Save hG
setappdata(hG.fig,'handles',hG);
end