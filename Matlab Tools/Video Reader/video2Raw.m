function vidParams = video2Raw(inName, outName, varargin)
%% function status = video2Raw(inName, outName, [varargin])
%    This is function that loads in a MATLAB compatible video file and save
%    the raw image frame data to output data file
%    Output data file can be raw binary file or .mat files (MATLAB data
%    file)
%
%  Inputs:
%    inName:   input video file name, should include file extension
%    outName:  output file name
%    varargin: parameter name-value pairs, now supports
%              - outFormat, supports 'dat' and 'mat'
%                - .dat video file is saved in RGB sequence in rows first
%                  order, 8 bit per channel. For example, for image I, the
%                  output file would contain sequence I(1,1,1), I(1,1,2), 
%                  I(1,1,3), I(1,2,1), etc.
%                
%                - .dat audio file contains 32 bit header, indicating the
%                  sampling rate and 32 bit field, indicating samples per 
%                  channel. The content of the file contains samples for 
%                  each channel, saved as 16 bit integers
%              - saveAudio, bool, indicate whether to save video file
%              - outWidth, output image width, in pix
%              - outHeight, output image height, in pix
%              - startFrame, start frame number, will override startTime
%              - endFrame, end frame number, will override endTime
%              - startTime, starting time
%              - endTime, ending time
%
%  Output:
%    vidParams: video parameters: 
%                -width, height, framerate, nFrames, bitsPerPix
%  
%  Example:
%    vidParams = video2Raw('mpegVideo1.mpg','video1.dat');
%
%  See also:
%    VideoReader
%
%  (HJ) Aug, 2013

%% Check inputs
%  check number of inputs
if nargin < 1, error('Input video name required'); end
if nargin < 2, error('Output file name required'); end
if mod(length(varargin),2) ~= 0
    error('Parameter should be in pairs'); 
end

%  check if input / output file exists
if ~exist(inName, 'file'), error('Input video file not found'); end
if exist(outName, 'file')
    choice = questdlg('Output File already exist, overwrite it?', ...
        'File exists','Replace', 'Cancle', 'Cancle');
    switch choice
        case 'Replace'
            delete(outName);
        case 'Cancle'
            vidParams = [];
            return;
        otherwise
            error('How could you get here');
    end
end

%% Parse input parameters
%  init parameters
outFormat  = 'dat';
outWidth   = 0; outHeight  = 0; % output frame rate
startTime  = 0; endTime    = inf; % start and end time
startFrame = 0; endFrame   = inf; % Start and end frame number
saveAudio  = 0; % ouput audio

for i = 1 : 2 : length(varargin)
    switch lower(strrep(varargin{i},' ',''))
        case 'outformat'
            if strcmpi(varargin{i+1},'mat')
                outFormat = 'mat';
            end
        case 'outwidth'
            if isnumeric(varargin{i+1})
                outWidth = round(varargin{i+1});
            end
        case 'outheight'
            if isnumeric(varargin{i+1})
                outHeight = round(varargin{i+1});
            end
        case 'starttime'
            if isnumeric(varargin{i+1})
                startTime = varargin{i+1};
            end
        case 'startframe'
            if isnumeric(varargin{i+1})
                startFrame = round(varargin{i+1});
            end
        case 'endtime'
            if isnumeric(varargin{i+1})
                endTime = varargin{i+1};
            end
        case 'endframe'
            if isnumeric(varargin{i+1})
                endFrame = round(varargin{i+1});
            end
        case 'saveaudio'
            saveAudio = varargin{i+1};
            % check if file contains readable audio
            if saveAudio
                fileInfo = mmfileinfo(inName);
                if isempty(fileInfo.Audio.Format)
                    warning(['No audio in file' inName 'detected']);
                    saveAudio = false;
                end
            end
        otherwise
            warning(['Unknown parameter: ' varargin{i} ' encountered']);
    end
end

% do some simple check here
assert(outWidth >= 0 && outHeight >= 0);
assert(startFrame <= endFrame); assert(startTime  <= endTime);

%% Load video & Set output Parameters
%  load video file
try
    vidObj = VideoReader(inName);
