function pixelets = pixeletsFromImage(Img, nRows, nCols, ...
                                      overlapSize, gapSize, pixelets)
%% function pixeletsFromImage(Img, nRows, nCols, overlapSize, gapSize)
%    This function creates a cell matrix of pixelets structures from an
%    input image. The image get replicated defined by overlapSize and get
%    cut into nRows-by-nCols
%
%  Inputs:
%    Img         - input image matrix
%    nRows       - number of rows of pixelets
%    nCols       - number of columns of pixelets
%    overlapSize - overlapSize, should be a vector with 2 elements,
%                  representing [left / right, up / down] overlap size,
%                  assuming that left and right overlap size are the same,
%                  up and down overlap size are the same also
%    gapSize     - black gap size, should be a vector with 2 elemenets,
%                  representing horizontal and vertical black gap size
%    pixelets    - optional, existing pixelets structure, if given, the
%                  diplay and mask information will be inheritated from
%                  there
%
%  Output:
%    pixelets    - nRows-by-nCols pixelets cell matrix, each cell contains
%                  a created pixelet structure
%
%  Example:
%    Img = im2double(imread('google.jpg'));
%    pixelets = pixeletFromImage(Img, 3, 1, [20 20 0 0]);
%
%  See also
%    pixeletSet
%
%  (HJ) Sep, 2013

%% Check inputs & Init
%  Check number of inputs
if nargin < 1, error('Input source image required'); end
if nargin < 2, error('Number of rows required'); end
if nargin < 3, error('Number of columns required'); end
if nargin < 4, error('Overlap size required'); end
if nargin < 5, error('Black gap size required'); end
if nargin < 6 || isempty(pixelets)
    % Init pixelets matrix as empty cell array
    pixelets = cell(nRows, nCols);
else
    % Validate the input pixelets
    assert(all(size(pixelets) == [nRows nCols]), ...
        'Inputs pixelets dimension mis-matched');
end

%  Check overlap size
if numel(overlapSize) ~= 2
    if numel(overlapSize) == 4
        overlapSize(1) = mean(overlapSize(1:2));
        overlapSize(2) = mean(overlapSize(3:4));
    else
        error('overlap size should be 2 element vector');
    end
end



%% Create pixelets
%  Compute some useful constants
[M, N, ~]   = size(Img);
overlapH    = overlapSize(1); % Horizontal overlap size
overlapV    = overlapSize(2); % Vertical overlap size
nonOverlapH = ceil((N - (nCols-1)*overlapH) / nCols);
nonOverlapV = ceil((M - (nRows-1)*overlapV) / nRows);

for curRow = 1 : nRows
    % Compute row position in source image
    srcUlY = (curRow - 1)*(nonOverlapV + overlapV) + 1;
    srcLrY = curRow * (nonOverlapV + overlapV);
    if curRow > 1, srcUlY = srcUlY - overlapV; end
    if curRow == nRows, srcLrY = srcLrY - overlapV; end
    for curCol = 1 : nCols
        % Get current pixelet in pixelets matrix
        pix = pixelets{curRow, curCol};
        
        % Compute column position in source image
        srcUlX = (curCol -1)*(nonOverlapH + overlapH) + 1;
        srcLrX = curCol * (nonOverlapH + overlapH);
        if curCol > 1, srcUlX = srcUlX - overlapH; end
        if curCol == nCols, srcLrX = srcLrX - overlapH; end
        srcLrX = min(srcLrX, N); srcLrY = min(srcLrY, M);
        
        % Set position & content
        pix.imgContent = Img(srcUlY : srcLrY, srcUlX : srcLrX, :);
        pix.srcUl = [srcUlY srcUlX];
        pix.srcLr = [srcLrY srcLrX];
        
        % Compute position in display image
        if isempty(pixeletGet(pix, 'disp ul pos'))
            pix.dispPos = pix.srcUl + [curRow-1 curCol-1].*gapSize;
            pix.dispSize = pix.srcLr - pix.srcUl + 1;
        end
        
        
        % Generate mask
        if isempty(pixeletGet(pix, 'msk'))
            pix.msk = genBlurMsk([overlapH overlapH overlapV overlapV], ...
                           pix.dispSize);      
        end
        
        if any(size(pix.msk) ~= size(pix.imgContent))
            pix.msk = imresize(pix.msk, pix.dispSize);
        end
        
        % Set overlap and blur size parameters
        pix.overlapL = overlapH; pix.overlapR = overlapH;
        pix.overlapU = overlapV; pix.overlapD = overlapV;
        
        pix.blurL = overlapH; pix.blurR = overlapH;
        pix.blurU = overlapV; pix.blurD = overlapV;
        
        % Compute disp image
        pix.dispImg = imresize(pix.imgContent .* pix.msk, pix.dispSize);
        
        % Save to pixelets matrix
        pixelets{curRow, curCol} = pix;
    end
end

end