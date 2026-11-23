###############################################################################
# Dataset: complete
# Outcome: balanced
# Effect: only in one modality (methyl)
# Train rf
# Performance 
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.keep" # because complete

for(i in 1:length(com_me_param_data$save_path)) {
  com_me_param_data$save_path[i] <- file.path(sub("data$", "train/rf", dirname(com_me_param_data$save_path[i])),
                                                            sub( "_prop_miss", "_rf_prop_miss",
                                                                 sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                                     basename(com_me_param_data$save_path[i])))) }

com_me_perf_rf <- wrap_batchtools(reg_name = "03-com-me-perf-rf",
                                  work_dir = working_dir,
                                  name = "com-me-perf-rf",
                                  reg_dir = reg_com_me_perf_dir,
                                  r_function = calculate_performance,
                                  vec_args = data.frame(input_file = com_me_param_data$save_path,
                                                        delta.methyl = com_me_param_data$delta.methyl,
                                                        delta.expr = com_me_param_data$delta.expr,
                                                        delta.protein = com_me_param_data$delta.protein,
                                                        effect = com_me_param_data$effect,
                                                         seed = com_me_param_data$seed,
                                                        result_dir = res_com_me_perf_dir,
                                                        folder = "rf"),
                                   more_args = list(),
                                  overwrite = TRUE,
                                  memory = "1g",
                                  n_cpus = 1,
                                  walltime = "10",
                                  partition = "fast",
                                  account = "imbs",
                                  packages = c(
                                    "pROC",
                                    "MLmetrics"),
                                  config_file = config_file,
                                  interactive_session = interactive_session)


# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_com_me_perf_dir, "03-com-me-perf-rf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                      reg = reg)