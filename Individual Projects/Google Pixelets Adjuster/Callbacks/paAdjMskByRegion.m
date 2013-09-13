function msk = paAdjMskByRegion(curMsk, varargin)
%% function paAdjMskByRegion(curMsk, varargin)
%    This function allows user to adjust a region of mask values
%    interactively. The shape of the mask will be kept the same and the
%    adjustment will be contraint to a scaler
%
%  Input:
%    curMsk   - current mask matrix
%    varargin - not used for now, might be used to accept channel selection
%               input in the future
%
%  Output:
%    msk      - adjusted mask matrix
%
%  See also
%    s_pixeletAdjuster
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('current mask matrix required'); end

%% Select region to adjust
img = curMsk(:,:,1); figure;
imagesc(img); axis off;
try
    selectedRect = round(getrect);
    close(gcf);
catch
    msk = curMsk;
    return;
end
selectedBW = zeros(size(img));

% Constrain Region
lx = max(selectedRect(2), 1);
ly = max(selectedRect(1), 1);
rx = min(selectedRect(2)+selectedRect(4), size(curMsk,1));
ry = min(selectedRect(1)+selectedRect(3), size(curMsk,2));
selectedBW(lx:rx, ly:ry)=1;
selectedBW = selectedBW > 0;

%% Get new values
prompt = {'Enter new avg', 'Smooth X', 'Smooth Y', 'Smooth Std'};
dlg_title = 'Edit Mask';
def = {num2str(mean(img(selectedBW>0))),'50','50','15'};
answer = inputdlg(prompt, dlg_title, 1, def);
if isempty(answer), msk = curMsk; return; end

% Check user inputs
if any(isnan(str2double(answer)))
    warning('Only numeric value accepted!');
    return;
end

% Set and Smooth
smoothParams = str2double(answer(2:4));
img(selectedBW) = img(selectedBW) + ...
    str2double(answer{1})-mean(img(selectedBW));
if all(smoothParams >= 1)
    gaussFilter = fspecial('gaussian',smoothParams(1:2), smoothParams(3));
    img = imfilter(img,gaussFilter,'replicate');
end

msk = repmat(img,[1 1 3]);

end
