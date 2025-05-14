source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
## -----------------------------------------------------------------------------
## na_action = na_impute
## -----------------------------------------------------------------------------
##
reg_mege_indep_combalanced_na_keep <- wrap_batchtools(reg_name = "02-train-lasso-na-keep",
                                                      work_dir = working_dir,
                                                      reg_dir = reg_indep_combalanced_mege,
                                                      r_function = single_run_lasso,
                                                      vec_args = data.frame(
                                                        data_file = indep_combalanced_mege_param_data$save_path,
                                                        seed = indep_combalanced_mege_param_data$seed,
                                                        delta.methyl = indep_combalanced_mege_param_data$delta.methyl,
                                                        delta.expr = indep_combalanced_mege_param_data$delta.expr,
                                                        delta.protein = indep_combalanced_mege_param_data$delta.protein,
                                                        effect = indep_combalanced_mege_param_data$effect
                                                      ),
                                                      more_args = list(na_action = "na.keep"),
                                                      name = "comb-mege-lasso-na-keep",
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
                                                        "fuseMLR",
                                                        "glmnet"
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
reg_indep_combalanced_mege_lasso_na_keep <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_combalanced_mege, "02-train-lasso-na-keep"),
  writeable = TRUE,
  conf.file = config_file)
reg_indep_combalanced_mege_lasso_na_keep <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_combalanced_mege_param_data),
    reg = reg_indep_combalanced_mege_lasso_na_keep
  ),
  reg = reg_indep_combalanced_mege_lasso_na_keep)


## resume filtered results
res_indep_combalanced_mege_lasso_na_keep <- data.table::rbindlist(reg_indep_combalanced_mege_lasso_na_keep)
res_indep_combalanced_mege_mean_perf_lasso_na_keep <- res_indep_combalanced_mege_lasso_na_keep[ , .(mean_perf = mean(meta_layer)), 
                                                                                                by = .(perf_measure, effect)]
print(res_indep_combalanced_mege_mean_perf_lasso_na_keep)
res_indep_combalanced_mege_mean_perf_lasso_na_keep$Setting <- "Independent"
res_indep_combalanced_mege_mean_perf_lasso_na_keep$Y_Distribution <- "Balanced"
res_indep_combalanced_mege_mean_perf_lasso_na_keep$Na_action <- "na.keep"
res_indep_combalanced_mege_mean_perf_lasso_na_keep$DE <- "DE: MeGe"
res_indep_combalanced_mege_mean_perf_lasso_na_keep$Meta_learner <- "Lasso"
saveRDS(
  object = res_indep_combalanced_mege_mean_perf_lasso_na_keep,
  file = file.path(res_indep_mege,
                   "res_indep_combalanced_mege_mean_perf_lasso_na_keep.rds")
)
