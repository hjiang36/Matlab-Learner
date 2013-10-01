function paMenuloadSettings(~, ~)
%% function paMenuLoadSettings
%    This is the callback for Menu -> File -> Load Settings. This function
%    loads saved pixelets settings to current handle of pixelet adjuster
%    graph
%    
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Try loading setting file
try
    [fName, pName] = uigetfile({'*.mat','MATLAB DATA FILE'});
    settingsFileName = fullfile(fName, pName);
    c = load(settingsFileName);
    if ~isfield(c,'hG')
        return;
    end
    hG = c.hG;
    imshow(hG.dispI);
    setappdata(hG.fig,'handles',hG);
catch
    msgbox('Cannot find settings file');
end

end