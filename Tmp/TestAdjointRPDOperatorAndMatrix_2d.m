%%  Stats 330 HW 3 - RPD Transform
%    TestAdjointRPDOperatorAndMatrix_2d
%
%  (HJ) Nov, 2013

function ret =  TestAdjointRPDOperatorAndMatrix_2d
%% Init parameters
n = 10;
thresh = 0.001;

%% Build Z, W and A
U = randn(n) + sqrt(-1)* randn(n);
V = randn(n) + sqrt(-1)* randn(n);
sigma = floor(rand(n)*4);
Z = Fast_RPD2_op(randn(n) + sqrt(-1)* randn(n), ...
                    randn(n) + sqrt(-1)* randn(n), sigma);
A = build_RPD2_matrix(sigma);

%% Validate
%  validate [Z, RPD(U,V)] = <Re-order[A'Z],W>
result(1) = sum(sum(Z .* Fast_RPD2_op(U, V, sigma))) - ...
               1i* sum(sum(Z .* Fast_RPD2_op(U*1i,V*1i,sigma)));
[uOut, vOut] = vec_to_rmo_2d(A'*Z(:));
result(2) = sum(sum(conj(uOut).*U + conj(vOut).*V));
fprintf('[Z, RPD(U,V)]: \t\t%s\n', num2str(result(1)));
fprintf('<Re-order[A''Z], (U, V)>: \t%s\n', num2str(result(2)));

ret(1) = (norm(result(1)-result(2)) < thresh);

% validate [Z, A[Re-order(W)]]=<AdjRPD(Z),W>
result(3) = Z(:)'*A*rmo_to_vec_2d(U, V) - ...
                1i*Z(:)'*A*rmo_to_vec_2d(U*1i, V*1i);
[uOut, vOut] = Fast_AdjRPD2_op(Z, sigma);
result(4) = sum(sum(conj(uOut).*U + conj(vOut).*V));

fprintf('[Z, A*Re-order[W]]: \t\t%s\n', num2str(result(3)));
fprintf('<AdjRPD(Z), W>: \t%s\n', num2str(result(4)));

ret(2) =  (norm(result(3)-result(4)) < thresh);

end

%% Vector to matrix representation
function [U, V] = vec_to_rmo_2d(x)
N = round(length(x)/4);
n = round(sqrt(N));
U = reshape(x(1:N) + sqrt(-1)* x(N+1:2*N), n, n);
V = reshape(x(2*N+1:3*N) + sqrt(-1)*x(3*N+1:4*N), n, n);
end

%% Matrix to vector representation
function x = rmo_to_vec_2d(U, V)
U = U(:); V = V(:);
x = [real(U); imag(U); real(V); imag(V)];
end