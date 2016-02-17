function ff = plot_error_time(t,e,meths,yl,xl,ot)
% function fig = plot_error_time(t,e,meths,ylim,xlim,outtrace)
%
% assumes training times are being plotted
%
% t is array of times
% e is the array of the metric values
% meths is cell of method properties
%   meths(:,6) are legend strings
%   meths(:,7) are plot name/value pairs
% ylim is optional 2-element vector; it represents the limits of the y-axis; 
%   data plot is truncated "smartly"
% xlim is scalar; it represents the max limit of the x-axis;
% if outtrace is provided, then the times for sod_la and sp_dual
%   will be corrected: in the case of no hyp opt, current experimental setup
%   attempts to optimize with la after 
%   initializing, so need to subtract amount of time optimizing. in the case of
%   no hyp opt, sp_?_dual doesn't use the initial varg parameters, so need
%   to subtract inititialization time. 
%   in case of hyp opt, still need to subtract amount of time spent on init. 
%   from sod la and sparse dual, but will need to get input from sod la runs
%   wo/ hyp opt (obtained as ttr-sts)
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

warning off;
ff = figure;
box on;

nmeth = size(e,1);

% correct the times with outtrace?
if(nargin>=6&&~isempty(ot))
    if(iscell(ot)) % outtrace is a cell with each entry a structure
        sts=outtrace_extract(ot,'ts','sum');
        ix=regexpi(meths(:,6),'sod_[a-z]+_la');
        lx=cellfun(@(x) ~isempty(x),ix);
        if(sum(lx)~=1)
            error('did not find single instance of sod_?_la in outtrace');
        end;
        for i = 1:size(t,3)
            t(lx,:,i) = t(lx,:,i) - sts(lx,:,i);
        end;
    elseif(isnumeric(ot))    % only the corrections have been 
                            % supplied (sts sod); 1 x NK x NISS double
        ix=regexpi(meths(:,6),'sod_[a-z]+_la');
        lx=cellfun(@(x) ~isempty(x),ix);
        if(sum(lx)~=1)
            error('did not find single instance of sod_?_la in outtrace');
        end;
        for i = 1:size(t,3)
            t(lx,:,i) = t(lx,:,i) - ot(1,:,i);
        end;
    end;
    % correct khan dual time by subtracting sod la init time
    ix=regexpi(meths(:,6),'sp_[a-z]+_dual');
    lx2=cellfun(@(x) ~isempty(x),ix);
    if(sum(lx2)~=1)
        warning('did not find single instance of sp_?_dual in outtrace');
    else
        for i = 1:size(t,3)
            t(lx2,:,i) = t(lx2,:,i) - t(lx,:,i);
        end;
    end;
end;

% compute stats
mn = mean(e,2);
sd = std(e,[],2);
tmn = mean(t,2);
tsd = std(t,[],2);

% limit y-axis 
if(nargin<4||isempty(yl))
    yl=[-inf,+inf];
end;
mn = squeeze(mn);
mn0 = mn;
lx = mn>yl(2);
mn(lx) = yl(2);
lx = mn<yl(1);
mn(lx) = yl(1);

% limit x-axis 
if(nargin<5||isempty(xl))
    xl=+inf;
end;
tmn = squeeze(tmn);
tmn0 = tmn;
lx = tmn>xl;
tmn(lx) = xl;
tsd(lx) = 0; % assume entire interval [tmn-tsd,tmn+tsd] is outside viewing window

cols = cell(nmeth,1);
for i = 1:nmeth
    h = semilogx(tmn(i,:),mn(i,:),'.-');
    hold on;
    set(h,meths{i,7}{:});
    set(h,'marker','.');
    set(h,'markersize',16);
    cols{i} = get(h,'color');
%    for j = 1:length(tmn(i,:))
%        h = semilogx([-1 1]*tsd(i,j)+tmn(i,j),[1 1]*mn(i,j),'.-');
%        set(h,meths{i,7}{:});
%    end;
end;

xlabel('Ave. Training Time (s)');
ylabel(upper(inputname(2)));

legend(strrep(meths(:,6),'_',' '));

% go back and put triangles where any limiting occurred
mn = mn0;
for i = 1:nmeth
    lx = mn(i,:)>yl(2);
    mn(i,lx) = yl(2);
    h = semilogx(tmn(i,lx),mn(i,lx),'^');
    set(h,'color',cols{i},'markerfacecolor',cols{i});
    %lx = mn<yl(1);
    %mn(lx) = yl(1);
    %sd(lx) = 0; % assume entire interval [mn-sd,mn+sd] is outside viewing window
end;

tmn = tmn0;
for i = 1:nmeth
    lx = tmn(i,:)>xl;
    tmn(i,lx) = xl;
    h = semilogx(tmn(i,lx),mn(i,lx),'>');
    set(h,'color',cols{i},'markerfacecolor',cols{i});
    %lx = mn<yl(1);
    %mn(lx) = yl(1);
    %sd(lx) = 0; % assume entire interval [mn-sd,mn+sd] is outside viewing window
end;

% go back and put larger dot over first subset size to distinguish it
for i = 1:nmeth
    h = semilogx(tmn(i,1),mn(i,1),'.');
    set(h,'color',cols{i});
    set(h,'marker','o');
    set(h,'markersize',10);
%    for j = 1:length(tmn(i,:))
%        h = semilogx([-1 1]*tsd(i,j)+tmn(i,j),[1 1]*mn(i,j),'.-');
%        set(h,meths{i,7}{:});
%    end;
end;

function hh = plot_cross(xmn,xsd,ymn,ysd)

hh = [];
x1 = xmn - xsd;
x2 = xmn + xsd;
y1 = ymn - ysd;
y2 = ymn + ysd;
h = plot(log10([x1 x2]),[1 1]*ymn,'-');
hh = [hh;h];
h = plot(log10([1 1]*xmn),[y1 y2],'-');
hh = [hh;h];
