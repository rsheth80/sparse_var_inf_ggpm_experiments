function x = compute_error_metric(model,data,params,datar,metric)
% function x = compute_error_metric(model,data_test,params,model_data_pred,metric)
%
% 'data_test' assumed to have 'ys' and 'xs' fields
% 'model_data_pred' assumed to have 'y_mean', 'y_var', 'f_mean', and 'v_var'
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

model_ltype = strrep(strrep(model.type,'sod_',''),'sparse_','');

switch(metric)
case 'mae',
    x = mean(abs(datar.y_mean-data.ys));
case 'mse'
    x = mean((datar.y_mean-data.ys).^2);
case 'mpr'
    x = mean((data.ys-datar.y_mean).^2./datar.y_var);
case 'mfe'
    ix_nz = find(data.ys);
    x = mean(abs((data.ys(ix_nz)-datar.y_mean(ix_nz))./data.ys(ix_nz)));
case 'mcn'
    S = 2;
    x = mean(abs(data.ys-datar.y_mean)<=S*sqrt(datar.y_var));
case 'meanzoc'
    ix_z = find(~data.ys);
    if(isempty(ix_z))
        x = 0;
    else
        x = mean(datar.y_mean(ix_z));
    end;
case 'mnlpd'
%    Nq = 20; % number of quadrature points
%    x = calc_evidence_dist(data.ys,datar.f_mean,datar.f_var,Nq);
%    x = mean(-log(x));
    lp = feval(model.lik_func{:},params.hyp.lik,data.ys,datar.f_mean,datar.f_var);
    x = mean(-lp);
case 'merr' 
    switch(model_ltype)
    case 'gpc' % for binary class
        lp = feval(model.lik_func{:},params.hyp.lik,data.ys,datar.f_mean,datar.f_var);
        x = mean(exp(lp)<0.5);
    case 'gpo' % for ordinal
        e = data.ys - round(datar.y_mode); % use most probable categeory
        x = mean(abs(e)>0);
    case 'gppr' % for count, but not used really 
        e = data.ys - round(datar.y_mean); % use most probable categeory
        x = mean(abs(e)>0);
    end;
%    pp_class1 = exp(feval(model.lik_func{:},params.hyp.lik,ones(size(data.ys)),datar.f_mean,datar.f_var));
%    pp_classn1 = 1-pp_class1;
%    ysr(pp_class1>=0.5)=1;
%    ysr(pp_classn1>0.5)=-1;
%    x = sum(abs(data.ys-ysr))/length(data.ys);
otherwise
    fprintf(1,'unknown metric\n');
end;
