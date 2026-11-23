###############################################################################
# path: 02-simulation/01-complete/02-methyl-genexpr
# Dataset: complete
# Outco: balanced
# Effect: in two modalities (methyl + gene expression)
# Train BlockForest (bf)
# Performance
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.keep"

for(i in 1:length(com_mege_param_data$save_path)) {
  com_mege_param_data$save_path[i] <- file.path(sub("data$", "train/bf", dirname(com_mege_param_data$save_path[i])),
                                                 sub( "_prop_miss", "_bf_prop_miss",
                                                      sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                           basename(com_mege_param_data$save_path[i])))) }


com_mege_perf_bf <- wrap_batchtools(reg_name = "03-com-mege-perf-bf",
                                    work_dir = working_dir,
                                    name = "com-mege-perf-bf",
                                    reg_dir = reg_com_mege_perf_dir,
                                    r_function = calculate_performance_ref, 
                                    vec_args = data.frame(input_file = com_mege_param_data$save_path,
                                                          delta.methyl = com_mege_param_data$delta.methyl,
                                                          delta.expr = com_mege_param_data$delta.expr,
                                                          delta.protein = com_mege_param_data$delta.protein,
                                                          effect = com_mege_param_data$effect,
                                                          seed = com_mege_param_data$seed,
                                                          result_dir = res_com_mege_perf_dir,
                                                          folder = "bf"),
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
  file.dir = file.path(reg_com_mege_perf_dir, "03-com-mege-perf-bf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)