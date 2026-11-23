###############################################################################
# path: 02-simulation\01-complete\01-methyl
# Dataset: complete
# Outcome: balanced
# Effect: only in one modality (methyl)
# Train best
###############################################################################

source("init.R", chdir = TRUE)

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------
com_me_train_best <- wrap_batchtools(reg_name = "02-com-me-train-best",
                                     name = "com-me-train-best",
                                     work_dir = working_dir,
                                     reg_dir = reg_com_me_train_dir,
                                     r_function = single_run_best,
                                     vec_args = data.frame(data_file = com_me_param_data$save_path,
                                                           seed = com_me_param_data$seed),
                                     more_args = list(num.tree.ranger.methyl = 15000L,
                                                      num.tree.ranger.genexpr = 15000L,
                                                      num.tree.ranger.proexpr = 10000L,
                                                      na_action = "na.keep"),
                                     overwrite = TRUE,
                                     memory = "8g",
                                     n_cpus = 1,
                                     walltime = "60",
                                     sleep = 5,
                                     partition = "prio", ## Set partition in init-global
                                     account = "p23048", ## Set account in init-global
                                     test_job = FALSE,
                                     wait_for_jobs = FALSE,
                                     packages = c("devtools",
                                                  "data.table",
                                                  "mgcv",
                                                  "fuseMLR"),
                                     config_file = config_file,
                                     interactive_session = interactive_session)

# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_com_me_train_dir, "02-com-me-train-best"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                      reg = reg)
batchtools::findDone(reg = reg)
batchtools::findNotDone(reg = reg)
batchtools::findErrors(reg = reg)
batchtools::findExpired(reg = reg)
