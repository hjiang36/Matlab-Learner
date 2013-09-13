function paAdjTotalSize(~, ~)
%% function paAdjTotalSize
%    This is the callback function for Menu -> Adjust -> Total Size in
%    pixelet adjuster
%    This function adjust the total image size to be shown to the screen,
%    note that even though the display image size get changed, the window
%    size keeps the same.
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Sep, 2013

%% Get pixelet adjuster handler
hG = paGetHandler();
if isempty(hG), return; end

%% Get new image size
prompt = {'Total Width (pixels)', 'Total Height'};
dlg_title = 'Adjust Total Size';
def = {num2str(size(hG.dispI, 2)), num2str(size(hG.dispI, 1))};
answer = inputdlg(prompt,dlg_title, 1, def);

if isempty(answer), return; end
dispWidth = str2double(answer{1});
dispHeight = str2double(answer{2});

%% If becomes larger, pad image with 0
padSize = max([dispHeight - size(hG.dispI, 1) ...
    dispWidth - size(hG.dispI, 2)], [0 0]);
hG.dispI = padarray(hG.dispI, [padSize 0], 0, 'post');
hG.dispI = hG.dispI(1:dispHeight, 1:dispWidth, :);

%% Show to screen
imshow(hG.dispI);
setappdata(hG.fig,'handles',hG);

end