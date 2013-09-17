function dispI = refreshPixelets(hG, seq, isVisible)
%% function refreshPixelets(hG, [seq], isVisible)
%    redraw pixelets to window defined in hG
%
%  Inputs:
%    hG        - pixelet adjuster graph handler
%    seq       - vector of pixelet index to be redrawn, default redraw all
%                sequentially
%    isVisible - bool, indicating whether or not to draw it to screen,
%                default true
%
%  Outputs:
%    dispI - the image shown to hG.fig
%
%  See also
%    drawOnCanvas, eraseFromCanvas
%
%  (HJ) Aug, 2013
 
%% Check inputs
if nargin < 1 || isempty(hG)
    hG = paGetHandler();
    if isempty(hG)
        dispI = [];
        return;
    end
end

if nargin < 2 || isempty(seq), seq = 1 : length(hG.pixelets(:)); end
if nargin < 3, isVisible = true; end
    
%% Redraw pixelet sequence
%  Erase
if length(seq) == length(hG.pixelets(:))
    hG.dispI(:) = 0; % Redraw all, set to black
else
    for curPixIndx = 1 : length(seq)
        hG.dispI = erasePixelet(hG.dispI, hG.pixelets{seq(curPixIndx)});
    end
end

% Draw
for curPixIndx = 1 :length(seq)
    hG.dispI = drawPixelet(hG.dispI, hG.pixelets{seq(curPixIndx)});
end

if isVisible
    imshow(hG.dispI);
    drawnow();
end

%% Set output
dispI = hG.dispI;

end