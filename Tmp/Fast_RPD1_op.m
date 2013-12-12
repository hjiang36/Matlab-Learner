%% Stats 330 HW 3 - RPD Transform
%   y = Fast_RPD1_op(x, sigma)
%   
%  This function implements the fast 1D RPD Transform
%  Inputs:
%    x          - n-by-1 complex vector
%    sigma      - n-by-1 real non-zero control vector
%
%  Outputs;
%    y          - n-by-1 transformed real vector
%
%  Equation:
%    y = (sign(sigma)+1)/2 .* real(x) - (sign(sigma)-1)/2 .* imag(x)
%
%  (HJ) Nov, 2013

function y = Fast_RPD1_op(x, sigma)
%% Check inputs
if nargin < 1, error('x vector required'); end
if nargin < 2, error('control vector required'); end
assert(numel(x) == numel(sigma), 'x and sigma should have same length');
x = x(:); sigma = sigma(:); % make them column vector

%% Fourier transform
x = fft(x)/sqrt(length(x));

%% Compute RPD Transform
indx = (sign(sigma)+1)/2;
y = indx .* real(x) + (1-indx) .* imag(x);

end