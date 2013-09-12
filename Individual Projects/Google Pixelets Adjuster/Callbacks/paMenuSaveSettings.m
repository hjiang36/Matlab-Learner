function paMenuSaveSettings(~, ~)
%% function paMenuSaveSettings
%    This is the callback for Menu -> File -> Save Settings. This function
%    save current pixelets settings to file pixeletSettings.mat
%    
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Get pixelet adjuster graph handle
hG.fig = findobj('Tag','PixeletAdjustment');
if isempty(hG.fig), error('pixelet adjuster window not found'); end

hG = getappdata(hG.fig,'handles');

%% Save current settings and window positions
Pos =  get(gcf,'Position');
save pixeletSettings.mat hG Pos;

msgbox('Settings Saved');

end