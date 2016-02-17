% note: eval_method must include explicit instances of methods which are to be
% evaluated so that matlab compiler will include the methods at compilation, 
% i.e., don't use single quotes for function handles
function [varargout] = eval_method_sod_gpo(DO_HYP,imeth,data0,ixtrain,ixtest,ixtrain_inducing,varargin)
% function [varargout] = eval_method_sod_gpo(DO_HYP,imeth,data0,ixtrain,ixtest,ixtrain_inducing,varargin)
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

    'sod_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
        { ...
            @f_obj_primal_m, opts_m; ...
            @fp_opt, opts_V;
            }, ...
        'sod_gpo_fp', {'color','b', 'linestyle','--', 'marker','n'};...

%    'sod_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
%        { ...
%            @full_var_opt_dm_fpV, {}; ...
%            }, ...
%        'sod_gpo_full', {'color','g', 'linestyle','-', 'marker','n'};...

    'sod_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
        { ...
            @f_obj_primal_m, opts_m; ...
            @f_obj_primal_C, opts_C; ...
            }, ...
        'sod_gpo_grad', {'color','c', 'linestyle','--', 'marker','n'};...

    'sod_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
        { ...
            @f_obj_laplace, opts_la; ...
            }, ...
        'sod_gpo_la', {'color','r', 'linestyle','--', 'marker','n'};...

%    'sod_gpo', models(4), @gen_gp_train, @gen_gp_predict, ...
%        { ...
%            @f_obj_dual_l, opts_ls ...
%            }, ...
%        'sod_gpo_dual', {'color',[0 .5 0], 'linestyle','--', 'marker','n'};...

% remember: comments CANNOT separate fields of a row; otherwise, matlab breaks
% up the row for some weird reason...
};

% if optimizing hyps, add hyp obj func to each method
if(DO_HYP)
    for i = 1:size(meths_cell,1)
        if(isequal(meths_cell{i,5}{1,1},@f_obj_laplace))
            meths_cell{i,5} = [meths_cell{i,5};{@f_obj_laplace_h,opts_h}];
        else
            meths_cell{i,5} = [meths_cell{i,5};{@f_obj_primal_h,opts_h}];
        end;
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
%else % set to true values (should equal generative hyps)
%%    D = size(data0.x,2);
%%    hyps.mean = 3;
%%    hyps.cov = log([sqrt(D)/3,1]);
%%    hyps.lik = [];
%end;

% set up output variables
KK = length(ixtrain);
nout = length(varargin);
varargout = cell(nout,1);
ix_out_train = [];
ix_out_test = [];
for i = 1:nout
    if(ismember(varargin{i},{'params_out','params_init','data','outtrace'}))
        varargout{i} = cell(1,KK);
    else
        varargout{i} = zeros(1,KK); 
    end;
    if(ismember(varargin{i},{'vlb','ttr','params_init','params_out','data',...
        'nfe','params_out','excond','outtrace'}))
        ix_out_train = [ix_out_train,i];
    else
        ix_out_test = [ix_out_test,i];
    end;
end;

% begin training 

% set up training data
data_train0 = get_data_fold(data0,ixtrain{1},ixtest{1});

% perform training and time it
ttr=cputime;
[model,data,params_init] = define_init_model(model,data_train0,hyps,...
    length(ixtrain_inducing{1}),ixtrain_inducing{1});
[params_out,vlb,nfe,excond,outtrace] = feval(ftrain,model,data,params_init,alg);
ttr=cputime-ttr;

nfe = sum(sum(nfe));

% duplicate training output parameters
for kk = 1:KK
    for j = ix_out_train
        if(eval(sprintf('exist(''%s'',''var'')',varargin{j})) ...
            && eval(sprintf('isstruct(%s)',varargin{j}))) % existing structure
            cmd = sprintf('varargout{j}(1,kk) = {%s};', varargin{j});
        else
            cmd = sprintf('varargout{j}(1,kk) = %s;', varargin{j});
        end;
        eval(cmd);
    end;
end;

% end training

% begin testing

fprintf(1,'Testing');
for kk = 1:KK
    fprintf(1,'.');

    % get test data
    [~,data_test] = get_data_fold(data0,ixtrain{kk},ixtest{kk});

    % predict
    tte=cputime;
    oo = ones(size(data_test.xs,1),1);
    xs = (data_test.xs-oo*data.zmu)./(oo*data.zsg);
    datap = feval(fpredict,model,data,params_out,xs);
    tte=cputime-tte;

    % save output
    for j = ix_out_test
        if(strcmp(varargin{j},'tte'))
            varargout{j}(1,kk) = tte;
        else
            % evaluate
            varargout{j}(1,kk) = compute_error_metric(model,data_test,params_out,datap,varargin{j});
        end;
    end;
end;
fprintf(1,'\n');

% end testing

