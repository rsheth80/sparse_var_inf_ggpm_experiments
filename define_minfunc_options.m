function define_minfunc_options
% function define_minfunc_options
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


opts_def = { ...
    'display', 'off', ...
};
opts_m = { opts_def{:}, 'method', 'newton' };
opts_C = { opts_def{:}, 'method', 'lbfgs' };
opts_V = { opts_def{:} };
opts_h = { opts_def{:}, 'method', 'lbfgs' };
opts_ls ={ opts_def{:}, 'method', 'lbfgs', 'stepfunc', @dual_max_step_func };
opts_la = { opts_def{:}, 'method', 'newton' };
l_opts = whos('opts_*');
for i = 1:length(l_opts)
    cmd = sprintf('x = struct(%s{:});', l_opts(i).name, l_opts(i).name);
    eval(cmd);
    assignin('caller',l_opts(i).name,x);
end;
