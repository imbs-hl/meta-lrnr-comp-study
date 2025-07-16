source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------
reg_me_indep_combalanced_na_keep <- wrap_batchtools(reg_name = "02-train-srf-na-keep",
                                                    work_dir = working_dir,
                                                    reg_dir = reg_indep_combalanced_me,
                                                    r_function = single_run_srf,
                                                    vec_args = data.frame(
                                                      data_file = indep_combalanced_me_param_data$save_path,
                                                      seed = indep_combalanced_me_param_data$seed,
                                                      delta.methyl = indep_combalanced_me_param_data$delta.methyl,
                                                      delta.expr = indep_combalanced_me_param_data$delta.expr,
                                                      delta.protein = indep_combalanced_me_param_data$delta.protein,
                                                      effect = indep_combalanced_me_param_data$effect
                                                    ),
                                                    more_args = list(na_action = "na.keep",
                                                                     num.tree.boruta = 25000L,
                                                                     num.tree.ranger = 5000L),
                                                    name = "comb-me-srf-na-keep",
                                                    overwrite = TRUE,
                                                    memory = "25g",
                                                    n_cpus = 6,
                                                    walltime = "0",
                                                    sleep = 5,
                                                    partition = "prio", ## Set partition in init-global
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
reg_indep_combalanced_me_srf_na_keep <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_combalanced_me,
                       "02-train-srf-na-keep"),
  writeable = TRUE,
  conf.file = config_file)
reg_indep_combalanced_me_srf_na_keep <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_combalanced_me_param_data),
    reg = reg_indep_combalanced_me_srf_na_keep
  ),
  reg = reg_indep_combalanced_me_srf_na_keep)


## resume filtered results 
res_indep_combalanced_me_srf_na_keep <- data.table::rbindlist(reg_indep_combalanced_me_srf_na_keep)
res_indep_combalanced_me_mean_perf_srf_na_keep <- res_indep_combalanced_me_srf_na_keep[ , .(mean_perf = mean(predictions)), # Check this again whether I called it predictions 
                                                                                      by = .(perf_measure, effect)]
print(res_indep_combalanced_me_mean_perf_srf_na_keep)
res_indep_combalanced_me_mean_perf_srf_na_keep$Setting <- "Independent"
res_indep_combalanced_me_mean_perf_srf_na_keep$Y_Distribution <- "Balanced"
res_indep_combalanced_me_mean_perf_srf_na_keep$Na_action <- "na.keep"
res_indep_combalanced_me_mean_perf_srf_na_keep$DE <- "DE: Me"
res_indep_combalanced_me_mean_perf_srf_na_keep$Meta_learner <- "SRF"
saveRDS(
  object = res_indep_combalanced_me_mean_perf_srf_na_keep,
  file = file.path(res_indep_me,
                   "res_indep_combalanced_me_mean_perf_srf_na_keep.rds")
)

