function [Img, adaptorName, devID] = imgCapturing(adaptorName, ...
                                                        devID, varargin)
%% function imgCapturing([adapterName],[devID],[varargin])
%    Capture image with certain supported cameras
%
%  Inputs:
%    adaptorName - string, adaptor name of the camera to be used. If empty,
%                  program would detect supported cameras
%    devID       - scaler, device ID, if empty, use the first one available
%    varargin    - parameter name-value pairs for capturing parameters
%                  'showPreview', bool, indicating whether to capture
%                  directly or show preview and capture interactively
%                  'numberOfFrames', scaler, indicating number of frames to
%                  caputre, default is 1
%
%  Outputs:
%    Img         - captured and processed RGB image
%    adaptorName - string, contrains which adaptor is used in capturing
%                  camera image
%    devID       - scaler, indicating which device is used in that adaptor
%
%  Example:
%    Img = imgCapturing('macvideo',1, 'Show Preview', false);
%
%  Note:
%    This function require Image Aquisition Toolbox
%
%  (HJ) July, 2013

%% Check Inputs and init
%  Check inputs
if nargin < 1, adaptorName = []; end
if nargin < 2, devID = []; end
if mod(length(varargin),2) ~= 0
    error('Parameters should be in pairs');
end

% Parse parameters
showPreview = true;
numberOfFrames = 1;
for i = 1 : 2 : length(varargin)
    switch lower(strrep(varargin{i},' ', ''))
        case 'showpreview'
            showPreview = varargin{i+1};
        case 'numberofframes'
            numberOfFrames = varargin{i+1};
        otherwise
            warning('Unknown parameter encountered');
    end
end

%% Load and create video input object
adaptorList = imaqhwinfo;
adaptorList = adaptorList.InstalledAdaptors;

if isempty(adaptorName)
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
    answer = round(str2double(answer));
    if isnan(answer), error('Indx not valid!'); end
    if answer == 0, Img = []; return; end
    if answer >= adaptorIndx || answer<0, error('Indx out of range!'); end
    adaptorName = availList{answer};
end

if ~isempty(devID)
    vObj = videoinput(adaptorName,devID);
else
    adpInfo = imaqhwinfo(adaptorName);
    if length(adpInfo.DeviceIDs) == 1
        vObj = videoinput(adaptorName);
    else
        disp(['Available device for adaptor ' adaptorName ' :']);
        for curDev = 1 : length(adpInfo.DeviceIDs)
            fprintf('%d\t-\t%s\n', adpInfo.DeviceIDs{curDev}, ...
                adpInfo.DeviceInfo(curDev).DeviceName);
        end
        answer = input('Enter Device ID (0 for exit):', 's');
        if isnan(answer), error('Indx not valid!'); end
        if answer == 0, Img = []; return; end
        if answer >= curDev, error('Indx out of range!'); end
        devID = answer;
        vObj = videoinput(adaptorName, devID);
    end
end

%% Preview Image
if showPreview
    % Show preview
    figName = 'Preview of Device (Press cmd+c to capture frame)';
    figure('Name', figName,...
        'NumberTitle','off',...
        'Menubar','none',...
        'KeyPressFcn', @onKeyPressed);
    vidRes = get(vObj, 'VideoResolution');
    nBands = get(vObj, 'NumberOfBands');
    hImage = image(zeros(vidRes(2), vidRes(1), nBands));
    preview(vObj, hImage);
    setappdata(0,'ImageHandle',hImage);
    
    % Capture and Wait
    waitfor(gcf);
end

%%  Capture Image
if numberOfFrames > 1
    start(vObj);
    Img = getdata(vObj, numberOfFrames);
else
    Img = getsnapshot(vObj);
end

%% Clean up
flushdata(vObj);
delete(vObj);

end

%% Callbacks
function onKeyPressed(~,evt)
    if evt.Key == 'c' && strcmp(evt.Modifier,'command')
        close(gcf);
    end
end