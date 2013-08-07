function content = cutImgToPix(Img, params)
%% function cutImgToPix
%  Compute image content for each pixelet
%
%  Inputs:
%    Img     - image matrix to be cut
%    params  - paramerters structure, should contain fields: nCols,
%              overlapSize, inputImgSz
%
%  Outputs:
%    content - cell array, each cell contains sliced image content for each
%              pixelets
%  Example:
%    content = cutImgToPix(Img, params)
%
%  See also:
%    setPixContent, calibrationByCamera 
%
%  (HJ) Aug, 2013

%% Check Inputs
if nargin < 1, error('Image to be cut required'); end
if nargin < 2, error('Parameter structure required'); end
if ~isfield(params, 'nCols'), error('Number of pixelets unknown'); end
if ~isfield(params, 'overlapSize'), error('Overlap size unknown'); end
if ~isfield(params, 'inputImgSz'),error('Original Image size unknown'); end

if any(size(Img) ~= params.inputImgSz)
    warning('New Image size is different, will be resized');
    Img = imresize(Img, params.inputImgSz);
end

%% Init
content = cell(nCols,1);
% Compute / store for convenience
M = params.inputImgSz(1); 
N = params.inputImgSz(2);

overlapSize = params.overlapSize;
nonOverlapSize = [M ceil((N - (nCols-1)*overlapSize)/nCols)];

%% Compute content for each pixelets
for curPix = 1 : nCols
    if curPix == 1
        overlapL = 0;
    else
        overlapL = overlapSize;
    end
    colPos = (curPix-1)*(nonOverlapSize(2)+overlapSize)+1;
    % Init image content size
    content{curPix} = Img(:,colPos-overlapL:...
        min(curPix*(nonOverlapSize(2)+overlapSize),N),:);
end