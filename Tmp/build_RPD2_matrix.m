%% Stats 330 HW 3 - RPD Transform
%   A = build_RPD2_matrix(sigma)
%   This function builds transformation matrix for 2D RPD tranformation
%
%  Inputs:
%    sigma      - n-by-1 real non-zero control vector
%
%  Outputs;
%    A          - tranformation matrix for y = Ax
%
%  Equation:
%    y = A_{sigma}*x
%
%  Notes:
%    Here, we generate real matrix A with 4n^2 columns. This implementation
%    corresponds to x with first all real parts of u and then all imaginary
%    parts of u, next real parts of v and imaginary parts of v
%
%  (HJ) Nov, 2013

function A = build_RPD2_matrix(sigma)
%% Check inputs
if nargin < 1, error('control matrix sigma required'); end
assert(size(sigma,1) == size(sigma,2), 'sigma should be square matrix');

%% Build A
N = length(sigma);
sigma = sigma(:);
A = [diag(sigma==0) diag(sigma==1) diag(sigma==2) diag(sigma==3)];

%% Add fourier transform
fft2_vec = zeros(2*N^2);
[L, K]   = meshgrid((0:N-1)/N, (0:N-1)/N);
for n = 0 : N-1
    for m = 0 : N-1
        tmp = -2*pi*(n*L+m*K); tmp = tmp(:)';
        fft2_vec(n*N+m+1,:) = [cos(tmp) -sin(tmp)];
        fft2_vec(n*N+m+1+N^2, :) = [sin(tmp) cos(tmp)];
    end
end
fft2_vec = fft2_vec / N;
A = A * [fft2_vec zeros(2*N^2); zeros(2*N^2) fft2_vec];