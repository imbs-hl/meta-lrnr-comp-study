source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------

reg_mege_dep_missunbalanced_na_keep <- wrap_batchtools(reg_name = "02-train-srf-na-keep",
                                                    work_dir = working_dir,
                                                    reg_dir = reg_dep_missunbalanced_mege,
                                                    r_function = single_run_srf,
                                                    vec_args = data.frame(
                                                      data_file = indep_missunbalanced_mege_param_data,
                                                      seed = indep_missunbalanced_mege_param_data,
                                                      delta.methyl = indep_missunbalanced_mege_param_data,
                                                      delta.expr = indep_missunbalanced_mege_param_data,
                                                      delta.protein = indep_missunbalanced_mege_param_data,
                                                      effect = indep_missunbalanced_mege_param_data
                                                    ),
                                                    more_args = list(na_action = "na.learn",
                                                                     num.tree.boruta = 25000L,
                                                                     num.tree.ranger = 5000L),
                                                    name = "missunb-mege-srf-na-keep",
                                                    overwrite = TRUE,
                                                    memory = "25g",
                                                    n_cpus = 6,
                                                    walltime = "0",
                                                    sleep = 5,
                                                    partition = "batch", ## Set partition in init-global
                                                    account = "dzhk-omics", ## Set account in init-global
                                                    test_job = FALSE,
                                                    wait_for_jobs = FALSE,
                                                    packages = c(
                                                      "devtools",
                                                      "data.table",
                                                      "mgcv",
                                                      "Boruta",
                                                      "ranger"
                                                    ),
                                                    config_file = config_file,
                                                    interactive_session = interactive_session)

## Run this after that your jobs are completed
## ----------------------------------------------
## Resume results
## ----------------------------------------------
##
reg_dep_missunbalanced_mege_srf_na_keep <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_missunbalanced_me,
                       "02-train-srf-na-keep"),
  writeable = TRUE,
  conf.file = config_file)
reg_dep_missunbalanced_mege_srf_na_keep <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_missunbalanced_mege_param_data),
    reg = reg_dep_missunbalanced_mege_srf_na_keep
  ),
  reg = reg_dep_missunbalanced_mege_srf_na_keep)


## resume filtered results 
res_dep_missunbalanced_mege_srf_na_keep <- data.table::rbindlist(reg_dep_missunbalanced_mege_srf_na_keep)
res_dep_missunbalanced_mege_mean_perf_srf_na_keep <- res_dep_missunbalanced_mege_srf_na_keep[ , .(mean_perf = mean(predictions)), # Check this again whether I called it predictions 
                                                                                      by = .(perf_measure, effect)]
print(res_dep_missunbalanced_mege_mean_perf_srf_na_keep)
res_dep_missunbalanced_mege_mean_perf_srf_na_keep$Setting <- "Dependent"
res_dep_missunbalanced_mege_mean_perf_srf_na_keep$Y_Distribution <- "Balanced"
res_dep_missunbalanced_mege_mean_perf_srf_na_keep$Na_action <- "na.keep"
res_dep_missunbalanced_mege_mean_perf_srf_na_keep$DE <- "DE: MeGe"
res_dep_missunbalanced_mege_mean_perf_srf_na_keep$Meta_learner <- "SRF"
saveRDS(
  object = res_dep_missunbalanced_mege_mean_perf_srf_na_keep,
  file = file.path(res_dep_mege,
                   "res_dep_missunbalanced_mege_mean_perf_srf_na_keep.rds")
)

