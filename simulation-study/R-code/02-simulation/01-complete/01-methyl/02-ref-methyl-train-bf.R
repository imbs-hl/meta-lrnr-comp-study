###############################################################################
# path: 02-simulation\01-complete\01-methyl
# Dataset: complete
# Outcome: balanced
# Effect: only in one modality (methyl)
# Train BlockForest (bf)
###############################################################################

source("init.R", chdir = TRUE)

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------
com_me_train_bf <- wrap_batchtools(reg_name = "02-com-me-train-bf",
                                   name = "com-me-train-bf",
                                   work_dir = working_dir,
                                   reg_dir = reg_com_me_train_dir,
                                   r_function = single_run_bf,
                                   vec_args = data.frame(
                                     data_file = com_me_param_data$save_path,
                                     seed = com_me_param_data$seed),
                                   more_args = list(na_action = "na.keep",
                                                    num.trees = 25000L),
                                   overwrite = TRUE,
                                   memory = "8g",
                                   n_cpus = 1,
                                   walltime = "02:00:00",
                                   sleep = 5,
                                   partition = "batch", ## Set partition in init-global
                                   account = "imbs", ## Set account in init-global
                                   test_job = FALSE,
                                   wait_for_jobs = FALSE,
                                   packages = c(
                                     "devtools",
                                     "data.table",
                                     "mgcv",
                                     "blockForest",
                                     "tidyverse"),
                                   config_file = config_file,
                                   interactive_session = interactive_session)


# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_com_me_train_dir, "02-com-me-train-bf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                      reg = reg)
