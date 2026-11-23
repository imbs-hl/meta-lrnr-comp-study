###############################################################################
# path: 02-simulation\02-missing\01-methyl
# Dataset: missing
# Outcome: balanced
# Effect: only in one modality (methyl)
# Train WA
###############################################################################

source("init.R", chdir = TRUE)

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------
mis_me_train_wa <- wrap_batchtools(reg_name = "02-mis-me-train-wa",
                                   name = "mis-me-train-wa",
                                   work_dir = working_dir,
                                   reg_dir = reg_mis_me_train_dir,
                                   r_function = single_run_wa,
                                   vec_args = data.frame(
                                      data_file = mis_me_param_data$save_path,
                                      seed = mis_me_param_data$seed),
                                   more_args = list(na_action = "na.keep"),
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
                                      "fuseMLR"
                                   ),
                                   config_file = config_file,
                                   interactive_session = interactive_session)

# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_me_train_dir, "02-mis-me-train-wa"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)