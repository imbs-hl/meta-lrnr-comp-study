source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_methyl_train_rf <- wrap_batchtools(reg_name = "02-train-cobra",
                                       work_dir = working_dir,
                                       reg_dir = reg_indep_missbalanced_me,
                                       r_function = single_run_cobra,
                                       vec_args = data.frame(
                                         data_file = indep_missbalanced_me_param_data$save_path,
                                         seed = indep_missbalanced_me_param_data$seed,
                                         delta.methyl = indep_missbalanced_me_param_data$delta.methyl,
                                         delta.expr = indep_missbalanced_me_param_data$delta.expr,
                                         delta.protein = indep_missbalanced_me_param_data$delta.protein,
                                         effect = indep_missbalanced_me_param_data$effect,
                                         na_action == "na.impute"
                                       ),
                                       more_args = list(),
                                       name = "me-cobra",
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
reg_methyl_train_cobra <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_methyl, "02-train-cobra"), writeable = TRUE,
  conf.file = config_file)
reg_methyl_train_cobra <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_methyl_param_data),
    reg = reg_methyl_train_cobra
  ),
  reg = reg_methyl_train_cobra)


## resume filtered results
indep_res_methyl_cobra <- data.table::rbindlist(reg_methyl_train_cobra)
indep_methyl_mean_perf_cobra <- indep_res_methyl_cobra[ , .(mean_perf = mean(meta_layer)), 
                                                by = .(perf_measure, effect)]
print(indep_methyl_mean_perf_cobra)
indep_res_methyl_cobra$Setting <- "Independent"
indep_res_methyl_cobra$DE <- "DE: Me"
indep_res_methyl_cobra$Meta_learner <- "COBRA"
saveRDS(object = indep_res_methyl_cobra,
        file = file.path(res_indep_methyl, "indep_res_methyl_cobra.rds"))
