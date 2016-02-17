function doplots(fn_mat,fn_corrections_mat,yl,xl,ixx);
% function doplots(fn_mat,fn_corrections_mat,yl,xl,ixx);
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


if(nargin<2||isempty(fn_corrections_mat))
    fn_corrections_mat = fn_mat;
end;
if(nargin<3)
    yl = [];
end;
if(nargin<4)
    xl = [];
end;

load(fn_mat);
%meths = change_dashes(meths);
fn_base = strrep(fn_mat,'.mat','');

if(nargin<5)
    ixx = 1:size(meths,1);
end;

% plot logsize vs performance metric
if(strfind(fn_mat,'gppr'))
    metric = mfe;
    ylstr = 'MFE';
else
    metric = merr;
    ylstr = 'MZE';
end;
ff = plot_error_logsize(ISS,metric(ixx,:,:),meths(ixx,:,:),yl);
if(~isempty(yl))
    r = axis;
    axis([r(1:2) yl]);
end;
r = axis;
h = legend;
delete(h);
ylabel(ylstr);

feps = [fn_base,'_size_',ylstr,'.eps'];
myprinteps(ff,feps);

% plot logtime vs performance metric
sts = get_corrections(fn_corrections_mat);
ff = plot_error_time(ttr(ixx,:,:),metric(ixx,:,:),meths(ixx,:,:),r(3:4),xl,sts);
r1 = axis;
axis([r1(1:2) r(3:4)]);
h = legend;
delete(h);
ylabel(ylstr);

feps = [fn_base,'_time_',ylstr,'.eps'];
myprinteps(ff,feps);

% plot logsize vs mnlpd
metric = mnlpd;
ylstr = 'MNLPD';
ff = plot_error_logsize(ISS,metric(ixx,:,:),meths(ixx,:,:));
r2 = axis;
axis([r(1:2) r2(3:4)]);
h = legend;
delete(h);
ylabel(ylstr);

feps = [fn_base,'_size_',ylstr,'.eps'];
myprinteps(ff,feps);

function meths = change_dashes(meths)

for i = 1:size(meths,1)
    ix = strmatch('linestyle',meths{i,7}(1:2:end));
    if(strcmp(meths{i,7}{(ix-1)*2+2},'--'))
        meths{i,7}{(ix-1)*2+2} = ':';
    end;
end;

function sts = get_corrections(fn)

load(fn);

sts=outtrace_extract(outtrace,'ts','sum');
ix=regexpi(meths(:,6),'sod_[a-z]+_la');
lx=cellfun(@(x) ~isempty(x),ix);
if(sum(lx)~=1)
    error('did not find single instance of sod_?_la in outtrace');
end;
sts = sts(lx,:,:);
%for i = 1:size(t,3)
%    t(lx,:,i) = t(lx,:,i) - sts(lx,:,i);
%end;
