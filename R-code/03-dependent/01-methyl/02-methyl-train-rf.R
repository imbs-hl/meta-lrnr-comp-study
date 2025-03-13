source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_dep_me_train_rf <- wrap_batchtools(reg_name = "train-rf",
                                    work_dir = working_dir,
                                    reg_dir = reg_dep_methyl,
                                    r_function = single_run_rf,
                                    vec_args = data.frame(
                                      data_file = dep_methyl_param_data$save_path,
                                      seed = dep_methyl_param_data$seed,
                                      delta.methyl = dep_methyl_param_data$delta.methyl,
                                      delta.expr = dep_methyl_param_data$delta.expr,
                                      delta.protein = dep_methyl_param_data$delta.protein,
                                      effect = dep_methyl_param_data$effect
                                    ),
                                    more_args = list(
                                      num.tree.meta = 1000L
                                    ),
                                    name = "dep_me-rf",
                                    overwrite = TRUE,
                                    memory = "25g",
                                    n_cpus = 5,
                                    walltime = "60",
                                    sleep = 5,
                                    partition = "batch", ## Set partition in init-global
                                    account = "p23048", ## Set account in init-global
                                    test_job = FALSE,
                                    wait_for_jobs = FALSE,
                                    packages = c(
                                      "devtools",
                                      "data.table",
                                      "mgcv",
                                      "fuseMLR"
                                    ),
                                    config_file = config_file,
                                    interactive_session = interactive_session)

## Run this after that your jobs are completed
## ----------------------------------------------
## Resume results
## ----------------------------------------------
##
reg_dep_me_train_rf <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_me, "train-rf"), writeable = TRUE,
  conf.file = config_file)
reg_dep_me_train_rf <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_methy_param_data),
    reg = reg_dep_me_train_rf
  ),
  reg = reg_dep_me_train_rf)


## resume filtered results
reg_dep_me_train_rf_DT <- data.table::rbindlist(reg_dep_me_train_rf)
methyl_mean_perf_rf <- reg_dep_me_train_rf_DT[ , .(mean_perf = mean(meta_layer)), 
                                         by = .(perf_measure, effect)]
