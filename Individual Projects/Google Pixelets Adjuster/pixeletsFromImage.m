function pixelets = pixeletsFromImage(Img, nRows, nCols, overlapSize, pixs)
%% function pixeletsFromImage(Img, nRows, nCols, overlapSize)
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
%    pixs        - optional, existing pixelets structure, if given, the
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

%  Check overlap size
if numel(overlapSize) ~= 2
    if numel(overlapSize) == 4
        overlapSize(1) = mean(overlapSize(1:2));
        overlapSize(2) = mean(overlapSize(3:4));
    else
        error('overlap size should be 2 element vector');
    end
end

% Init pixelets cell matrix
pixelets = cell(nRows, nCols);

%% Create pixelets
%  Compute some useful constants
[M, N, ~]   = size(Img);
overlapH    = overlapSize(1); % Horizontal overlap size
overlapV    = overlapSize(2); % Vertical overlap size
nonOverlapH = ceil((N - (nCols-1)*overlapH) / nCols);
nonOverlapV = ceil((M - (nRows-1)*overlapV) / nRows);

for curRow = 1 : nRows
    for curCol = 1 : nCols
        % Compute position in source image
        
        % Set content
        
        % Compute position in display image
        
        % Generate mask
    end
end

end