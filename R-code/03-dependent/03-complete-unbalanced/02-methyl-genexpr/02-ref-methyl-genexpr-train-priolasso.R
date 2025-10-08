source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------
reg_mege_dep_comunbalanced_na_keep <- wrap_batchtools(reg_name = "02-train-priolasso-na-keep",
                                                    work_dir = working_dir,
                                                    reg_dir = reg_dep_comunbalanced_me,
                                                    r_function = single_run_priolasso,
                                                    vec_args = data.frame(
                                                      data_file = indep_comunbalanced_mege_param_data$save_path,
                                                      seed = indep_comunbalanced_mege_param_data$seed,
                                                      delta.methyl = indep_comunbalanced_mege_param_data$delta.methyl,
                                                      delta.expr = indep_comunbalanced_mege_param_data$delta.expr,
                                                      delta.protein = indep_comunbalanced_mege_param_data$delta.protein,
                                                      effect = indep_comunbalanced_mege_param_data$effect
                                                    ),
                                                    more_args = list(na_action = "na.keep"),
                                                    name = "comb-me-pl-na-keep",
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
                                                      "prioritylasso"
                                                    ),
                                                    config_file = config_file,
                                                    interactive_session = interactive_session)

## Run this after that your jobs are completed
## ----------------------------------------------
## Resume results
## ----------------------------------------------
##
reg_dep_comunbalanced_mege_pl_na_keep <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_comunbalanced_me,
                       "02-train-priolasso-na-keep"),
  writeable = TRUE,
  conf.file = config_file)
reg_dep_comunbalanced_mege_pl_na_keep <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_comunbalanced_mege_param_data),
    reg = reg_dep_comunbalanced_mege_pl_na_keep
  ),
  reg = reg_dep_comunbalanced_mege_pl_na_keep)


## resume filtered results
res_dep_comunbalanced_mege_pl_na_keep <- data.table::rbindlist(reg_dep_comunbalanced_mege_pl_na_keep)
res_dep_comunbalanced_mege_mean_perf_pl_na_keep <- res_dep_comunbalanced_mege_pl_na_keep[ , .(mean_perf = mean(predictions, na.rm = TRUE)), 
                                                                                      by = .(perf_measure, effect)]
print(res_dep_comunbalanced_mege_mean_perf_pl_na_keep)
res_dep_comunbalanced_mege_mean_perf_pl_na_keep$Setting <- "Dependent"
res_dep_comunbalanced_mege_mean_perf_pl_na_keep$Y_Distribution <- "Balanced"
res_dep_comunbalanced_mege_mean_perf_pl_na_keep$Na_action <- "na.keep"
res_dep_comunbalanced_mege_mean_perf_pl_na_keep$DE <- "DE: MeGe"
res_dep_comunbalanced_mege_mean_perf_pl_na_keep$Meta_learner <- "PriorityLasso"
saveRDS(
  object = res_dep_comunbalanced_mege_mean_perf_pl_na_keep,
  file = file.path(res_dep_me,
                   "res_dep_comunbalanced_mege_mean_perf_pl_na_keep.rds")
)

