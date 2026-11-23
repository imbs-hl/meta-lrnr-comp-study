#########################################################
# TCGA: Train COBRA meta-learner
#########################################################

source("../init.R", chdir = TRUE)

tcga_train_cobra <- wrap_batchtools(reg_name = "train_cobra",
                                    name = "train_cobra",
                                    work_dir = working_dir,
                                    reg_dir = registry_path,
                                    r_function = train_cobra,
                                    vec_args = data.frame(
                                      nam = tcga_cobra_param_data$nam,
                                      input_file = tcga_cobra_param_data$input_file,
                                      output_file = tcga_cobra_param_data$output_file),
                                    more_args = list(),
                                    overwrite = TRUE,
                                    memory = "8g",
                                    n_cpus = 1,
                                    walltime = "60",
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
  file.dir = file.path(registry_path, "train_cobra"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                      reg = reg)
