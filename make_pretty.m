function make_pretty(fig)
% function make_pretty(fig)
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

TitleSize=14;
XLabelSize=14;
YLabelSize=14;
TickLabelSize=12;
LegendTextSize=14;

h0=get(fig,'children');
for i=1:length(h0)
	if(~strcmp(get(h0(i),'tag'),'legend'))
		h=get(h0(i),'xlabel');
		set(h,'fontsize',XLabelSize,'fontweight','bold');
		h=get(h0(i),'Ylabel');
		set(h,'fontsize',YLabelSize,'fontweight','bold');
		h=get(h0(i),'title');
		set(h,'fontsize',TitleSize,'fontweight','bold');
		set(h0(i),'fontsize',TickLabelSize,'fontweight','bold');
	else
		set(h0(i),'fontsize',LegendTextSize,'fontweight','bold');
	end;
end;

set(fig,'paperposition',[.25 .5 (8.5-1.4) 6*(8.5-1.4)/8]);
