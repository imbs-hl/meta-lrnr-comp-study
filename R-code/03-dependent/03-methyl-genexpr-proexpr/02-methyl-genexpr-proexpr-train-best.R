source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_megepro_train <- wrap_batchtools(reg_name = "02-train-best",
                                     work_dir = working_dir,
                                     reg_dir = reg_indep_methyl_genexpr_proexpr,
                                     r_function = single_run_best,
                                     vec_args = data.frame(
                                       data_file = dep_methyl_genexpr_proexpr_param_data$save_path,
                                       seed = dep_methyl_genexpr_proexpr_param_data$seed,
                                       delta.methyl = dep_methyl_genexpr_proexpr_param_data$delta.methyl,
                                       delta.expr = dep_methyl_genexpr_proexpr_param_data$delta.expr,
                                       delta.protein = dep_methyl_genexpr_proexpr_param_data$delta.protein,
                                       effect = dep_methyl_genexpr_proexpr_param_data$effect
                                     ),
                                     more_args = list(
                                       num.tree.boruta.methyl = 15000L,
                                       num.tree.ranger.methyl = 2000L,
                                       num.tree.boruta.genexpr = 5000L,
                                       num.tree.ranger.genexpr = 1000L,
                                       num.tree.boruta.proexpr = 5000L,
                                       num.tree.ranger.proexpr = 1000L
                                     ),
                                     name = "megepro-best",
                                     overwrite = TRUE,
                                     memory = "25g",
                                     n_cpus = 5,
                                     walltime = "60",
                                     sleep = 5,
                                     partition = "prio", ## Set partition in init-global
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
reg_dep_megepro_train_best <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_methyl_genexpr_proexpr, "02-train-best"),
  writeable = TRUE,
  conf.file = config_file)
reg_dep_megepro_train_best <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(dep_methyl_genexpr_proexpr_param_data),
    reg = reg_dep_megepro_train_best
  ),
  reg = reg_dep_megepro_train_best)


## resume filtered results
reg_dep_megepro_train_DT <- data.table::rbindlist(reg_dep_megepro_train_best)
methyl_mean_perf <- reg_dep_megepro_best_train_DT[ , .(mean_perf = mean(meta_layer)), 
                                                   by = .(perf_measure, effect)]
