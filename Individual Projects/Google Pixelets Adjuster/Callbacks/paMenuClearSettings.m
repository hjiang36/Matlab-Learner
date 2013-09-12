function paMenuClearSettings(~, ~)
%% function paMenuClearSettings
%    This function is the callback function for Menu->File->Clear Settings.
%    This funciton clears / deletes all saved setting files from hard disk
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Delete Settings
while exist('pixeletSettings.mat','file')
    delete(which('pixeletSettings.mat'))
end

end