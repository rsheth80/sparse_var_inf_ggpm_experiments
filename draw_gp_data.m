function data = draw_gp_data(T,N,D,model_gen,hyp_gen,SV)
% data = draw_gp_data(T,N,D,model_gen,hyp_gen,SV)
%
% 'N' samples from 'D'-dimensional hypercube with side length 'T'; random 
% sampling (drawn from a uniform distribution on hypercube)
%
% model_gen is a structure with fields type, mean_func and cov_func
% hyp_gen is a structure with fields mean and cov 
%
% observation model determined by model.type:
%   '*_gppr': Poisson with exp(GP) as rate parameter
%   '*_gpprlog': Poisson with log(1+exp(GP)) as rate parameter
%   '*_gpc':  binary class model (y={-1,+1}) with sigma(y*GP) as parameter (prob
%           of class +1), where sigma(.) is logistic sigmoid
%
% output 'data' is a structure with fields 'x', 'y', 'f_true'
%
% SV is optional; if provided, rng will be seeded to it
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


% seed rng, if requested
if(nargin==6 && ~isempty(SV))
    init_rand_seed(SV);
end;

% create features 
data.x = rand(N,D)*T;

% create process mean, covariance
f_mean = feval(model_gen.mean_func{:}, hyp_gen.mean, data.x);
K = feval(model_gen.cov_func{:}, hyp_gen.cov, data.x);

% draw a sample field 
L = chol( K, 'lower' );
data.f_true = L*randn(N,1) + f_mean;

% draw observations 
model_ltype = strrep(strrep(model_gen.type,'sod_',''),'sparse_','');
switch(lower(model_ltype))
case 'gppr'
    data.y = poissrnd(exp(data.f_true));
case 'gpprlog'
    data.y = poissrnd(log(1+exp(data.f_true)));
case 'gpc'
    data.y = -1*ones(N,1);
    lx = logical(binornd(1,sigmoid(data.f_true),N,1));
    data.y(lx) = 1;
%    data.y(data.f_true>0) = 1;
case 'gpo'
    Lcat = length(hyp_gen.lik);
    ptemp.hyp = hyp_gen;
    [phi,a] = ord_disp_hyp(ptemp);
    P = zeros(N,Lcat);
    for ll = 1:Lcat
        P(:,ll) = sigmoid(a*(phi(ll+1)-data.f_true)) ...
            - sigmoid(a*(phi(ll)-data.f_true));
    end;
    pe = [zeros(N,1),cumsum(P,2)];
    u = rand(N,1);
    data.y = zeros(N,1);
    for i = 1:N
        [~,data.y(i)] = histc(u(i),pe(i,:));
    end;
%    [~,data.y] = histc(data.f_true,phi);
case 'gpl'
    stdn = exp(hyp_gen.lik(1));
    data.y = data.f_true + stdn.*randn(size(data.f_true));
end;

% order data if low dimensional
% if data not low dimensional, then sigh...
if(D<2)
    [data.x,ix]=sort(data.x);
    data.y=data.y(ix);
    data.f_true=data.f_true(ix);
end;
