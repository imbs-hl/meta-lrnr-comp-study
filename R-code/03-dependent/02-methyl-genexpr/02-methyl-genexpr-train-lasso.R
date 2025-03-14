source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_dep_mege_train_lasso <- wrap_batchtools(reg_name = "02-train-lasso",
                                            work_dir = working_dir,
                                            reg_dir = reg_dep_methyl_genexpr,
                                            r_function = single_run_lasso,
                                            vec_args = data.frame(
                                              data_file = dep_methyl_genexpr_param_data$save_path,
                                              seed = dep_methyl_genexpr_param_data$seed,
                                              delta.methyl = dep_methyl_genexpr_param_data$delta.methyl,
                                              delta.expr = dep_methyl_genexpr_param_data$delta.expr,
                                              delta.protein = dep_methyl_genexpr_param_data$delta.protein,
                                              effect = dep_methyl_genexpr_param_data$effect
                                            ),
                                            more_args = list(
                                              num.tree.meta = 1000L
                                            ),
                                            name = "dep-mege-lasso",
                                            overwrite = TRUE,
                                            memory = "25g",
                                            n_cpus = 5,
                                            walltime = "60",
                                            sleep = 5,
                                            partition = "fast", ## Set partition in init-global
                                            account = "p23048", ## Set account in init-global
                                            test_job = FALSE,
                                            wait_for_jobs = FALSE,
                                            packages = c(
                                              "devtools",
                                              "data.table",
                                              "glmnet",
                                              "fuseMLR"
                                            ),
                                            source = c(file.path(function_dir, 
                                                                 "mylasso.R")),
                                            config_file = config_file,
                                            interactive_session = interactive_session)

## Run this after that your jobs are completed
## ----------------------------------------------
## Resume results
## ----------------------------------------------
##
reg_dep_mege_train_lasso <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_methyl_genexpr, "02-train-lasso"),
  writeable = TRUE,
  conf.file = config_file)
reg_dep_mege_train_lasso <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(dep_methyl_genexpr_param_data),
    reg = reg_dep_mege_train_lasso
  ),
  reg = reg_dep_mege_train_lasso)


## resume filtered results
reg_dep_mege_train_lasso_DT <- data.table::rbindlist(reg_dep_mege_train_lasso)
dep_mege_mean_perf_lasso <- reg_dep_mege_train_lasso_DT[ , .(mean_perf = mean(meta_layer)), 
                                                           by = .(perf_measure, effect)]
