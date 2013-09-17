function hf = fullScreen(hf)
%% function fullScreen(hf)
%    This is a function that makes a full screen plot
%
%  Inputs:
%    hf   - handle of figure
%
%  Output:
%    hf   - handle of figure with full screen related properties set
%
%  Example:
%    load earth.mat
%    image(X);
%    colormap(map)
%    hf = fullScreen(gcf);
%
%  See also:
%    set, get
%
%  (HJ) Sep, 2013

%% Check inputs
if nargin < 1, hf = figure; end

%% Set fullscreen
set(hf, 'Visible','off','MenuBar','none','NumberTitle','off');
ha = gca;
set(ha,'Visible','off');
set(ha,'Unit','Normalized','Position',[0,0,1,1]);

set(hf, 'Unit', 'Normalized', 'Position', [0 0 1 1]);
set(hf, 'Unit', 'Pixels');
% make the figure visible
set(hf, 'Visible','on');

end