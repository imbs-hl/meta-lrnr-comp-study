source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_methyl_train_wa <- wrap_batchtools(reg_name = "train-wa",
                                    work_dir = working_dir,
                                    reg_dir = reg_indep_methyl,
                                    r_function = single_run_wa,
                                    vec_args = data.frame(
                                      data_file = indep_methyl_param_data$save_path,
                                      seed = indep_methyl_param_data$seed,
                                      delta.methyl = indep_methyl_param_data$delta.methyl,
                                      delta.expr = indep_methyl_param_data$delta.expr,
                                      delta.protein = indep_methyl_param_data$delta.protein,
                                      effect = indep_methyl_param_data$effect
                                    ),
                                    more_args = list(
                                      num.tree.meta = 1000L
                                    ),
                                    name = "methyl-wa",
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
reg_methyl_train_wa <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_methyl, "train-wa"), writeable = TRUE,
  conf.file = config_file)
reg_methyl_train_wa <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_methy_param_data),
    reg = reg_methyl_train_wa
  ),
  reg = reg_methyl_train_wa)


## resume filtered results
reg_methyl_train_wa_DT <- data.table::rbindlist(reg_methyl_train_wa)
methyl_mean_perf_wa <- reg_methyl_train_wa_DT[ , .(mean_perf = mean(meta_layer)), 
                                         by = .(perf_measure, effect)]
