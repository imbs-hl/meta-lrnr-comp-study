###############################################################################
# path: 02-simulation\02-missing\01-methyl
# Dataset: missing
# Outcome: balanced
# Effect: only in one modality (methyl)
# Train Diablo
# Performance 
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.keep"

for(i in 1:length(mis_me_param_data$save_path)) {
  mis_me_param_data$save_path[i] <- file.path(sub("data$", "train/diablo_miss_fin", dirname(mis_me_param_data$save_path[i])),
                                               sub( "_prop_miss", "_diablo_prop_miss",
                                                    sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                         basename(mis_me_param_data$save_path[i])))) }


mis_me_perf_diablo_mis <- wrap_batchtools(reg_name = "03-mis-me-perf-diablo-mis",
                                          work_dir = working_dir,
                                          name = "mis-me-perf-diablo-mis",
                                          reg_dir = reg_mis_me_perf_dir,
                                          r_function = calculate_performance_ref,
                                          vec_args = data.frame(input_file = mis_me_param_data$save_path,
                                                                delta.methyl = mis_me_param_data$delta.methyl,
                                                                delta.expr = mis_me_param_data$delta.expr,
                                                                delta.protein = mis_me_param_data$delta.protein,
                                                                effect = mis_me_param_data$effect,
                                                                seed = mis_me_param_data$seed,
                                                                result_dir = res_mis_me_perf_dir,
                                                                folder = "diablo_miss_fin"),
                                          more_args = list(),
                                          overwrite = TRUE,
                                          memory = "1g",
                                          n_cpus = 1,
                                          walltime = "10",
                                          partition = "fast",
                                          account = "imbs",
                                          wait_for_jobs = FALSE,
                                          packages = c(
                                             "pROC",
                                             "MLmetrics"),
                                          config_file = config_file,
                                          interactive_session = interactive_session)



# Check
reg <- batchtools::loadRegistry(
  file.dir = file.path(reg_mis_me_perf_dir, "03-mis-me-perf-diablo-mis"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)
