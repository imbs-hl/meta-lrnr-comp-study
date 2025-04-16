source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
reg_dep_megepro_train_lasso <- wrap_batchtools(reg_name = "02-train-lasso",
                                               work_dir = working_dir,
                                               reg_dir = reg_dep_methyl_genexpr_proexpr,
                                               r_function = single_run_lasso,
                                               vec_args = data.frame(
                                                 data_file = dep_methyl_genexpr_proexpr_param_data$save_path,
                                                 seed = dep_methyl_genexpr_proexpr_param_data$seed,
                                                 delta.methyl = dep_methyl_genexpr_proexpr_param_data$delta.methyl,
                                                 delta.expr = dep_methyl_genexpr_proexpr_param_data$delta.expr,
                                                 delta.protein = dep_methyl_genexpr_proexpr_param_data$delta.protein,
                                                 effect = dep_methyl_genexpr_proexpr_param_data$effect
                                               ),
                                               more_args = list(
                                                 num.tree.meta = 1000L
                                               ),
                                               name = "dep-megepro-lasso",
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
                                                 "glmnet",
                                                 "fuseMLR"
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
reg_dep_megepro_train_lasso <- batchtools::loadRegistry(
  file.dir = file.path(reg_dep_methyl_genexpr_proexpr, "02-train-lasso"),
  writeable = TRUE,
  conf.file = config_file)
reg_dep_megepro_train_lasso <- batchtools::reduceResultsList(
  ids = batchtools::findDone(
    ids = 1:nrow(dep_methyl_genexpr_proexpr_param_data),
    reg = reg_dep_megepro_train_lasso
  ),
  reg = reg_dep_megepro_train_lasso)


## resume filtered results
dep_res_megepro_lasso <- data.table::rbindlist(reg_dep_megepro_train_lasso)
dep_megepro_mean_perf_lasso <- dep_res_megepro_lasso[ , .(mean_perf = mean(meta_layer)), 
                                                      by = .(perf_measure, effect)]
print(dep_megepro_mean_perf_lasso)
dep_res_megepro_lasso$Setting <- "Dependent"
dep_res_megepro_lasso$DE <- "DE: MeGePro"
dep_res_megepro_lasso$Meta_learner <- "Lasso"
saveRDS(object = dep_res_megepro_lasso,
        file = file.path(res_dep_methyl_genexpr_proexpr,
                         "dep_res_megepro_lasso.rds"))
