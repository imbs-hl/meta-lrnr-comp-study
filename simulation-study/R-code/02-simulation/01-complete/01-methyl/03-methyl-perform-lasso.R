###############################################################################
# Dataset: complete
# Outcome: balanced
# Effect: only in one modality (methyl)
# Train lasso
# Performance 
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.keep" 

for(i in 1:length(com_me_param_data$save_path)) {
  com_me_param_data$save_path[i] <- file.path(sub("data$", "train/lasso", dirname(com_me_param_data$save_path[i])),
                                                            sub( "_prop_miss", "_lasso_prop_miss",
                                                                 sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                                     basename(com_me_param_data$save_path[i])))) }

com_me_perf_lasso <- wrap_batchtools(reg_name = "03-com-me-perf-lasso",
                                    work_dir = working_dir,
                                    name = "com-me-perf-lasso",
                                    reg_dir = reg_com_me_perf_dir,
                                    r_function = calculate_performance,
                                    vec_args = data.frame(input_file = com_me_param_data$save_path,
                                                          delta.methyl = com_me_param_data$delta.methyl,
                                                          delta.expr = com_me_param_data$delta.expr,
                                                          delta.protein = com_me_param_data$delta.protein,
                                                          effect = com_me_param_data$effect,
                                                          seed = com_me_param_data$seed,
                                                          result_dir = res_com_me_perf_dir,
                                                          folder = "lasso"),
                                    more_args = list(),
                                    overwrite = TRUE,
                                    memory = "1g",
                                    n_cpus = 1,
                                    walltime = "10",
                                    partition = "fast",
                                    account = "imbs",
                                    wait_for_jobs = TRUE,
                                    packages = c(
                                      "pROC",
                                      "MLmetrics"),
                                    config_file = config_file,
                                    interactive_session = interactive_session)



# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_com_me_perf_dir, "03-com-me-perf-lasso"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                      reg = reg)