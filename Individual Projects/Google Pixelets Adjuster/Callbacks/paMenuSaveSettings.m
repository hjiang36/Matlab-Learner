function paMenuSaveSettings(~, ~)
%% function paMenuSaveSettings
%    This is the callback for Menu -> File -> Save Settings. This function
%    saves current pixelets settings to file pixeletSettings.mat in folder
%    $PIXELET_ADJUSTER_ROOT/Data/ 
%    
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Get pixelet adjuster graph handle
hG = paGetHandler();
if isempty(hG), error('pixelet adjuster window not found'); end

hG = getappdata(hG.fig,'handles');

%% Save current settings and window positions
Pos =  get(gcf,'Position');
settignsFileName = fullfile(paRootPath, 'Data', 'pixeletSettings.mat');

save(settignsFileName, 'hG', 'Pos');

msgbox('Settings Saved');

end