function paCalByCameraAuto(~, ~)
%% function paCalByCameraManuual
%  This is the callback function for Menu -> Calibrate -> Camera (Auto)
%  This function is aimed at calibrating the uniformity automatically. In
%  this method, the program will compute the proper adjusted mask for
%  uniformity automatically
%
%  See aslo:
%    calibrationByCameraAuto, s_pixeletAjuster
%
%  (HJ) Aug, 2013

%% Get Pixelet Adjuster Handler
hG.fig = findobj('Tag','PixeletAdjustment');
if isempty(hG.fig), error('pixelet adjuster window not found'); end

hG = getappdata(hG.fig,'handles');

%% Auto camera calibration
hG = calibrationByCameraAuto(hG);

%% Save adjusted mask
setappdata(hG.fig, 'handles', hG);
end