function paMenuClearWindowPos(~, ~)
%% function paMenuClearWindowPos
%  This is the callback function for Menu -> File -> Clear Window Pos. This
%  function deletes the saved window postion form the setting file and
%  prevent the program from saving window position when it get closed
%
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Delete window position from settings file
if exist('pixeletSettings.mat','file')
    c  = load('pixeletSettings.mat');
    if ~isfield(c,'hG')
        delete('pixeletSettings.mat');
    else
        hG = c.hG;
        save pixeletSettings.mat hG;
    end
end

%% Prevent program from saving window position
hG.fig = findobj('Tag','PixeletAdjustment');
if isempty(hG.fig), error('Pixelet adjuster graph handle not found'); end
hG = getappdata(hG.fig,'handles');

hG.saveWindowPos = false;
setappdata(hG.fig,'handles',hG);

end