catch e
    disp(['Error:' e]);
    vidParams = [];
    return;
end

%  set fields to output parameters
vidParams.FrameRate = vidObj.FrameRate; % framerate
vidParams.BitsPerPixel = vidObj.BitsPerPixel; % bit depth

%  set up start frame number
if startFrame > 0 && startFrame <= vidObj.NumberOfFrames
    vidParams.startFrame = startFrame;
elseif startTime>0 && startTime<=vidObj.NumberOfFrames/vidObj.FrameRate
    vidParams.startFrame = round(startTime * vidObj.FrameRate);
else
    vidParams.startFrame = 1;
end

%  set up end frame number
if endFrame > 0 && endFrame <= vidObj.NumberOfFrames
    vidParams.endFrame = endFrame;
elseif endTime>0 && endTime<=vidObj.NumberOfFrames/vidObj.FrameRate
    vidParams.endFrame = round(endTime * vidObj.FrameRate);
else
    vidParams.endFrame = vidObj.NumberOfFrames;
end

% set up number of frames
vidParams.NumberOfFrames = vidParams.endFrame - ...
                                vidParams.startFrame + 1;

%  set up output video frame size
if outWidth > 0
    vidParams.Width = outWidth;
else
    vidParams.Width = vidObj.Width;
end

if outHeight > 0
    vidParams.Height = outHeight;
else
    vidParams.Height = vidObj.Height;
end

%% Write to output file
switch outFormat
    case 'dat' % output as binary file
    % save video frames
    fp = fopen(outName,'wb');
    for curFrame = vidParams.startFrame : vidParams.endFrame
        frameData = read(vidObj, curFrame); % Read Image Data
        frameData = imresize(frameData,[vidParams.Height vidParams.Width]);
        frameData = permute(frameData, [3 2 1]);
        fwrite(fp, frameData, 'uint8');
    end
    fclose(fp);
    % save audio samples
    if saveAudio
        % parse outName
        [fPath, fName, fExt] = fileparts(outName);
        outAudioName = fullfile(fPath,[fName '-Audio'], fExt);
        
        fp = fopen(outAudioName,'wb');
        % load audio
        [au, fs] = audioread(inName);
        % Compute start pos and end pos
        % I do not use startTime / endTime to compute output audio
        % position, just for sake of video-audio sychronization
        startPos = (vidParams.startFrame - 1) * fs / vidParams.FrameRate;
        endPos   = (vidParams.endFrame - 1) * fs / vidParams.FrameRate;
        % cut audio
        au = au(startPos:endPos,:);
        % write sampling rate
        fprintf(fp,'%d', fs);
        % write samples per channel
        fprintf(fp,'%d', length(au));
        % write audio data
        fwrite(fp,au,'int16');
        fclose(fp);
    end
    
    case 'mat' % output as MATLAB data file
    % save video frame
    inFrameData = read(vidObj, [startFrame endFrame]);
    [M,N,K,~]   = size(inFrameData);
    if outHeight ~= M || outWidth ~= N
        frameData = zeros([outHeight,outWidth,K,vidParams.NumberOfFrames]);
        for curFrame = 1 : vidParams.NumberOfFrames
            frameData(:,:,:,curFrame) = imresize(...
                inFrameData(:,:,:,curFrame),[outHeight outWidth]);
        end
    else
        frameData = inFrameData;
    end
    save tmp.mat frameData vidParams;
    movefile('tmp.mat', outName);
    
     if saveAudio
        % parse outName
        [fPath, fName, fExt] = fileparts(outName);
        outAudioName = fullfile(fPath,[fName '-Audio' fExt]);
        % load audio
        [au, fs] = audioread(inName);
        % cut audio
        startPos = (vidParams.startFrame - 1) * fs / vidParams.FrameRate;
        endPos   = (vidParams.endFrame - 1) * fs / vidParams.FrameRate;
        au = au(startPos:endPos,:);
        % write audio data
        save tmp.mat au fs;
        movefile('tmp.mat', outAudioName);
    end
    
    otherwise
        error('Unknown output type');
end

end
