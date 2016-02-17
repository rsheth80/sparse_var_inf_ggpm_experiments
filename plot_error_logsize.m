function ff = plot_error_logsize(M,e,meths,yl,nosd)
% function fig = plot_error_logsize(M,e,meths,ylim,nosd)
%
% M is vector of pseudo-input sizes
% e is the metric to plot
% meths is cell of method properties
%   meths(:,6) are legend strings
%   meths(:,7) are plot name/value pairs
% ylim is optional 2-element vector; it represents limits of y-axis; data plot 
%   is truncated "smartly"
% nosd is an optional flag to indicate whether error bars are plotted (0: no)
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
ff = figure;
hold on;
box on;
xlabel('Subset/Active Set Size');
ylabel(upper(inputname(2)));

nmeth = size(e,1);
mn = mean(e,2);
if(nargin<5 || nosd)
    sd = std(e,[],2);
else
    sd = zeros(size(mn));
end;

% limit y-axis 
if(nargin<4||isempty(yl))
    yl=[-inf,+inf];
end;
mn = squeeze(mn);
mn0 = mn;
lx = mn>yl(2);
mn(lx) = yl(2);
sd(lx) = 0; % assume entire interval [mn-sd,mn+sd] is outside viewing window
lx = mn<yl(1);
mn(lx) = yl(1);
sd(lx) = 0; % assume entire interval [mn-sd,mn+sd] is outside viewing window

[xt,xtl,xl] = create_x_logscale(M);
jitter = min(abs(diff(xt)))/nmeth*jitter_frac;

cols = cell(nmeth,1);
for i = 1:nmeth
    h = errorbar(log10(M)+jitter*(i-1),mn(i,:),sd(i,:));
    set(h,meths{i,7}{:});
    cols{i} = get(h,'color');
%    set(h,'color',meths{i,6});
%    set(h,'linestyle',meths{i,7});
%    set(h,'marker',meths{i,8});
end;
warning on;

axis([xl ylim]);
set(gca,'xtick',xt);
set(gca,'xticklabel',xtl);

legend(strrep(meths(:,6),'_',' '));

% go back and put triangles where any limiting occurred
mn = mn0;
for i = 1:nmeth
    lx = mn(i,:)>yl(2);
    mn(i,lx) = yl(2);
    h = plot(log10(M(lx))+jitter*(i-1),mn(i,lx),'^');
    set(h,'color',cols{i},'markerfacecolor',cols{i});
    %lx = mn<yl(1);
    %mn(lx) = yl(1);
    %sd(lx) = 0; % assume entire interval [mn-sd,mn+sd] is outside viewing window
end;

function [xt,xl,xa] = create_x_logscale(M,a)

xx = [floor(log10(M(1))) ceil(log10(M(end)))];
xa = [xx(1)-0.1 xx(2)+0.1];
xt = cumsum([xx(1)+log10(1:9)',ones(9,1)*ones(1,xx(2)-2)],2);
if(xx(1)==xx(2))
    xt = [xt(:);xx(1)+1];
else
    if(xx(2)>xt(end))
        xt = [xt(:);xx(2)];
    else
        xt = xt(:);
    end;
end;
ix = find(xt-floor(xt));
xl = num2cell(10.^xt);
for i = 1:length(ix)
    xl{ix(i)}=[];
end;
