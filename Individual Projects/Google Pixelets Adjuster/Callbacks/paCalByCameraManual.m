function paCalByCameraManual(~, ~)
%% function paCalByCameraManuual
%  This is the callback function for Menu -> Calibrate -> Camera (Manual)
%  This function is aimed at calibrating the uniformity semi-automatically.
%  In this method, the user is asked to choose corresponding points between
%  input image and camera captured image. Then, the program will compute
%  the proper adjusted mask for uniformity automatically
%
%  See aslo:
%    calibrationByCameraManual, s_pixeletAjuster
%
%  (HJ) Aug, 2013

%% Get Pixelet Adjuster Handler
hG.fig = findobj('Tag','PixeletAdjustment');
if isempty(hG.fig), error('pixelet adjuster window not found'); end

hG = getappdata(hG.fig,'handles');

%% Manual Camera Calibration
It = im2double(imread('popup_white - text.jpg'));
Id = ones(size(It));
hG = paCalCameraManual(hG,It,Id);

%% Save adjusted pixelet structure
setappdata(hG.fig,'handles',hG);
end