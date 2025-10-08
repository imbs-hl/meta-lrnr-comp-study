source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------

reg_mege_indep_missbalanced_na_keep <- wrap_batchtools(reg_name = "02-train-diablo-na-keep-test",
                                                    work_dir = working_dir,
                                                    reg_dir = reg_indep_missbalanced_mege,
                                                    r_function = single_run_diablo,
                                                    vec_args = data.frame(
                                                      data_file = indep_missbalanced_mege_param_data[400, ]$save_path,
                                                      seed = indep_missbalanced_mege_param_data[400, ]$seed,
                                                      delta.methyl = indep_missbalanced_mege_param_data[400, ]$delta.methyl,
                                                      delta.expr = indep_missbalanced_mege_param_data[400, ]$delta.expr,
                                                      delta.protein = indep_missbalanced_mege_param_data[400, ]$delta.protein,
                                                      effect = indep_missbalanced_mege_param_data[400, ]$effect
                                                    ),
                                                    more_args = list(na_action = "na.keep"),
                                                    name = "comb-mege-diablo-na-keep",
                                                    overwrite = TRUE,
                                                    memory = "25g",
                                                    n_cpus = 6,
                                                    walltime = "60",
                                                    sleep = 5,
                                                    partition = "fast", ## Set partition in init-global
                                                    account = "dzhk-omics", ## Set account in init-global
                                                    test_job = FALSE,
                                                    wait_for_jobs = FALSE,
                                                    packages = c(
                                                      "devtools",
                                                      "data.table",
                                                      "mgcv",
                                                      "Boruta",
                                                      "mixOmics",
                                                      "ranger"
                                                    ),
                                                    config_file = config_file,
                                                    interactive_session = interactive_session)

## Run this after that your jobs are completed
## ----------------------------------------------
## Resume results
## ----------------------------------------------
##
reg_indep_missbalanced_mege_diablo_na_keep <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_missbalanced_mege,
                       "02-train-diablo-na-keep-test"),
  writeable = TRUE,
  conf.file = config_file)
reg_indep_missbalanced_mege_diablo_na_keep <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_missbalanced_mege_param_data),
    reg = reg_indep_missbalanced_mege_diablo_na_keep
  ),
  reg = reg_indep_missbalanced_mege_diablo_na_keep)


## resume filtered results 
res_indep_missbalanced_mege_diablo_na_keep <- data.table::rbindlist(reg_indep_missbalanced_mege_diablo_na_keep)
res_indep_missbalanced_mege_mean_perf_diablo_na_keep <- res_indep_missbalanced_mege_diablo_na_keep[ , .(mean_perf = mean(predictions)), # Check this again whether I called it predictions 
                                                                                        by = .(perf_measure, effect)]
print(res_indep_missbalanced_mege_mean_perf_diablo_na_keep)
res_indep_missbalanced_mege_mean_perf_diablo_na_keep$Setting <- "Independent"
res_indep_missbalanced_mege_mean_perf_diablo_na_keep$Y_Distribution <- "Balanced"
res_indep_missbalanced_mege_mean_perf_diablo_na_keep$Na_action <- "na.keep"
res_indep_missbalanced_mege_mean_perf_diablo_na_keep$DE <- "DE: MeGe"
res_indep_missbalanced_mege_mean_perf_diablo_na_keep$Meta_learner <- "DIABLO"
saveRDS(
  object = res_indep_missbalanced_mege_mean_perf_diablo_na_keep,
  file = file.path(res_indep_mege,
                   "res_indep_missbalanced_mege_mean_perf_diablo_na_keep.rds")
)

