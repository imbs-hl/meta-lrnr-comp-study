source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------
reg_me_indep_missunbalanced_na_keep <- wrap_batchtools(reg_name = "02-train-rf-na-keep",
                                                     work_dir = working_dir,
                                                     reg_dir = reg_indep_missunbalanced_me,
                                                     r_function = single_run_rf,
                                                     vec_args = data.frame(
                                                       data_file = indep_missunbalanced_me_param_data$save_path,
                                                       seed = indep_missunbalanced_me_param_data$seed,
                                                       delta.methyl = indep_missunbalanced_me_param_data$delta.methyl,
                                                       delta.expr = indep_missunbalanced_me_param_data$delta.expr,
                                                       delta.protein = indep_missunbalanced_me_param_data$delta.protein,
                                                       effect = indep_missunbalanced_me_param_data$effect
                                                     ),
                                                     more_args = list(na_action = "na.keep",
                                                                      num.tree.meta = 1000L),
                                                     name = "missunb-me-rf-na-keep",
                                                     overwrite = FALSE,
                                                     memory = "25g",
                                                     n_cpus = 6,
                                                     walltime = "60",
                                                     sleep = 5,
                                                     partition = "prio", ## Set partition in init-global
                                                     account = "dzhk-omics", ## Set account in init-global
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
reg_indep_missunbalanced_me_rf_na_keep <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_missunbalanced_me, "02-train-rf-na-keep"),
  writeable = TRUE,
  conf.file = config_file)
reg_indep_missunbalanced_me_rf_na_keep <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_missunbalanced_me_param_data),
    reg = reg_indep_missunbalanced_me_rf_na_keep
  ),
  reg = reg_indep_missunbalanced_me_rf_na_keep)


## resume filtered results
res_indep_missunbalanced_me_rf_na_keep <- data.table::rbindlist(reg_indep_missunbalanced_me_rf_na_keep)
res_indep_missunbalanced_me_mean_perf_rf_na_keep <- res_indep_missunbalanced_me_rf_na_keep[ , .(mean_perf = mean(meta_layer)), 
                                                                                              by = .(perf_measure, effect)]
print(res_indep_missunbalanced_me_mean_perf_rf_na_keep)
res_indep_missunbalanced_me_mean_perf_rf_na_keep$Setting <- "Independent"
res_indep_missunbalanced_me_mean_perf_rf_na_keep$Y_Distribution <- "Unbalanced"
res_indep_missunbalanced_me_mean_perf_rf_na_keep$Na_action <- "na.keep"
res_indep_missunbalanced_me_mean_perf_rf_na_keep$DE <- "DE: Me"
res_indep_missunbalanced_me_mean_perf_rf_na_keep$Meta_learner <- "Random forests"
saveRDS(
  object = res_indep_missunbalanced_me_mean_perf_rf_na_keep,
  file = file.path(res_indep_me,
                   "res_indep_missunbalanced_me_mean_perf_rf_na_keep.rds")
)



## -----------------------------------------------------------------------------
## na_action = na_impute
## -----------------------------------------------------------------------------
reg_me_indep_missunbalanced_na_impute <- wrap_batchtools(reg_name = "02-train-rf-na-imp",
                                                       work_dir = working_dir,
                                                       reg_dir = reg_indep_missunbalanced_me,
                                                       r_function = single_run_rf,
                                                       vec_args = data.frame(
                                                         data_file = indep_missunbalanced_me_param_data$save_path,
                                                         seed = indep_missunbalanced_me_param_data$seed,
                                                         delta.methyl = indep_missunbalanced_me_param_data$delta.methyl,
                                                         delta.expr = indep_missunbalanced_me_param_data$delta.expr,
                                                         delta.protein = indep_missunbalanced_me_param_data$delta.protein,
                                                         effect = indep_missunbalanced_me_param_data$effect
                                                       ),
                                                       more_args = list(na_action = "na.impute"),
                                                       name = "missb-me-rf-na-impute",
                                                       overwrite = TRUE,
                                                       memory = "25g",
                                                       n_cpus = 6,
                                                       walltime = "60",
                                                       sleep = 5,
                                                       partition = "prio", ## Set partition in init-global
                                                       account = "dzhk-omics", ## Set account in init-global
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
reg_indep_missunbalanced_me_rf_na_impute <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_missunbalanced_me, "02-train-rf-na-imp"),
  writeable = TRUE,
  conf.file = config_file)
reg_indep_missunbalanced_me_rf_na_impute <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_missunbalanced_me_param_data),
    reg = reg_indep_missunbalanced_me_rf_na_impute
  ),
  reg = reg_indep_missunbalanced_me_rf_na_impute)


## resume filtered results
res_indep_missunbalanced_me_rf_na_impute <- data.table::rbindlist(reg_indep_missunbalanced_me_rf_na_impute)
res_indep_missunbalanced_me_mean_perf_rf_na_impute <- res_indep_missunbalanced_me_rf_na_impute[ , .(mean_perf = mean(meta_layer)), 
                                                                                                  by = .(perf_measure, effect)]
print(res_indep_missunbalanced_me_mean_perf_rf_na_impute)
res_indep_missunbalanced_me_mean_perf_rf_na_impute$Setting <- "Independent"
res_indep_missunbalanced_me_mean_perf_rf_na_impute$Y_Distribution <- "Unbalanced"
res_indep_missunbalanced_me_mean_perf_rf_na_impute$Na_action <- "na.impute"
res_indep_missunbalanced_me_mean_perf_rf_na_impute$DE <- "DE: Me"
res_indep_missunbalanced_me_mean_perf_rf_na_impute$Meta_learner <- "Random forests"
saveRDS(
  object = res_indep_missunbalanced_me_mean_perf_rf_na_impute,
  file = file.path(res_indep_me,
                   "res_indep_missunbalanced_me_mean_perf_rf_na_impute.rds")
)