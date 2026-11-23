###############################################################################
# path: 02-simulation\02-missing\01-methyl
# Dataset: missing
# Outcome: balanced
# Effect: only in one modality (methyl)
# Train SRF and SRF-mis
###############################################################################

source("init.R", chdir = TRUE)

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------

mis_me_train_srf <- wrap_batchtools(reg_name = "02-mis-me-train-srf",
                                    name = "mis-me-train-srf",
                                    work_dir = working_dir,
                                    reg_dir = reg_mis_me_train_dir,
                                    r_function = single_run_srf,
                                    vec_args = data.frame(
                                      data_file = mis_me_param_data$save_path,
                                      seed = mis_me_param_data$seed),
                                    more_args = list(na_action = "na.learn",
                                                     num.tree.boruta = 25000L,
                                                     num.tree.ranger = 15000L),
                                    overwrite = TRUE,
                                    memory = "8g",
                                    n_cpus = 1,
                                    walltime = "05:00:00",
                                    sleep = 5,
                                    partition = "batch", ## Set partition in init-global
                                    account = "imbs", ## Set account in init-global
                                    test_job = FALSE,
                                    wait_for_jobs = FALSE,
                                    packages = c("devtools",
                                                 "data.table",
                                                 "mgcv",
                                                 "Boruta",
                                                 "ranger", 
                                                 "tidyverse"),
                                    config_file = config_file,
                                    interactive_session = interactive_session)



# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_me_train_dir, "02-mis-me-train-srf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)


mis_me_train_srf_mis <- wrap_batchtools(reg_name = "02-mis-me-train-srf-mis",
                                        name = "mis-me-train-srf-mis",
                                        work_dir = working_dir,
                                        reg_dir = reg_mis_me_train_dir,
                                        r_function = single_run_srf_mis,
                                        vec_args = data.frame(
                                           data_file = mis_me_param_data$save_path,
                                           seed = mis_me_param_data$seed),
                                        more_args = list(na_action = "na.learn",
                                                         num.tree.boruta = 25000L,
                                                         num.tree.ranger = 15000L),
                                        overwrite = TRUE,
                                        memory = "8g",
                                        n_cpus = 1,
                                        walltime = "05:00:00",
                                        sleep = 5,
                                        partition = "batch", ## Set partition in init-global
                                        account = "imbs", ## Set account in init-global
                                        test_job = FALSE,
                                        wait_for_jobs = FALSE,
                                        packages = c("devtools",
                                                      "data.table",
                                                      "mgcv",
                                                      "Boruta",
                                                      "ranger", 
                                                      "tidyverse"),
                                        config_file = config_file,
                                        interactive_session = interactive_session)

reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_me_train_dir, "02-mis-me-train-srf-mis"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)
