%% Stats 330 HW 3 - RPD Transform
%   A = build_RPD1_matrix(sigma)
%   This function builds transformation matrix for 1D RPD tranformation
%
%  Inputs:
%    sigma      - n-by-1 real non-zero control vector
%
%  Outputs;
%    A          - tranformation matrix for y = Ax
%
%  Equation:
%    y = (sign(sigma)+1)/2 .* real(x) - (sign(sigma)-1)/2 .* imag(x)
%    y = A_{sigma}*x
%
%  Notes:
%    Here, we generate real matrix A with 2n columns. This implementation
%    corresponds to x with first all real parts and then all imaginary
%    parts
%
%  (HJ) Nov, 2013

function A = build_RPD1_matrix(sigma)
%% Check inputs
if nargin < 1, error('control matrix sigma required'); end

%% Build A
indx = (sign(sigma) + 1) / 2;
A = [diag(indx) diag(1-indx)];

%% Add fft matrix into A
n = length(sigma);
fftM = fft(eye(n))/sqrt(n);
fftM_vec = [real(fftM) -imag(fftM); imag(fftM) real(fftM)];

% Merge to A
A = A * fftM_vec;

end