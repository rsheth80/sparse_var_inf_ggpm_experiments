% note: eval_method must include explicit instances of methods which are to be
% evaluated so that matlab compiler will include the methods at compilation, 
% i.e., don't use single quotes for function handles
function [varargout] = eval_method_sparse_gpo(DO_HYP,imeth,data_train,data_test,ix_inducing,varargin)
% function [varargout] = eval_method_sparse_gpo(DO_HYP,imeth,data_train,data_test,ix_inducing,varargin)
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
models = define_learning_models;

% define options to pass to minFunc
define_minfunc_options;

% define methods/models that are tested
% columns: 
% 1. string of model type
% 2. structure of gp model 
% 3. handle of training function
% 4. handle of prediction function
% 5. structure of optimization algorithm options
% 6. string of legend text
% 7. cell of plotting name/value pairs
meths_cell = {

    'sparse_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
        { ...
            @f_obj_primal_m, opts_m; ...
            @fp_opt, opts_V;
            }, ...
        'sp_gpo_fp', {'color','b', 'linestyle','-', 'marker','n'};...

%    'sparse_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
%        { ...
%            @full_var_opt_dm_fpV, {}; ...
%            }, ...
%        'sp_gpo_full', {'color','g', 'linestyle','-', 'marker','n'};...

    'sparse_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
        { ...
            @f_obj_primal_m, opts_m; ...
            @f_obj_primal_C, opts_C; ...
            }, ...
        'sp_gpo_grad', {'color','c', 'linestyle','-', 'marker','n'};...
        
%    'sparse_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
%        { ...
%            @f_obj_dual_l, opts_ls ...
%            }, ...
%        'sp_gpo_dual', {'color',[0 .5 0], 'linestyle','-', 'marker','n'};...
        
% remember: comments CANNOT separate fields of a row; otherwise, matlab breaks
% up the row for some weird reason...
};

% if optimizing hyps, add hyp obj func to each method
if(DO_HYP)
    for i = 1:size(meths_cell,1)
        meths_cell{i,5} = [meths_cell{i,5};{@f_obj_primal_h,opts_h}];
    end;
end;

if(nargin==1)
    varargout{1} = size(meths_cell,1); % number of methods to evaluate
    if(nargout > 1)
        varargout{2} = meths_cell;
    end;
    return;
end;

% set up local variables
model = meths_cell{imeth,2};
model.type = meths_cell{imeth,1};
ftrain = meths_cell{imeth,3};
fpredict = meths_cell{imeth,4};
alg = meths_cell{imeth,5};

% define likelihood function
% am assuming user knows how many true categories exist in the data
model.lik_func = {@likCumLog,5}; 
%model.lik_func = {@likCumLog,10}; 

model.Lcat = model.lik_func{2};

% initialize hyps
hyps = [];
%if(DO_HYP)
%    hyps = [];
%else % set to true values (should equal generative hyps)
%%    D = size(data0.x,2);
%%    hyps.mean = 3;
%%    hyps.cov = log([sqrt(D)/3,1]);
%%    hyps.lik = [];
%end;

%hyps.mean = [];
%D = 10;
%hyps.cov = log([sqrt(D)/3;1]);
%hyps.lik = [-1;log([[1;1;1]*2/3;40])];

% train
ttr=cputime;
[model,data,params_init] = define_init_model(model,data_train,hyps,...
    length(ix_inducing),ix_inducing);
[params_out,vlb,nfe,excond,outtrace] = feval(ftrain,model,data,params_init,alg);
ttr=cputime-ttr;

% predict 
tte=cputime;
oo = ones(size(data_test.xs,1),1);
xs = (data_test.xs-oo*data.zmu)./(oo*data.zsg);
datap = feval(fpredict,model,data,params_out,xs);
tte=cputime-tte;

n = length(varargin);
varargout = cell(n,1);

for j = 1:n
    if(strcmp(varargin{j},'vlb'))
        varargout{j} = vlb;
    elseif(strcmp(varargin{j},'ttr'))
        varargout{j} = ttr;
    elseif(strcmp(varargin{j},'tte'))
        varargout{j} = tte;
    elseif(strcmp(varargin{j},'params_out'))
        varargout{j} = params_out;
    elseif(strcmp(varargin{j},'params_init'))
        varargout{j} = params_init;
    elseif(strcmp(varargin{j},'data'))
        varargout{j} = data;
    elseif(strcmp(varargin{j},'nfe'))
        varargout{j} = sum(sum(nfe));
    elseif(strcmp(varargin{j},'excond'))
        varargout{j} = excond;
    elseif(strcmp(varargin{j},'outtrace'))
        varargout{j} = {outtrace};
    else
        % evaluate
        varargout{j} = compute_error_metric(model,data_test,params_out,datap,varargin{j});
    end;
end;

