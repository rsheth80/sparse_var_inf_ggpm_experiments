function x = outtrace_extract(ot,fld,st)
% function x = outtrace_extract(outtrace,field,f_el)
%
% field = {'fs','foocs','mps','ts'.'nfes'}
% f_el = {'end','ave','sum'}
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

[nmeth,nk,niss] = size(ot);
x = zeros(nmeth,nk,niss);

for i = 1:nmeth
    for j = 1:nk
        for k = 1:niss
            if(isstruct(ot{i,j,k}))
                xx = ot{i,j,k}.(fld);
                switch(st)
                case 'end'
                    x(i,j,k) = xx(end);
                case 'ave'
                    x(i,j,k) = mean(xx);
                case 'sum'
                    x(i,j,k) = sum(xx(:));
                otherwise
                    error('unknown operation requested: %s',st);
                end;
            else
                x(i,j,k) = nan;
            end;
        end;
    end;
end;
