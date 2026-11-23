###############################################################################
# path: 02-simulation\01-missing\03-methyl-genexpr-proexpr
# Dataset: missing
# Outcome: balanced
# Effect: in all modalities (methyl + gene expression + protein)
# Train Prioritylasso
# Performance 
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.impute"

for(i in 1:length(mis_megepro_param_data$save_path)) {
  mis_megepro_param_data$save_path[i] <- file.path(sub("data$", "train/priolasso", dirname(mis_megepro_param_data$save_path[i])),
                                                    sub( "_prop_miss", "_priolasso_prop_miss",
                                                         sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                              basename(mis_megepro_param_data$save_path[i])))) }


mis_megepro_perf_pl <- wrap_batchtools(reg_name = "03-mis-megepro-perf-pl",
                                       work_dir = working_dir,
                                       name = "mis-megepro-perf-pl",
                                       reg_dir = reg_mis_megepro_perf_dir,
                                       r_function = calculate_performance_ref,
                                       vec_args = data.frame(input_file = mis_megepro_param_data$save_path,
                                                             delta.methyl = mis_megepro_param_data$delta.methyl,
                                                             delta.expr = mis_megepro_param_data$delta.expr,
                                                             delta.protein = mis_megepro_param_data$delta.protein,
                                                             effect = mis_megepro_param_data$effect,
                                                             seed = mis_megepro_param_data$seed,
                                                             result_dir = res_mis_megepro_perf_dir,
                                                             folder = "priolasso"),
                                       more_args = list(),
                                       overwrite = TRUE,
                                       memory = "1g",
                                       n_cpus = 1,
                                       walltime = "10",
                                       partition = "fast,batch",
                                       account = "imbs",
                                       wait_for_jobs = FALSE,
                                       packages = c(
                                          "pROC",
                                          "MLmetrics"),
                                       config_file = config_file,
                                       interactive_session = interactive_session)

# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_megepro_perf_dir, "03-mis-megepro-perf-pl"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)
