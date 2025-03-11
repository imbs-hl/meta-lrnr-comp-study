source(file.path(code_dir, "01-effect-definition/init.R"), chdir = TRUE)
## Send jobs
no.threads <- 20
def_proexpr_best <- wrap_batchtools(reg_name = "02-def-proexpr-best",
                                work_dir = working_dir,
                                reg_dir = registry_dir,
                                r_function = single_run_best,
                                vec_args = data.frame(
                                  data_file = param_df_proexpr$save_path,
                                  seed = param_df_proexpr$seed,
                                  delta.methyl = param_df_proexpr$delta.methyl,
                                  delta.expr = param_df_proexpr$delta.expr,
                                  delta.protein = param_df_proexpr$delta.protein
                                ),
                                more_args = list(
                                  num.tree.boruta.methyl = 5L,
                                  num.tree.ranger.methyl = 2L,
                                  num.tree.boruta.genexpr = 2L,
                                  num.tree.ranger.genexpr = 2L,
                                  num.tree.boruta.proexpr = 2000L,
                                  num.tree.ranger.proexpr = 1000L
                                ),
                                name = "proexpr-train",
                                overwrite = TRUE,
                                memory = "25g",
                                n_cpus = no.threads,
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
reg_proexpr_train <- batchtools::loadRegistry(
  file.dir = file.path(registry_dir, "02-def-proexpr-best"), writeable = TRUE,
  conf.file = config_file)
reg_proexpr_train <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(param_df_proexpr),
    reg = reg_proexpr_train
  ),
  reg = reg_proexpr_train)


## resume filtered results
reg_proexpr_train_DT <- data.table::rbindlist(reg_proexpr_train)
proexpr_mean_perf <- reg_proexpr_train_DT[ , .(mean_perf = mean(meta_layer)), 
                                           by = .(perf_measure, delta.protein)]
saveRDS(object = reg_proexpr_train_DT,
        file = file.path(dirname(param_df_proexpr$save_path[1]),
                         "perf-def-proexpr-best.rds"))
