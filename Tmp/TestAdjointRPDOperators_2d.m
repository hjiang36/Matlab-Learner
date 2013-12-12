%%  Stats 330 HW 3 - RPD Transform
%    TestAdjointRPDOperators_2d
%
%  (HJ) Nov, 2013

%% Init parameters
n = 10;
thresh = 0.001;

%% Build U,V and W
U = randn(n) + sqrt(-1)* randn(n);
V = randn(n) + sqrt(-1)* randn(n);
sigma = floor(rand(n)*4);
Z = Fast_RPD2_op(randn(n) + sqrt(-1)* randn(n), ...
                    randn(n) + sqrt(-1)* randn(n), sigma);

%% Validate
result(1) = sum(sum(Z .* Fast_RPD2_op(U, V, sigma))) - ...
                1i * sum(sum(Z .* Fast_RPD2_op(U*1i, V*1i, sigma)));
[uOut, vOut] = Fast_AdjRPD2_op(Z, sigma);
result(2) =  sum(sum(conj(uOut).*U + conj(vOut).*V));
fprintf('[Z, RPD(U,V)]: \t\t%s\n', num2str(result(1)));
fprintf('<AdjRPD(Z), (U,V)>: \t%s\n',num2str(result(2)));

if norm(result(1)-result(2)) < thresh
    disp('success');
else
    disp('failure');
end