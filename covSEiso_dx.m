function K = covSEiso_dx(hyp, x, z, i, dinput)
% function K = covSEiso_dx(hyp, x, z, i, dinput)
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
    K = covSEiso;
elseif(nargin<2)
    K = covSEiso(hyp);
elseif(nargin<3)
    K = covSEiso(hyp,x);
elseif(nargin<4)
    K = covSEiso(hyp,x,z);
elseif(nargin<5)
    K = covSEiso(hyp,x,z,i);
%     K = K/exp(hyp(i));  % scale by 1/hyperparameter(i) since derivatives are
%                         % are wrt/ log(hyperparameter(i))
else % returns a cell array of matrices 
    K0 = covSEiso(hyp,x,z);
    ell = exp(hyp(1));                                 % characteristic length scale
    if(isempty(z))
        z=x;
    end;
    [~,ix]=ismember(dinput,x,'rows');
    [~,iz]=ismember(dinput,z,'rows');
    dim = size(x,2);
    dK = cell(dim,1);
    for l=1:dim
        dK{l} = sparse(zeros(size(K0)));
    end;
    if(~ix&&~iz)
        K = dK;
        return;
    end;
    if(ix)
        for l=1:dim
            for i=1:length(ix)
                for j=1:size(z,1)
                    dK{l}(ix(i),j) = (-x(ix(i),l)+z(j,l))/ell^2;
                end;
            end;
        end;
    end;
    if(iz)
        for l=1:dim
            for j=1:length(iz)
                for i=1:size(x,1)
                    dK{l}(i,iz(j)) = (-z(iz(j),l)+x(i,l))/ell^2;
                end;
            end;
        end;
    end;
    if(ix&&iz)
        for l=1:dim
            for i=1:length(ix)
                for j=1:length(iz)
                    dK{l}(ix(i),iz(j)) = 0;
                end;
            end;
        end;
    end;
    for l=1:dim
        K{l} = K0.*dK{l};
    end;
end;

