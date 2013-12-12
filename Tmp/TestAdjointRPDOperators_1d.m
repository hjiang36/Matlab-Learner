%%  Stats 330 HW 3 - RPD Transform
%    TestAdjointRPDOperators_1d
%
%  (HJ) Nov, 2013

%% Init parameters
n = 10;
thresh = 0.001;

%% Build Z and W
W = randn(n, 1) + sqrt(-1)* randn(n, 1);
sigma = randn(n, 1);
Z = Fast_RPD1_op(randn(n, 1) + sqrt(-1)* randn(n, 1), sigma);

%% Validate
result(1) = Z'* Fast_RPD1_op(W, sigma) - 1i * Z'*Fast_RPD1_op(1i*W, sigma);
result(2) =  Fast_AdjRPD1_op(Z, sigma)'*W;
fprintf('[Z, RPD(W)]: \t\t%s\n', num2str(result(1)));
fprintf('<AdjRPD(Z), W>: \t%s\n',num2str(result(2)));

if norm(result(1)-result(2)) < thresh
    disp('success');
else
    disp('failure');
end