function paOnCloseRequest(~, ~)
%% function paOnCloseRequest
%    This is the callback function in pixelet adjust. This function get
%    called just before program get exited
%    This program is responsible for saving current window position status
%    for future usage
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Check if need to save settings
choice = questdlg('Save settings?','Save settings?', 'Yes', 'No', 'Yes');
if strcmp(choice, 'No'), delete(gcf); return; end

%% Get pixelet adjuster handler
hG = paGetHandler();
if isempty(hG), delete(gcf); return; end
if ~hG.saveWindowPos, delete(gcf); return; end
if ~isfield(hG, 'useDefaultSettingsName')
    hG.useDefaultSettingsName = false;
end


%% Save window position
if hG.useDefaltSettingsName
    paSettingFileName = fullfile(paRootPath,'Data','pixeletSettings.mat');
else
    [fName, pName] = uiputfile;
    paSettingFileName = fullfile(pName, fName);
end

Pos = get(gcf,'Position');

if exist(paSettingFileName, 'file')
    c   = load(paSettingFileName);
    if isfield(c, 'hG')
        hG = c.hG;
        save(paSettingFileName, 'hG', 'Pos');
    else
        save(paSettingFileName, 'Pos');
    end
else
    save(paSettingFileName, 'Pos');
end

%% Close figure
delete(gcf);

end