source(file.path(code_dir, "01-effect-definition/init.R"), chdir = TRUE)
## Send jobs
no.threads <- 5
run_boruta10 <- wrap_batchtools(reg_name = "01-effect-def-proexpr",
                                work_dir = working_dir,
                                reg_dir = registry_dir,
                                r_function = simuldata,
                                vec_args = param_df_proexpr,
                                more_args = list(
                                  empirical_param_prefix = data_tcga,
                                  n.sample = 300,
                                  cluster.sample.prop = c(0.5, 0.5),
                                  p.DMP = 0.2,
                                  p.DEG = NULL,
                                  p.DEP = NULL,
                                  do.plot = FALSE,
                                  sample.cluster = TRUE,
                                  feature.cluster = FALSE,
                                  training_prop = 2/3,
                                  prop_missing_train = 0,
                                  prop_missing_test = 0,
                                  function_dir = function_dir
                                ),
                                name = "proexpr-data",
                                overwrite = TRUE,
                                memory = "25g",
                                n_cpus = no.threads,
                                walltime = "0",
                                sleep = 5,
                                partition = "batch", ## Set partition in init-global
                                account = "imbs", ## Set account in init-global
                                test_job = FALSE,
                                wait_for_jobs = FALSE,
                                packages = c(
                                  "devtools",
                                  "data.table",
                                  "mgcv",
                                  "InterSIM"
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
                                           by = .(perf_measure, delta.expr)]
saveRDS(object = reg_proexpr_train_DT,
        file = file.path(dirname(param_df_proexpr$save_path[1]),
                         "perf-def-proexpr-best.rds"))
