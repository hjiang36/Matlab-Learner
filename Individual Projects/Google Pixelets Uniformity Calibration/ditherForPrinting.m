function dithered_I = ditherForPrinting(I,dispPixelSize,printDotSize,isShow)
%% Function ditherForPrinting
%  Convert gray level image to dithered black and white half-toned image
%
%  Inputs:
%    I              - gray level image, auto-convert to gray for rgb input
%    dispPixelSize  - display pixel size, in um
%    printDotSize   - printer dot size, in um
%    isShow         - indicating whether to show the dithered plot
%
%  Outputs:
%    dithered_I     - BW, half-toned image
%
%  Example:
%    dithered_I = ditherForPrinting(I)
%
%  Written by HJ
%  July, 2013

%% Check Inputs
if nargin < 1, error('Input image required'); end
if nargin < 2, dispPixelSize = 250; end
if nargin < 3, printDotSize = 50; end
if nargin < 4, isShow = false; end

I = im2double(I); % Convert to double in 0~1
if size(I,3)==3, I = rgb2gray(I); end

%% Up-Sample Image
%  Bicubic interpolation is used here, feel free to change it to other
%  methods. Maybe we should use 'nearest' here to avoid introducing
%  blurring in this step
[M,N]  = size(I);
scales = dispPixelSize / printDotSize;

[Xq,Yq] = meshgrid(linspace(1,N,round(N*scales)),...
                   linspace(1,M,round(M*scales)));
upSampledI = interp2(I,Xq,Yq,'cubic');
                   
%% Half-tonning
dithered_I = dither(upSampledI);

%% Show Plot
if isShow
    imshow(dithered_I);
end

