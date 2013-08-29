function [Img, adaptorName, devID] = imgCapturing(adaptorName, ...
                                                        devID, varargin)
%% function imgCapturing([adapterName],[devID],[varargin])
%    Capture image with certain supported cameras
%
%  Inputs:
%    adaptorName - string, adaptor name of the camera to be used. If empty,
%                  program would detect supported cameras
%    devID       - scaler, device ID, if empty, use the first one available
%    varargin    - parameter pairs for image croping and denoising
%
%  Outputs:
%    Img         - captured and processed RGB image
%    adaptorName - string, contrains which adaptor is used in capturing
%                  camera image
%    devID       - scaler, indicating which device is used in that adaptor
%
%  Example:
%    Img = imgCapturing('macvideo',1);
%
%  Note:
%    This function require Image Aquisition Toolbox
%
%  (HJ) July, 2013

%% Check Inputs and init
if nargin < 1, adaptorName = []; end
if nargin < 2, devID = []; end
if mod(length(varargin),2) ~= 0
    error('Parameters should be in pairs');
end

%% Load and create video input object
if isempty(adaptorName)
    adaptorList = imaqhwinfo;
    adaptorList = adaptorList.InstalledAdaptors;
    adaptorIndx = 1;
    availList   = cell(length(adaptorList),1);
    disp('Avaible adaptors are listed below');
    for curAdp = 1 : length(adaptorList)
        adpInfo = imaqhwinfo(adaptorList{curAdp});
        if ~isempty(adpInfo.DeviceIDs)
            fprintf('%d\t-\t%s\n',adaptorIndx,adaptorList{curAdp});
            availList{adaptorIndx} = adaptorList{curAdp};
            adaptorIndx = adaptorIndx + 1;
        end
    end
    answer = input('Enter Adaptor Indx (0 for exit):','s');
    answer = str2double(answer);
    if isnan(answer), error('Indx not valid!'); end
    if answer == 0, Img = []; return; end
    if answer >= adaptorIndx, error('Indx out of range!'); end
    adaptorName = availList{answer};
end

if ~isempty(devID)
    vObj = videoinput(adaptorName,devID);
else
    vObj = videoinput(adaptorName);
end

%% Show Preview
figName = 'Preview of Device (Press cmd+c to capture frame)';
figure('Name', figName,...
       'NumberTitle','off',...
       'Menubar','none',...
       'KeyPressFcn',@onKeyPressed,...
       'CloseRequestFcn',@onCloseFig); 
vidRes = get(vObj, 'VideoResolution');
nBands = get(vObj, 'NumberOfBands');
hImage = image(zeros(vidRes(2), vidRes(1), nBands)); 
preview(vObj, hImage);
setappdata(0,'ImageHandle',hImage);

%% Capture and Wait
waitfor(gcf);
if nargout > 0
    Img = getappdata(0,'RetImage');
    Img = im2double(Img);
else
    Img = [];
end

delete(vObj);

end

function onKeyPressed(~,evt)
    if evt.Key == 'c' && strcmp(evt.Modifier,'command')
        close(gcf);
    end
end

function onCloseFig(~,~)
    hImage = getappdata(0,'ImageHandle');
    setappdata(0,'RetImage',getimage(hImage));
    delete(gcf);
end