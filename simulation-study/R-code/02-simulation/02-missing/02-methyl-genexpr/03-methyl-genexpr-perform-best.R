###############################################################################
# path: 02-simulation\02-missing\02-methyl-genexpr
# Dataset: missing
# Outcome: balanced
# Effect: in two modalities (methyl + gene expression)
# Train best
# Performance 
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.keep"

for(i in 1:length(mis_mege_param_data$save_path)) {
  mis_mege_param_data$save_path[i] <- file.path(sub("data$", "train/best", dirname(mis_mege_param_data$save_path[i])),
                                                 sub( "_prop_miss", "_best_prop_miss",
                                                      sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                           basename(mis_mege_param_data$save_path[i])))) }

mis_mege_perf_best <- wrap_batchtools(reg_name = "03-mis-mege-perf-best",
                                      work_dir = working_dir,
                                      name = "mis-mege-perf-best",
                                      reg_dir = reg_mis_mege_perf_dir,
                                      r_function = calculate_performance,
                                      vec_args = data.frame(input_file = mis_mege_param_data$save_path,
                                                            delta.methyl = mis_mege_param_data$delta.methyl,
                                                            delta.expr = mis_mege_param_data$delta.expr,
                                                            delta.protein = mis_mege_param_data$delta.protein,
                                                            effect = mis_mege_param_data$effect,
                                                            seed = mis_mege_param_data$seed,
                                                            result_dir = res_mis_mege_perf_dir,
                                                            folder = "best"),
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
  file.dir = file.path(reg_mis_mege_perf_dir, "03-mis-mege-perf-best"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)