function paMenuImportSettings(~, ~)
%% function paMenuImportSettings
%    This is the callback for Menu -> File -> Import Settings. This
%    function loads current pixelets settings from position file
%    pixeletsPos.csv and pixeletsMsk.dat in folder
%    $PIXELET_ADJUSTER_ROOT/Data/
%  
%  See also:
%    s_pixeletAdjuster
%
%  (HJ) Sep, 2013

%% Get pixelet adjuster graph handle
hG = paGetHandler();
if isempty(hG), error('pixelet adjuster window not found'); end

%% Load pixelets positions
%  Get positions
%  pixPosFileName = fullfile(paRootPath,'Data', 'pixeletsPos.csv');
[pixPosName, pathName]  = uigetfile({'*.csv','CSV'},'Select Pos File');
pixPosFileName = fullfile(pathName, pixPosName);
pixeletsPos    = csvread(pixPosFileName);

assert(size(pixeletsPos, 1) == numel(hG.pixelets), ...
       'number of pixeletes mismatched');

%  Set positions
for curPix = 1 : numel(hG.pixelets)
    pix = hG.pixelets{curPix};
    % set position in source image
    pix.srcUl = pixeletsPos(curPix, [5 1]);
    pix.srcLr = pixeletsPos(curPix, [6 2]);
    
    % update image content
    pix.imgContent = hG.inputImg(pix.srcUl(1) : pix.srcLr(1), ...
                                 pix.srcUl(2) : pix.srcLr(2), :);
    
    % set display size
    pix = pixeletSet(pix, 'ul pos', pixeletsPos(curPix, [7 3]));
    pix.dispSize = pixeletsPos(curPix, [8 4]) - pixeletsPos(curPix, [7 3]);
    
    hG.pixelets{curPix} = pix;
end

%% Load mask data
%  Get whole mask data
% pixMskFileName = fullfile(paRootPath, 'Data', 'pixeletsMsk.dat');
[pixMskName, pathName]  = uigetfile({'*.dat','DAT'}, 'Select Mask File');
pixMskFileName = fullfile(pathName, pixMskName);
fp = fopen(pixMskFileName,'rb');
warning('Should change mskImg data size to be flexible ASAP');
mskImg = fread(fp, 3*600*600, 'float'); % should have a way to know mask size
fclose(fp);
mskImg = permute(reshape(mskImg, [3 600 600]), [3 2 1]);
for i = 1 : 3
    mskImg(:,:,i) = flipud(mskImg(:,:,i));
end

%  Cut and set to each pixelet
for curPix = 1 : numel(hG.pixelets)
    pix = hG.pixelets{curPix};
    ulPos = pixeletGet(pix, 'ul pos');
    lrPos = pixeletGet(pix, 'lr pos');
    imgContentSz = pixeletGet(pix, 'image content size');
    pix.msk = imresize(mskImg(ulPos(1):lrPos(1), ulPos(2):lrPos(2), :), ...
                       imgContentSz(1:2));
    pix = pixeletSet(pix, 'msk', pix.msk); % Just for setting dispImg
    hG.pixelets{curPix} = pix;
end

%% Refresh pixelet adjuster image content
hG.dispI = refreshPixelets(hG);
setappdata(hG.fig, 'handles', hG);

end