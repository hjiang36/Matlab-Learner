%% Stats 330 HW 3 - RPD Transform
%   y = Fast_RPD2_op(u, v, sigma)
%   
%  This function implements the fast 2D RPD Transform
%  Inputs:
%    u, v       - n-by-n complex matrix
%    sigma      - n-by-n real non-zero control matrix, values can be 0~3
%
%  Outputs;
%    y          - n-by-n transformed real matrix
%
%  Equation:
%    y(i,j) = real(u(i,j)), if sigma(i,j) = 0
%           = imag(u(i,j)), if sigma(i,j) = 1
%           = real(v(i,j)), if sigma(i,j) = 2
%           = imag(v(i,j)), if sigma(i,j) = 3
%
%  (HJ) Nov, 2013

function y = Fast_RPD2_op(u, v, sigma)
%% Check inputs
if nargin < 2, error('u and v matrix required'); end
if nargin < 3, error('control matrix required'); end
assert(all(size(u) == size(v) & size(u) == size(sigma)), ...
            'u, v and sigma should have same size');
assert(size(u,1) == size(u,2), 'u, v should be square matrix');

%% Fourier transform
u = fft2(u)/length(u);
v = fft2(v)/length(v);

%% Compute RPD transform
y = real(u) .* (sigma == 0) + imag(u) .* (sigma == 1) + ...
    real(v) .* (sigma == 2) + imag(v) .* (sigma == 3);

end