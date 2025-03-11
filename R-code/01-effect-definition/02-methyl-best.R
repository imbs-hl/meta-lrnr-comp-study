source(file.path(code_dir, "01-effect-definition/init.R"), chdir = TRUE)
## Send jobs
no.threads <- 5
run_boruta10 <- wrap_batchtools(reg_name = "02-def-methyl-best",
                                work_dir = working_dir,
                                reg_dir = registry_dir,
                                r_function = single_run_best,
                                vec_args = data.frame(
                                  data_file = param_df_methyl$save_path,
                                  seed = param_df_methyl$seed,
                                  delta.methyl = param_df_methyl$delta.methyl,
                                  delta.expr = param_df_methyl$delta.expr,
                                  delta.protein = param_df_methyl$delta.protein
                                ),
                                more_args = list(
                                  num.tree.boruta.methyl = 15000L,
                                  num.tree.ranger.methyl = 2000L,
                                  num.tree.boruta.genexpr = 2500L,
                                  num.tree.ranger.genexpr = 2000L,
                                  num.tree.boruta.proexpr = 2500L,
                                  num.tree.ranger.proexpr = 2000L
                                ),
                                name = "methyl-train",
                                overwrite = TRUE,
                                memory = "40g",
                                n_cpus = no.threads,
                                walltime = "0",
                                sleep = 10,
                                partition = "prio", ## Set partition in init-global
                                account = "dzhk-omics", ## Set account in init-global
                                test_job = FALSE,
                                wait_for_jobs = FALSE,
                                packages = c(
                                  "devtools",
                                  "data.table",
                                  "fuseMLR"
                                ),
                                config_file = config_file,
                                interactive_session = interactive_session)

## Run this after that your jobs are completed
## ----------------------------------------------
## Resume results
## ----------------------------------------------
##
reg_methyl_train <- batchtools::loadRegistry(
  file.dir = file.path(registry_dir, "02-def-methyl-best"), writeable = TRUE,
  conf.file = config_file)
reg_methyl_train <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(param_df_methyl),
    reg = reg_methyl_train
  ),
  reg = reg_methyl_train)


## resume filtered results
reg_methyl_train_DT <- data.table::rbindlist(reg_methyl_train)
methyl_mean_perf <- reg_methyl_train_DT[ , .(mean_perf = mean(meta_layer)), 
                                           by = .(perf_measure, delta.methyl)]
