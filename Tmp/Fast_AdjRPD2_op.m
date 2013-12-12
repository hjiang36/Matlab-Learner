%% Stats 330 HW 3 - RPD Transform
%   [u,v] = Fast_AdjRPD2_op(y, sigma)
%   This function implements the fast adjoint 2D RPD Transform
%
%  Inputs:
%    y          - n-by-n transformed real matrix
%    sigma      - n-by-n real non-zero control matrix
%
%  Outputs;
%    u,v        - n-by-n complex matrix
%
%  Equation:
%    forward transformation:
%    y(i,j) = real(u(i,j)), if sigma(i,j) = 0
%           = imag(u(i,j)), if sigma(i,j) = 1
%           = real(v(i,j)), if sigma(i,j) = 2
%           = imag(v(i,j)), if sigma(i,j) = 3
%
%  (HJ) Nov, 2013

function [u, v] = Fast_AdjRPD2_op(y, sigma)
%% Check inputs
if nargin < 1, error('y matrix required'); end
if nargin < 2, error('control matrix required'); end
assert(all(isreal(y)), 'y should be real vector');
assert(numel(y) == numel(sigma), 'y and sigma should have same size');

%% Compute adjoint RPD transform
u = y .* (sigma == 0) + sqrt(-1) * y .* (sigma == 1);
v = y .* (sigma == 2) + sqrt(-1) * y .* (sigma == 3);

%% Inverse Fourier transform
u = ifft2(u)*length(u);
v = ifft2(v)*length(v);

end