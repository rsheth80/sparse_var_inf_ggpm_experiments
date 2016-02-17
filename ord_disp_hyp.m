function [phi,a] = ord_disp_hyp(p)
% function [phi,a] = ord_disp_hyp(p)
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

hyp = p.hyp.lik;
phi = cumsum([hyp(1);exp(hyp(2:end-1));]);
phi = [-Inf;phi;Inf];
a = exp(hyp(end));

if(~nargout)
    phi'
end;
