function val = ellipseGet(eCoef, param)
%% function ellipseGet
%    Compute parameters of ellipse
%
%  Inputs:
%    eCoef      - 5-by-1 vector, indicating estimated coefficient for
%                 ellipses in form: ax^2+by^2+cxy+dx+ey+1 = 0
%    param      - string, indicating parameter names
%
%  Outputs:
%    val        - computed value for parameter
%
%  Supported Parameters:
%    Center     - center of ellipse
%    AxDir      - major axis direction
%    MajorAxLen - major axis length
%    MinorAxLen - minor axis length
%
% Example:
%    c = ellipseGet(ellipse,'Center');
%
% Note:
%    not all parameters supported in this version
%
% (HJ) July, 2013

%% Check inputs
if nargin < 1, error('Ellipse should be specified'); end
if nargin < 2, error('Parameter name should be specified'); end

if length(eCoef) ~= 5, error('unrecognized ellipse structure'); end

%% Compute parameters
switch lower(param)
    case 'center'
        sc = eCoef(3)^2 - 4*eCoef(1)*eCoef(2);
        val(1) = (2*eCoef(2)*eCoef(4)-eCoef(3)*eCoef(5))/sc;
        val(2) = (2*eCoef(1)*eCoef(5)-eCoef(3)*eCoef(4))/sc;
    case 'axdir'
    otherwise
        warning('Unsupported parameter name found!');
end

end

%% Interesting function adopted from fitellipse.m
function [z, a, b, alpha] = conic2parametric(A, bv, c)
% Diagonalise A - find Q, D such at A = Q' * D * Q
[Q, D] = eig(A);
Q = Q';

% If the determinant < 0, it's not an ellipse
if prod(diag(D)) <= 0 
    error('fitellipse:NotEllipse', 'Linear fit did not produce an ellipse');
end

% We have b_h' = 2 * t' * A + b'
t = -0.5 * (A \ bv);

c_h = t' * A * t + bv' * t + c;

z = t;
a = sqrt(-c_h / D(1,1));
b = sqrt(-c_h / D(2,2));
alpha = atan2(Q(1,2), Q(1,1));
end % conic2parametric