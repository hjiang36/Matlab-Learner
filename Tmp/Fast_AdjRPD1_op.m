%% Stats 330 HW 3 - RPD Transform
%   x = Fast_AdjRPD1_op(y, sigma)
%   This function implements the fast adjoint 1D RPD Transform
%
%  Inputs:
%    y          - n-by-1 transformed real vector
%    sigma      - n-by-1 real non-zero control vector
%
%  Outputs;
%    x          - n-by-1 complex vector
%
%  Equation:
%    forward transformation:
%    y = (sign(sigma)+1)/2 .* real(x) - (sign(sigma)-1)/2 .* imag(x)
%
%  (HJ) Nov, 2013

function x = Fast_AdjRPD1_op(y, sigma)
%% Check inputs
if nargin < 1, error('y vector required'); end
if nargin < 2, error('control vector required'); end
assert(all(isreal(y)), 'y should be real vector');
assert(numel(y) == numel(sigma), 'y and sigma should have same length');
y = y(:); sigma = sigma(:); % make them column vector

%% Compute adjoint RPD transform
indx = (sign(sigma)+1)/2;
x = indx .* y + (1-indx) .* y * sqrt(-1);

%% Inverse Fourier transform
x = ifft(x)*sqrt(length(x));

end