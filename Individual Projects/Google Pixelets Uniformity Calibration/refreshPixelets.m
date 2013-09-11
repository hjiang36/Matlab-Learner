function dispI = refreshPixelets(hG, seq)
%% function refreshPixelets(hG, [seq])
%    redraw pixelets to window defined in hG
%
%  Inputs:
%    hG    - pixelet adjuster graph handler
%    seq   - vector of pixelet index to be redrawn, default redraw all
%            sequentially
%
%  Outputs:
%    dispI - the image shown to hG.fig
%
%  See also
%    drawOnCanvas, eraseFromCanvas
%
%  (HJ) Aug, 2013
 
%% Check inputs
if nargin < 1
    hG.fig = findobj('Tag','PixeletAdjustment');
    hG = getappdata(hG.fig,'handles');
end
if nargin < 2, seq = 1 : length(hG.pixelets); end
    
%% Redraw pixelet sequence
for curPixIndx = 1 : length(seq)
    hG.dispI = erasePixelet(hG.dispI, hG.pixelets{seq(curPixIndx)});
    hG.dispI = drawPixelet(hG.dispI, hG.pixelets{seq(curPixIndx)});
end

imshow(hG.dispI);
drawnow();

%% Set output
dispI = hG.dispI;

end