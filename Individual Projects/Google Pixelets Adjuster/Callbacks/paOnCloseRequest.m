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

%% Get pixelet adjuster handler
hG = paGetHandler();
if isempty(hG), delete(gcf); return; end
if ~hG.saveWindowPos, delete(gcf); return; end


%% Save window position
Pos = get(gcf,'Position');
paSettingFileName = fullfile(paRootPath, 'Data', 'pixeletSettings.mat');
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