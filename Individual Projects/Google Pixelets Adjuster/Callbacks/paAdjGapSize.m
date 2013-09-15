function paAdjGapSize(~, ~)
%% function paAdjOverlap
%    This is the callback function for Menu -> Adjust -> Adj Gap Size in
%    pixelet adjuster
%    This function adjust the gap size of each pixelet and basically
%    change pixelet position based on current location. So, this function
%    will not re-align pixelets
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Sep, 2013

%% Get pixelet adjuster handler
hG = paGetHandler();
if isempty(hG), return; end

%% Get new overlap size
prompt = {'Horizontal Gap Size', 'Vertical Gap Size'};
dlg_title = 'Adjust Gap Size';
def = {num2str(hG.gapSize(1)), num2str(hG.gapSize(2))};
answer = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer), return; end
gapSizeH = str2double(answer{1});
gapSizeV = str2double(answer{2});

%% Adjust gap size
%  Compute difference
diffGapH = gapSizeH - hG.gapSize(1);
diffGapV = gapSizeV - hG.gapSize(2);

for curRow = 1 : hG.nRows
    for curCol = 1 : hG.nCols
        pix = hG.pixelets{curRow, curCol};
        curDispPos = pixeletGet(pix, 'disp ul pos');
        hG.pixelets{curRow, curCol} = pixeletSet(pix, 'ul pos', ...
            curDispPos + [curRow-1 curCol-1].*[diffGapV diffGapH]);
    end
end

hG.gapSize = [hG.gapSizeH hG.gapSizeV];

% Redraw all here
hG.dispI = refreshPixelets(hG);

% Save hG
setappdata(hG.fig,'handles',hG);

end