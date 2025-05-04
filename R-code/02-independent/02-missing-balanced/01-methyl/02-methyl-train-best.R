source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_methyl_train <- wrap_batchtools(reg_name = "02-train-best",
                                    work_dir = working_dir,
                                    reg_dir = reg_indep_missbalanced_me,
                                    r_function = single_run_best,
                                    vec_args = data.frame(
                                      data_file = indep_missbalanced_me_param_data$save_path,
                                      seed = indep_missbalanced_me_param_data$seed,
                                      delta.methyl = indep_missbalanced_me_param_data$delta.methyl,
                                      delta.expr = indep_missbalanced_me_param_data$delta.expr,
                                      delta.protein = indep_missbalanced_me_param_data$delta.protein,
                                      effect = indep_missbalanced_me_param_data$effect
                                    ),
                                    more_args = list(
                                      num.tree.boruta.methyl = 15000L,
                                      num.tree.ranger.methyl = 2000L,
                                      num.tree.boruta.genexpr = 5000L,
                                      num.tree.ranger.genexpr = 1000L,
                                      num.tree.boruta.proexpr = 5000L,
                                      num.tree.ranger.proexpr = 1000L
                                    ),
                                    name = "miss-me-best",
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
reg_methyl_train_best <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_missbalanced_me, "02-train-best"), writeable = TRUE,
  conf.file = config_file)
reg_methyl_train_best <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_methyl_param_data),
    reg = reg_methyl_train_best
  ),
  reg = reg_methyl_train_best)


## resume filtered results
indep_res_methyl_best <- data.table::rbindlist(reg_methyl_train_best)
indep_methyl_mean_perf_best <- indep_res_methyl_best[ , .(mean_perf = mean(meta_layer)), 
                                         by = .(perf_measure, effect)]
print(indep_methyl_mean_perf_best)
indep_res_methyl_best$Setting <- "Independent"
indep_res_methyl_best$DE <- "DE: Me"
indep_res_methyl_best$Meta_learner <- "BM"
saveRDS(object = indep_res_methyl_best,
        file = file.path(res_indep_methyl, "indep_res_methyl_best.rds"))

