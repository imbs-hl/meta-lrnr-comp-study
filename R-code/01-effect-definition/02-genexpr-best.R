source(file.path(code_dir, "01-effect-definition/init.R"), chdir = TRUE)
## Send jobs
no.threads <- 5
reg_genexpr_train <- wrap_batchtools(reg_name = "02-def-genexpr-best",
                                     work_dir = working_dir,
                                     reg_dir = registry_dir,
                                     r_function = single_run_best,
                                     vec_args = data.frame(
                                       data_file = param_df_genexpr$save_path,
                                       seed = param_df_genexpr$seed,
                                       delta.methyl = param_df_genexpr$delta.methyl,
                                       delta.expr = param_df_genexpr$delta.expr,
                                       delta.protein = param_df_genexpr$delta.protein
                                     ),
                                     more_args = list(
                                       num.tree.boruta.methyl = 15000L,
                                       num.tree.ranger.methyl = 2000L,
                                       num.tree.boruta.genexpr = 2500L,
                                       num.tree.ranger.genexpr = 2000L,
                                       num.tree.boruta.proexpr = 2500L,
                                       num.tree.ranger.proexpr = 2000L
                                     ),
                                     name = "genexpr-train",
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
reg_genexpr_train <- batchtools::loadRegistry(
  file.dir = file.path(registry_dir, "02-def-genexpr-best"), writeable = TRUE,
  conf.file = config_file)
reg_genexpr_train <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(param_df_genexpr),
    reg = reg_genexpr_train
  ),
  reg = reg_genexpr_train)


## resume filtered results
reg_genexpr_train_DT <- data.table::rbindlist(reg_genexpr_train)
genexpr_mean_perf <- reg_genexpr_train_DT[ , .(mean_perf = mean(meta_layer)), 
                                           by = .(perf_measure, delta.expr)]
saveRDS(object = reg_genexpr_train_DT,
        file = file.path(dirname(param_df_genexpr$save_path[1]),
                         "perf-def-genexpr-best.rds"))

