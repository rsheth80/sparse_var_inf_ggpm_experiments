function A = meanConst_dx(hyp, x, i, dinput)
% function A = meanConst_dx(hyp, x, i, dinput)
%
% Copyright (C) 2016  Rishit Sheth

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>. fields

if(nargin<1)
    A = meanConst;
elseif(nargin<2)
    A = meanConst(hyp);
elseif(nargin<3)
    A = meanConst(hyp,x);
elseif(nargin<4)
    A = meanConst(hyp,x,i);
else % returns an array the size of x
    A = zeros(size(x));
end;
