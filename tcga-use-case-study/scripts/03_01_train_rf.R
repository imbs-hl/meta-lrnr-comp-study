#########################################################
# TCGA: Train RF base models and RF meta-learner
#########################################################

source("../init.R", chdir = TRUE)


tcga_train_rf <- wrap_batchtools(reg_name = "train_rf",
                                 name = "train_rf",
                                 work_dir = working_dir,
                                 reg_dir = registry_path,
                                 r_function = train_rf,
                                 vec_args = data.frame(
                                   nam = tcga_rf_param_data$nam,
                                   input_file = tcga_rf_param_data$input_file,
                                   output_file = tcga_rf_param_data$output_file),
                                 more_args = list(),
                                 overwrite = TRUE,
                                 memory = "8g",
                                 n_cpus = 1,
                                 walltime = "1200",
                                 sleep = 5,
                                 partition = partition,
                                 account = account,
                                 test_job = FALSE,
                                 wait_for_jobs = FALSE,
                                 source = file.path(project_root, "init.R"),
                                 packages = c("devtools", "data.table", "mgcv", "fuseMLR"),
                                 config_file = config_file,
                                 interactive_session = interactive_session)

# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(registry_path, "train_rf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                      reg = reg)


