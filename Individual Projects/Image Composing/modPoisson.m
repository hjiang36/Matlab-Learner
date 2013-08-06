% modPoisson reconstructs an image from the gradient feature data.
%
% Y = modPoisson( X, param, ep )
%Output parameters:
% Y: the reconstructed image
%
%
%Input parameters:
% X: the input feature data
% param (optional): the parameters which is generated by buildModPoissonParam
% ep (optional): constraint parameter
%
%
%Example:
% x = double(imread('img.png'));
% y = imGradFeature(x);
% param = buildModPoissonParam( [size(x,1), size(x,2)] );
% X = modPoisson( y, 1E-8, param);
%
%
%Version: 20121212

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified Poisson                                         %
%                                                          %
% Copyright (C) 2012 Masayuki Tanaka. All rights reserved. %
%                    mtanaka@ctrl.titech.ac.jp             %
%                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Y = modPoisson( X, param, ep )

if( nargin < 3 )
 ep = 1E-8;
end

s = [size(X,1), size(X,2), size(X,3)];

if( nargin < 2 )
 param = buildModPoissonParam(s);
else
 sk = size(param);
 if( s(1) ~= sk(1) || s(2) ~= sk(2) )
  param = buildModPoissonParam(s);
 end
end

Fh = ( X(:,:,:,2) + circshift(X(:,:,:,4),[0,-1])) / 2;
Fv = ( X(:,:,:,3) + circshift(X(:,:,:,5),[-1,0])) / 2;
L = circshift(Fh,[0,1]) + circshift(Fv,[1,0]) - Fh - Fv;

Y = zeros(s);
param2 = param .* param;
for i=1:s(3)
 Xdct = dct2(X(:,:,i));
 Ydct = ( param .* dct2(L(:,:,i)) + ep * Xdct  ) ./ (param2 + ep);
 Y(:,:,i) = idct2(Ydct);
end

