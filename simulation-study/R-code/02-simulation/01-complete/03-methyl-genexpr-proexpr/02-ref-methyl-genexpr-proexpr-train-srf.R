###############################################################################
# path: 02-simulation\01-complete\03-methyl-genexpr-proexpr
# Dataset: complete
# Outcome: balanced
# Effect: in all modalities (methyl + gene expression + protein)
# Train SRF and SRF-mis
###############################################################################

source("init.R", chdir = TRUE)

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------

com_megepro_train_srf <- wrap_batchtools(reg_name = "02-com-megepro-train-srf",
                                         name = "com-megepro-train-srf",
                                         work_dir = working_dir,
                                         reg_dir = reg_com_megepro_train_dir,
                                         r_function = single_run_srf,
                                         vec_args = data.frame(
                                            data_file = com_megepro_param_data$save_path,
                                            seed = com_megepro_param_data$seed),
                                         more_args = list(na_action = "na.learn",
                                                          num.tree.boruta = 25000L,
                                                          num.tree.ranger = 15000L),
                                         overwrite = TRUE,
                                         memory = "8g",
                                         n_cpus = 1,
                                         walltime = "05:00:00",
                                         sleep = 5,
                                         partition = "prio", ## Set partition in init-global
                                         account = "p23048", ## Set account in init-global
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
  file.dir = file.path(reg_com_megepro_train_dir, "02-com-megepro-train-srf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)



com_megepro_train_srf_mis <- wrap_batchtools(reg_name = "02-com-megepro-train-srf-mis",
                                             name = "com-megepro-train-srf-mis",
                                             work_dir = working_dir,
                                             reg_dir = reg_com_megepro_train_dir,
                                             r_function = single_run_srf_mis,
                                             vec_args = data.frame(
                                                data_file = com_megepro_param_data$save_path,
                                                seed = com_megepro_param_data$seed),
                                             more_args = list(na_action = "na.learn",
                                                              num.tree.boruta = 25000L,
                                                              num.tree.ranger = 15000L),
                                             overwrite = TRUE,
                                             memory = "8g",
                                             n_cpus = 1,
                                             walltime = "05:00:00",
                                             sleep = 5,
                                             partition = "prio", ## Set partition in init-global
                                             account = "p23048", ## Set account in init-global
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
  file.dir = file.path(reg_com_megepro_train_dir, "02-com-megepro-train-srf-mis"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)
