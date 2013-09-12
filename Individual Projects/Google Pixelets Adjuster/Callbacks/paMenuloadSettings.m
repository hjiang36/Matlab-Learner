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
if exist('pixeletSettings.mat','file');
    c  = load('pixeletSettings.mat');
    if ~isfield(c,'hG')
        return;
    end
    hG = c.hG;
    imshow(hG.dispI);
    setappdata(hG.fig,'handles',hG);
else
    msgbox('Cannot find settings file');
end

end