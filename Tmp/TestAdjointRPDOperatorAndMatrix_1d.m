%%  Stats 330 HW 3 - RPD Transform
%    TestAdjointRPDOperatorAndMatrix_1d
%
%  (HJ) Nov, 2013

%% build re-ordering handles
vec_to_rmo_1d = @(x) [real(x(:)); imag(x(:))];
rmo_to_vec_1d = @(x) x(1:length(x)/2) + sqrt(-1)*x(length(x)/2+1:end);

%% Init parameters
n = 10;
thresh = 0.001;

%% Build Z, W and A
W = randn(n, 1) + sqrt(-1)* randn(n, 1);
sigma = randn(n, 1);
Z = Fast_RPD1_op(randn(n, 1) + sqrt(-1)* randn(n, 1), sigma);
A = build_RPD1_matrix(sigma);

%% Validate
%  validate [Z, RPD(W)] = <Re-order[A'Z],W>
result(1) = Z'* Fast_RPD1_op(W, sigma) - 1i*Z'*Fast_RPD1_op(1i*W, sigma);
result(2) = rmo_to_vec_1d(A'*Z)'*W;
fprintf('[Z, RPD(W)]: \t\t%s\n', num2str(result(1)));
fprintf('<Re-order[A''Z], W>: \t%s\n', num2str(result(2)));


if norm(result(1)-result(2)) < thresh
    disp('success');
else
    disp('failure');
end

% validate [Z, A[Re-order(W)]]=<AdjRPD(Z),W>
result(3) = Z'*A*vec_to_rmo_1d(W)-1i*Z'*A*vec_to_rmo_1d(1i*W);
result(4) = Fast_AdjRPD1_op(Z, sigma)'*W;

fprintf('[Z, A*Re-order[W]]: \t\t%s\n', num2str(result(3)));
fprintf('<AdjRPD(Z), W>: \t%s\n', num2str(result(4)));


if norm(result(3)-result(4)) < thresh
    disp('success');
else
    disp('failure');
end