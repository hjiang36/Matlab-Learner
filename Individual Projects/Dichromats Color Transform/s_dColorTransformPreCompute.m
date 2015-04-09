%% s_dColorTransformPreCompute
%    This function is used to pre-compute and store the transformation
%    look-up table for dichromatic observers
%
%    The pre-computed dichromatic color transform is based on convex
%    optimzation problem with non-negative constraints (dColorTransform).
%    In that problem set-up, we can sample from 0 to 1 and scale it up
%    later. This helps to simplify the look-up table greatly.
%
% (HJ) ISETBIO TEAM, 2015

%% Init
ieInit;   % initialize a new isetbio session
N = 128; % number of sample poitns

%% Compute for Protanopia
%  Protanopia does not have L cones and we just need to make up M and S
dLMS = zeros(N ,3);
dLMS(:, 2) = linspace(0, 1, N);
dLMS(:, 3) = 1 - dLMS(:, 2);

%  Transform and find L
tic; L = dColorTransform(dLMS, 1); toc;
L = L(:, 1);

% There might be some infeasible cases, we just ignore them and set them to
% zeros
L(isnan(L)) = 0;

%% Compute for Deuteranopia
%  Deuteranopia does not have M cones and we just need to make up L and S
dLMS = zeros(N ,3);
dLMS(:, 1) = linspace(0, 1, N);
dLMS(:, 3) = 1 - dLMS(:, 1);

%  Transform and find L
tic; M = dColorTransform(dLMS, 2); toc;
M = M(:, 2); M(isnan(M)) = 0;

%% Compute for Tritanopia
%  Tritanopia does not have S cones and we just need to make up L and M
dLMS = zeros(N ,3);
dLMS(:, 1) = linspace(0, 1, N);
dLMS(:, 2) = 1 - dLMS(:, 1);

%  Transform and find L
tic; S = dColorTransform(dLMS, 3); toc;
S = S(:, 3); S(isnan(S)) = 0;

%% Save
save dColorTransformPre.mat L M S