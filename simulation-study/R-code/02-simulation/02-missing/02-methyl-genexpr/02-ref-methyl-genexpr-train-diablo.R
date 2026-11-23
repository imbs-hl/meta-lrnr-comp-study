###############################################################################
# path: 02-simulation\02-missing\02-methyl-genexpr
# Dataset: missing
# Outcome: balanced
# Effect: in two modalities (methyl + gene expression)
# Train diablo
###############################################################################

source("init.R", chdir = TRUE)

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------

mis_mege_train_diablo_mis <- wrap_batchtools(reg_name = "02-mis-mege-train-diablo-mis",
                                             name = "mis-mege-train-diablo-mis",
                                             work_dir = working_dir,
                                             reg_dir = reg_mis_mege_train_dir,
                                             r_function = single_run_diablo_miss,
                                             vec_args = data.frame(
                                                data_file = mis_mege_param_data$save_path,
                                                seed = mis_mege_param_data$seed),
                                             more_args = list(na_action = "na.keep"),
                                             overwrite = TRUE,
                                             memory = "8g",
                                             n_cpus = 1,
                                             walltime = "4300",
                                             sleep = 5,
                                             partition = "prio", ## Set partition in init-global
                                             account = "p23048", ## Set account in init-global
                                             test_job = FALSE,
                                             wait_for_jobs = FALSE,
                                             packages = c(
                                                "devtools",
                                                "data.table",
                                                "mgcv",
                                                "Boruta",
                                                "mixOmics",
                                                "ranger",
                                                "tidyverse"),
                                             config_file = config_file,
                                             interactive_session = interactive_session)



# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_mege_train_dir, "02-mis-mege-train-diablo-mis"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)

