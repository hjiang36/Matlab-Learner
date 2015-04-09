function armaData = simulateARMA(ar, ma, sigma, sz)
% Generate samples for ARMA model
%  armaData = simulateARMA(ar, ma, sigma, sz)
%
%    This function generate samples for ARMA model
%    It is similar to function simulate in economics toolbox
%    We implement a simple version of that for speed and for those without
%    that toolbox
%
%  Inputs:
%    ar    - vector, containing auto-regressive coefficients
%    ma    - vector, containing moving average coefficients
%    simga - scalar, standard deviation of generation noise
%    sz    - size, could be [rows, cols, nFrames]
%
%  Outputs:
%
%
%  See also:
%    arima, estimate, simulate
%
%  (HJ) ISETBIO TEAM, 2014

%% Check inputs
if ~exist('ar', 'var'), error('ar coefficients required'); end
if ~exist('ma', 'var'), error('ma coefficients required'); end
if ~exist('sigma', 'var'), error('std of noise required'); end
if ~exist('sz', 'var'), error('simulation size (nFrames) required'); end

if ~isscalar(sigma), error('std of noise should be a scalar'); end
sz = padarray(sz(:), [3-numel(sz) 0], 1, 'pre')';

%% Generate noise
% will throw away first 20 more samples to avoid initial problems
sz(3) = sz(3) + 20;
wt = randn(sz) * sigma;
armaData = wt;

for t = 2 : sz(3)
    % auto-regressive part
    indx = 1 : min(length(ar), t - 1);
    indx = reshape(indx, [1 1 length(indx)]);
    if ~isempty(indx)
        arSum = sum(bsxfun(@times, ar(indx), armaData(:,:,t-indx(:))), 3);
        armaData(:,:,t) = armaData(:,:,t) + arSum;
    end
    
    % moving average part
    indx = 1 : min(length(ma), t - 1);
    indx = reshape(indx, [1 1 length(indx)]);
    if ~isempty(indx)
        maSum = sum(bsxfun(@times, ma(indx), wt(:,:,t-indx(:))), 3);
        armaData(:,:,t) = armaData(:,:,t) + maSum;
    end
end

% throw away the first 20 samples
armaData = armaData(:,:, 21:end);

end