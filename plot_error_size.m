function plot_error_size(M,e,meths)
%
% M is vector of pseudo-input sizes
% e is the metric to plot
% meths is cell of method properties
%   meths(:,5) are legend strings
%   meths(:,6) are colors
%   meths(:,7) are line styles
%   meths(:,8) are markers 
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

jitter_frac = 1;

warning off;
figure;
hold on;
box on;
xlabel('Subset/Inducing set size');
ylabel(inputname(2));

nmeth = size(e,1);
mn = mean(e,2);
sd = std(e,[],2);
jitter = min(abs(diff(M)))/nmeth*jitter_frac;

for i = 1:nmeth
    h = errorbar(M+jitter*(i-1),mn(i,:),sd(i,:));
    set(h,'color',meths{i,6});
    set(h,'linestyle',meths{i,7});
    set(h,'marker',meths{i,8});
end;
warning on;

legend(strrep(meths(:,5),'_',' '));
