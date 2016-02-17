% the experiment below is mostly straightforward; the code generates the data
% for a learning curve where the x-axis is inducing set size and a number of 
% performance metrics are calculated for the y-axis; each independent point on
% the x-axis represents the average of NK CV runs each representing K of K+1 
% CV folds; the reason for the K of K+1 CV methodology is as follows:
%
% the inducing set is kept the same across all folds performed at a given
% inducing set size to keep the CV variance at that size from being so large as
% to obscure the method's performance; but, doing this automatically destroys
% one fold of a normal K-fold CV run since K independent test sets across the
% data set will no longer be possible (e.g., for a data set size of 1000 and an
% inducing set size of 50, it is no longer possible to find 10 independent test 
% sets of size 100); therefore, we perform K of K+1 CV to account for the fact
% that one fold has been lost; the effect of creating K+1 folds is to decrease
% the size of the test set; this approach preserves interpretability, i.e., NK*K
% folds are still being averaged together; setting K equal to a divisible of 
% N-Ninducing ensures all the data in the data set is used;
%
% note: it turns out that this is exactly what I was doing in the previous 
% version of this program
%
% this version is specific for experiments on SoD methods since: it trains once
% for a given subset size and tests K*NK times
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

function sod_exp_gpc

DO_HYP = 0;

% load data
fn = 'class_dataset_usps35_N1540_D256.mat';
%fn = 'class_dataset_yeast_N1484_D8.mat';
%fn = 'class_dataset_winew_N4898_D11.mat';
%fn = 'class_dataset_musk_N6598_D166.mat';
%fn = 'class_dataset_madelon_N2600_D500.mat';
datadir = fullfile('..',filesep,'data');
load(fullfile(datadir,fn));
N = length(data0.y);

% experiment parameters
SV = 1;                     % RNG seed value
num_learning_pts = 10;
min_sod_size = ceil(N/100);
max_sod_size = min(1000,floor(N*.5));
ISS = round(logspace(log10(min_sod_size),log10(max_sod_size),num_learning_pts));   % inducing set sizes
K = 10;                     % num folds for K of K+1 fold CV
NK = 1;                     % num averaging runs per data set (same 
                            %   pseudo-inputs, diff CV folds)
NISS = length(ISS);

% method and output metrics
[NM,meths] = eval_method_sod_gpc(DO_HYP);
mae = zeros(NM,K*NK,NISS);
mse = zeros(NM,K*NK,NISS);
mpr = zeros(NM,K*NK,NISS);
mfe = zeros(NM,K*NK,NISS);
vlb = zeros(NM,K*NK,NISS);
mz = zeros(NM,K*NK,NISS);
mcn = zeros(NM,K*NK,NISS);
ttr = zeros(NM,K*NK,NISS);
tte = zeros(NM,K*NK,NISS);
nfe = zeros(NM,K*NK,NISS);
mnlpd = zeros(NM,K*NK,NISS);
excond = zeros(NM,K*NK,NISS);
merr = zeros(NM,K*NK,NISS);
outtrace = cell(NM,K*NK,NISS);

% specify results file name
mfname = mfilename;
if(DO_HYP)
    mfname = [mfname,'_h'];
end;
fn_output = sprintf('%s_%s_output_%s.mat',mfname,strrep(fn,'.mat',''),...
    datestr(now,'mmddyy_HHMMSS'));

% initialize rng
init_rand_seed(SV);

% run experiment
ixpseudo = random_sample(ISS(end),N);

% begin cluster_block
for ixiss = 1:NISS % loop over inducing set size (training set size for SoD)
    % keep (initial) inducing set same for all methods, all folds, all averages
    Ninducing = ISS(ixiss);
    ix_inducing = ixpseudo(1:Ninducing);
    ix_rest = setdiff((1:N)',ix_inducing);

    % set up training, test, and inducing set indices 
    ixtrain0 = cell(1,NK*K);
    ixtest0 = cell(1,NK*K);
    ixtrain_inducing0 = cell(1,NK*K);
    for nk = 1:NK % loop over CV averaging run
        k0 = (nk-1)*K;
        [ixtrain,ixtest] = mycvpartition(N-Ninducing,K,ix_rest);
        for k = 1:K % loop over CV fold
            kk = k + k0;
            % create training/test indices for this fold adding back inducing 
            % inputs
            this_ix_train = [ixtrain{k};ix_inducing];
            % 'eval_method' expects 'ix_inducing' to reference the *training* 
            % set
            n_ix_train = length(this_ix_train);
            ix_train_inducing = (n_ix_train-Ninducing+1):n_ix_train;
            % store
            ixtrain0{kk} = this_ix_train;
            ixtest0{kk} = ixtest{k};
            ixtrain_inducing0{kk} = ix_train_inducing;
        end;
    end;

    % evaluate
    for nm = 1:NM % loop over methods
        fprintf(1,'ixiss=[%d/%d]\n',ixiss,NISS);
        % begin cluster_function
        [ ...
            mae(nm,:,ixiss),...
            mse(nm,:,ixiss),...
            mpr(nm,:,ixiss),...
            mfe(nm,:,ixiss),...
            mz(nm,:,ixiss),...
            mcn(nm,:,ixiss),...
            mnlpd(nm,:,ixiss),...
            vlb(nm,:,ixiss),...
            ttr(nm,:,ixiss),...
            tte(nm,:,ixiss),...
            nfe(nm,:,ixiss),...
            excond(nm,:,ixiss),...
            merr(nm,:,ixiss),...
            outtrace(nm,:,ixiss),...
        ] = eval_method_sod_gpc(DO_HYP,nm,data0,ixtrain0,ixtest0,ixtrain_inducing0,...
            'mae','mse','mpr','mfe','meanzoc','mcn','mnlpd','vlb',...
            'ttr','tte','nfe','excond','merr','outtrace');
        % end cluster_function
    end;
end;
% end cluster_block

clear data_test data_train data0;
save(fn_output,'-v6');
fprintf(1,'Output saved to %s\n',fn_output);
