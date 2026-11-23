###############################################################################
# path: 02-simulation\02-missing\03-methyl-genexpr-proexpr
# Dataset: missing
# Outcome: balanced
# Effect: in all modalities (methyl + gene expression + protein)
# Train lasso
###############################################################################

source("init.R", chdir = TRUE)
## -----------------------------------------------------------------------------
## na_action = na_impute
## -----------------------------------------------------------------------------
##
mis_megepro_train_lasso <- wrap_batchtools(reg_name = "02-mis-megepro-train-lasso",
                                           name = "mis-megepro-train-lasso",
                                           work_dir = working_dir,
                                           reg_dir = reg_mis_megepro_train_dir,
                                           r_function = single_run_lasso,
                                           vec_args = data.frame(
                                             data_file = mis_megepro_param_data$save_path,
                                             seed = mis_megepro_param_data$seed),
                                           more_args = list(na_action = "na.impute",
                                                            na_action_best = "na.keep"),
                                           overwrite = TRUE,
                                           memory = "8g",
                                           n_cpus = 1,
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
                                             "fuseMLR",
                                             "glmnet"),
                                           source = c(file.path(function_dir,
                                                                "mylasso.R")),
                                           config_file = config_file,
                                           interactive_session = interactive_session)

# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_megepro_train_dir, "02-mis-megepro-train-lasso"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)