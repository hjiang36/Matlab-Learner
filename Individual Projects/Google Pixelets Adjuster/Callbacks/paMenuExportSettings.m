function paMenuExportSettings(~, ~)
%% function paMenuExportSettings
%    This is the callback for Menu -> File -> Export Settings. This
%    function saves current pixelets settings to position file
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

%% Save pixelets positions
%  Each line in the output csv file should contain 8 values, srcUlPosX,
%  srcLrPosX, dstUlPosX, dstLrPosX, srcUlPosY, srcLrPosY, dstUlPosY,
%  dstLrPosY
pixeletsPos = zeros(numel(hG.pixelets), 8);
for curPix = 1 : numel(hG.pixelets)
    pix = hG.pixelets{curPix};
    pixeletsPos(curPix, [5 1]) = pixeletGet(pix, 'in ul pos');
    pixeletsPos(curPix, [6 2]) = pixeletGet(pix, 'in lr pos');
    pixeletsPos(curPix, [7 3]) = pixeletGet(pix, 'disp ul pos');
    pixeletsPos(curPix, [8 4]) = pixeletGet(pix, 'disp lr pos');
end

pixPosFileName = fullfile(paRootPath,'Data', 'pixeletsPos.csv');
csvwrite(pixPosFileName, pixeletsPos);

%% Save pixelets mask
[M, N, ~] = size(hG.dispI);
mskImg = zeros(M, N, 3);
for curPix = 1 : numel(hG.pixelets)
    pix = hG.pixelets{curPix};
    pix = pixeletSet(pix, 'image content', ...
                     ones(pixeletGet(pix, 'image content size')));
    mskImg = drawPixelet(mskImg, pix);
end


%% Write to File
for i = 1 : 3
    mskImg(:,:,i) = flipud(mskImg(:,:,i));
end

pixMskFileName = fullfile(paRootPath, 'Data', 'pixeletsMsk.dat');
fp = fopen(pixMskFileName,'wb');
fwrite(fp,permute(mskImg, [3 2 1]),'float');
fclose(fp);

msgbox('Export Successfully','Export Status');
end