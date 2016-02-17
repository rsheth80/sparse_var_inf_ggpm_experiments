function models = define_learning_models
% function models = define_learning_models
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


% define some learning models
models_cell = {

    {@meanConst}, {@covSEiso};
    {@meanZero}, {@covMaternoneiso};
    {@meanZero}, {@covPolytwo};
    {@meanZero}, {@covSEiso};

};
for i = 1:size(models_cell,1)
    models(i).mean_func = models_cell{i,1};
    models(i).cov_func = models_cell{i,2};
end;
