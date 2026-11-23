###############################################################################
# path: 02-simulation\02-missing\03-methyl-genexpr-proexpr
# Dataset: missing
# Outcome: balanced
# Effect: in all modalities (methyl + gene expression + protein)
# Train BlockForest (bf)
###############################################################################

source("init.R", chdir = TRUE)

## -----------------------------------------------------------------------------
## na_action = na_keep
## -----------------------------------------------------------------------------

mis_megepro_train_bf <- wrap_batchtools(reg_name = "02-mis-megepro-train-bf",
                                        name = "mis-megepro-train-bf",
                                        work_dir = working_dir,
                                        reg_dir = reg_mis_megepro_train_dir,
                                        r_function = single_run_bf,
                                        vec_args = data.frame(
                                          data_file = mis_megepro_param_data$save_path,
                                          seed = mis_megepro_param_data$seed),
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
                                          "ranger", 
                                          "tidyverse"),
                                        config_file = config_file,
                                        interactive_session = interactive_session)


# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_megepro_train_dir, "02-mis-megepro-train-bf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)