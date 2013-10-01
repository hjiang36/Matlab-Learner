function paAdjPixSize(~, ~)
%% function paAdjPixSize
%    This is the callback function for menu->Adjust->Adjust pixelets size
%    This function adjusts sizes for all pixelets by a number of pixels
%
%  (HJ) Sep 2013

%% Init
hG = paGetHandler();
if isempty(hG), error('pixelet adjuster window not found'); end

%% Get new size
prompt = {'Horizontal Size Change', 'Vertical Size Change'};
dlg_title = 'Adjust Pixelets Size';
def = {'0', '0'};
answer = inputdlg(prompt, dlg_title, 1, def);

if isempty(answer), return; end
pixSzChange = [str2double(answer{2}) str2double(answer{1})];

%% Set new size
for curPix = 1 : length(hG.pixelets(:))
    pix = hG.pixelets{curPix};
    sz  = pixeletGet(pix, 'size') + pixSzChange;
    pix = pixeletSet(pix, 'size', sz);
    hG.pixelets{curPix} = pix;
end

%% Refresh
hG.dispI = refreshPixelets(hG);
setappdata(hG.fig, 'handles', hG);

end