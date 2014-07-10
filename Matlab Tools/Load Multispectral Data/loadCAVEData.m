function caveData = loadCAVEData(from, to)
%% Load multi-spectral image dataset (CAVE) into matlab
%    loadCAVEData(fName)
%
%  Inputs:
%    from  - root path to the folder containing CAVE data
%    to    - folder of output data to be saved to, default - from
%
%  Outputs:
%    caveData - structure array, contains:
%               .wave - wavelength of samples
%               .reflectance - m x n x nwave, reflectance data
%               .sRGB - sRGB image rendered under d65
%  
%  Notes:
%    The CAVE multispectral image database can be downloaded from:
%      http://www.cs.columbia.edu/CAVE/databases/multispectral/
%
%  (HJ) July, 2014

%% Init
if notDefined('from'), error('CAVE root folder path required'); end
if notDefined('to'), to = []; end
assert(exist(from, 'dir')==7, 'from should be a folder path')
if ~isempty(to)
    assert(exist(to, 'dir')==7, 'to should be a folder');
end

wave = 400 : 10 : 700; % wavelength

%% Load reflectance and sRGB image
dirName = dir(from);
sRGB = cell(length(dirName), 1);
reflectance = cell(length(dirName), 1);
outName = cell(length(dirName), 1);
imageCount  = 0;

for ii = 3 : length(dirName)
    if ~dirName(ii).isdir, continue; end
    imageCount = imageCount + 1;
    reflectance{imageCount} = zeros(512, 512, length(wave));
    
    % Print debug info
    fprintf('Loading multi-spectral file: %s...', dirName(ii).name)
    
    % Set name
    outName{imageCount} = dirName(ii).name;
    
    % Load reflectance
    folderPath = fullfile(from, dirName(ii).name, dirName(ii).name);
    for jj = 1 : length(wave)
        imgName = fullfile(folderPath, ...
            [dirName(ii).name '_' sprintf('%02d', jj) '.png']);
        I = im2double(imread(imgName));
        if ndims(I) == 3, I = rgb2gray(I); end
        reflectance{imageCount}(:,:,jj) = I;
    end
    
    % Load sRGB
    imgName = fullfile(folderPath, ...
        [dirName(ii).name(1:end-3) '_RGB.bmp']);
    sRGB{imageCount} = im2double(imread(imgName));
    
    if ~isempty(to)
        fName = fullfile(to, [dirName(ii).name '.mat']);
        caveData.wave = wave(:);
        caveData.reflectance = reflectance{imageCount};
        caveData.sRGB = sRGB{imageCount};
        save(fName, 'caveData');
    end
    
    fprintf('Done!\n');
end
reflectance = reflectance(1:imageCount);
sRGB = sRGB(1:imageCount);
outName = outName(1:imageCount);

%% Create matlab structure and save to file
if nargout > 0
caveData = struct('wave', wave(:), ...
                  'reflectance', reflectance, ...
                  'sRGB', sRGB, ...
                  'name', outName);
end