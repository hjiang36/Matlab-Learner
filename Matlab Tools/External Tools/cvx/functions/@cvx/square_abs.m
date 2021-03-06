function cvx_optval = square_abs( x )

%SQUARE_ABS   Internal cvx version.

error( nargchk( 1, 1, nargin ) ); %#ok
cvx_optval = pow_abs( x, 2 );

% Copyright 2012 CVX Research, Inc. 
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
