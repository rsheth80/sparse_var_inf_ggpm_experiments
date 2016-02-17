if(~isdeployed)
    % base code path
    code_path = fullfile('~','Dropbox','School','Tufts','Research','code');

    % load GPML toolbox
    gpml_toolbox_ver = 'gpml-matlab-v3.4-2013-11-11';
    addpath( fullfile(code_path,gpml_toolbox_ver) );
    gpml_startup;   % a simple run command cannot be used here because it
                    % requires a path to the startup file which will not be 
                    % known prior to submitting to the Tufts cluster for 
                    % execution

    % minFunc
    minfunc_ver = 'minFunc_2012';
    addpath( fullfile(code_path,minfunc_ver,'minFunc') );
    addpath( fullfile(code_path,minfunc_ver,'minFunc','compiled') );

    % sparse_var_ggpm
    addpath(fullfile(code_path,'sparse_gp_experiments','sparse_var_inf_ggpm'));
    addpath(fullfile(code_path,'sparse_gp_experiments','sparse_var_inf_ggpm',...
        'util'));

    % sparse_var_ggpm dual supplement
    addpath(fullfile(code_path,'sparse_gp_experiments',...
        'sparse_var_inf_ggpm_dual_supp'));
    addpath(fullfile(code_path,'sparse_gp_experiments',...
        'sparse_var_inf_ggpm_dual_supp','util'));

    clear code_path;
    clear gpml_toolbox_ver; 
    clear vgai_toolbox_ver;
    clear minfunc_ver;
    clear OCT; % created during gpml_startup
    clear me;
    clear mydir;
end;
