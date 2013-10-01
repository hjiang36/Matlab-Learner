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
if ~isfield(hG, 'saveWindowPos'), hG.saveWindowPos = true; end
if ~isfield(hG, 'useDefaultSettingsName')
    hG.useDefaultSettingsName = false;
end

%% Save current settings and window positions
if hG.useDefaltSettingsName
    settignsFileName = fullfile(paRootPath, 'Data', 'pixeletSettings.mat');
else
    [fName, pName] = uiputfile;
    settingsFileName = fullfile(pName, fName);
end

if hG.saveWindowPos
    Pos =  get(gcf,'Position');
    save(settignsFileName, 'hG', 'Pos');
else
    save(settingsFileName, 'hG');
end

msgbox('Settings Saved');

%% Save hG

end