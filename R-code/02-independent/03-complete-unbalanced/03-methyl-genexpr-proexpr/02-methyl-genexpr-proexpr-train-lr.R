source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_indep_megepro_train_lr <- wrap_batchtools(reg_name = "02-train-lr",
                                    work_dir = working_dir,
                                    reg_dir = reg_indep_methyl_genexpr_proexpr,
                                    r_function = single_run_lr,
                                    vec_args = data.frame(
                                      data_file = indep_methyl_genexpr_proexpr_param_data$save_path,
                                      seed = indep_methyl_genexpr_proexpr_param_data$seed,
                                      delta.methyl = indep_methyl_genexpr_proexpr_param_data$delta.methyl,
                                      delta.expr = indep_methyl_genexpr_proexpr_param_data$delta.expr,
                                      delta.protein = indep_methyl_genexpr_proexpr_param_data$delta.protein,
                                      effect = indep_methyl_genexpr_proexpr_param_data$effect
                                    ),
                                    more_args = list(
                                      num.tree.meta = 1000L
                                    ),
                                    name = "methyl-lr",
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
                                    source = c(file.path(function_dir, 
                                                         "myglm.R")),
                                    config_file = config_file,
                                    interactive_session = interactive_session)

## Run this after that your jobs are completed
## ----------------------------------------------
## Resume results
## ----------------------------------------------
##
reg_indep_megepro_train_lr <- batchtools::loadRegistry(
  file.dir = file.path(reg_indep_methyl_genexpr_proexpr, "02-train-lr"),
  writeable = TRUE,
  conf.file = config_file)
reg_indep_megepro_train_lr <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(indep_methyl_genexpr_proexpr_param_data),
    reg = reg_indep_megepro_train_lr
  ),
  reg = reg_indep_megepro_train_lr)


## resume filtered results
indep_res_megepro_lr <- data.table::rbindlist(reg_indep_megepro_train_lr)
indep_megepro_mean_perf_lr <- indep_res_megepro_lr[ , .(mean_perf = mean(meta_layer)), 
                                                          by = .(perf_measure, effect)]
print(indep_megepro_mean_perf_lr)
indep_res_megepro_lr$Setting <- "Independent"
indep_res_megepro_lr$DE <- "DE: MeGePro"
indep_res_megepro_lr$Meta_learner <- "LogReg"
saveRDS(object = indep_res_megepro_lr,
        file = file.path(res_indep_methyl_genexpr_proexpr,
                         "indep_res_megepro_lr.rds"))
