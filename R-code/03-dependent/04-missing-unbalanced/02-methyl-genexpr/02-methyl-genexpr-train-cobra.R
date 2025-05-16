source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------
reg_mege_dep_missunbalanced_na_keep <- wrap_batchtools(reg_name = "02-train-cobra-na-keep",
                                                     work_dir = working_dir,
                                                     reg_dir = reg_dep_missunbalanced_mege,
                                                     r_function = single_run_cobra,
                                                     vec_args = data.frame(
                                                       data_file = dep_missunbalanced_mege_param_data$save_path,
                                                       seed = dep_missunbalanced_mege_param_data$seed,
                                                       delta.methyl = dep_missunbalanced_mege_param_data$delta.methyl,
                                                       delta.expr = dep_missunbalanced_mege_param_data$delta.expr,
                                                       delta.protein = dep_missunbalanced_mege_param_data$delta.protein,
                                                       effect = dep_missunbalanced_mege_param_data$effect
                                                     ),
                                                     more_args = list(na_action = "na.keep"),
                                                     name = "missunb-mege-cobra-na-keep",
                                                     overwrite = FALSE,
                                                     memory = "25g",
                                                     n_cpus = 5,
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
reg_dep_missunbalanced_mege_cobra_na_keep <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_missunbalanced_mege, "02-train-cobra-na-keep"),
  writeable = TRUE,
  conf.file = config_file)
reg_dep_missunbalanced_mege_cobra_na_keep <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(dep_missunbalanced_mege_param_data),
    reg = reg_dep_missunbalanced_mege_cobra_na_keep
  ),
  reg = reg_dep_missunbalanced_mege_cobra_na_keep)


## resume filtered results
res_dep_missunbalanced_mege_cobra_na_keep <- data.table::rbindlist(reg_dep_missunbalanced_mege_cobra_na_keep)
res_dep_missunbalanced_mege_mean_perf_cobra_na_keep <- res_dep_missunbalanced_mege_cobra_na_keep[ , .(mean_perf = mean(meta_layer)), 
                                                                                              by = .(perf_measure, effect)]
print(res_dep_missunbalanced_mege_mean_perf_cobra_na_keep)
res_dep_missunbalanced_mege_mean_perf_cobra_na_keep$Setting <- "Dependent"
res_dep_missunbalanced_mege_mean_perf_cobra_na_keep$Y_Distribution <- "Unbalanced"
res_dep_missunbalanced_mege_mean_perf_cobra_na_keep$Na_action <- "na.keep"
res_dep_missunbalanced_mege_mean_perf_cobra_na_keep$DE <- "DE: MeGe"
res_dep_missunbalanced_mege_mean_perf_cobra_na_keep$Meta_learner <- "COBRA"
saveRDS(
  object = res_dep_missunbalanced_mege_mean_perf_cobra_na_keep,
  file = file.path(res_dep_mege,
                   "res_dep_missunbalanced_mege_mean_perf_cobra_na_keep.rds")
)



## -----------------------------------------------------------------------------
## na_action = na_impute
## -----------------------------------------------------------------------------
reg_mege_dep_missunbalanced_na_impute <- wrap_batchtools(reg_name = "02-train-cobra-na-imp",
                                                       work_dir = working_dir,
                                                       reg_dir = reg_dep_missunbalanced_mege,
                                                       r_function = single_run_cobra,
                                                       vec_args = data.frame(
                                                         data_file = dep_missunbalanced_mege_param_data$save_path,
                                                         seed = dep_missunbalanced_mege_param_data$seed,
                                                         delta.methyl = dep_missunbalanced_mege_param_data$delta.methyl,
                                                         delta.expr = dep_missunbalanced_mege_param_data$delta.expr,
                                                         delta.protein = dep_missunbalanced_mege_param_data$delta.protein,
                                                         effect = dep_missunbalanced_mege_param_data$effect
                                                       ),
                                                       more_args = list(na_action = "na.impute"),
                                                       name = "missunb-mege-cobra-na-impute",
                                                       overwrite = TRUE,
                                                       memory = "25g",
                                                       n_cpus = 5,
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
reg_dep_missunbalanced_mege_cobra_na_impute <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_missunbalanced_mege, "02-train-cobra-na-imp"),
  writeable = TRUE,
  conf.file = config_file)
reg_dep_missunbalanced_mege_cobra_na_impute <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(dep_missunbalanced_mege_param_data),
    reg = reg_dep_missunbalanced_mege_cobra_na_impute
  ),
  reg = reg_dep_missunbalanced_mege_cobra_na_impute)


## resume filtered results
res_dep_missunbalanced_mege_cobra_na_impute <- data.table::rbindlist(reg_dep_missunbalanced_mege_cobra_na_impute)
res_dep_missunbalanced_mege_mean_perf_cobra_na_impute <- res_dep_missunbalanced_mege_cobra_na_impute[ , .(mean_perf = mean(meta_layer)), 
                                                                                                  by = .(perf_measure, effect)]
print(res_dep_missunbalanced_mege_mean_perf_cobra_na_impute)
res_dep_missunbalanced_mege_mean_perf_cobra_na_impute$Setting <- "Dependent"
res_dep_missunbalanced_mege_mean_perf_cobra_na_impute$Y_Distribution <- "Unbalanced"
res_dep_missunbalanced_mege_mean_perf_cobra_na_impute$Na_action <- "na.keep"
res_dep_missunbalanced_mege_mean_perf_cobra_na_impute$DE <- "DE: MeGe"
res_dep_missunbalanced_mege_mean_perf_cobra_na_impute$Meta_learner <- "COBRA"
saveRDS(
  object = res_dep_missunbalanced_mege_mean_perf_cobra_na_impute,
  file = file.path(res_dep_mege,
                   "res_dep_missunbalanced_mege_mean_perf_cobra_na_impute.rds")
)
