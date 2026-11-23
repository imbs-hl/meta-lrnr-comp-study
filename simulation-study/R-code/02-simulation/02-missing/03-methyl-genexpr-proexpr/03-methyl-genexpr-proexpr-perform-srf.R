###############################################################################
# path: 02-simulation\02-missing\03-methyl-genexpr-proexpr
# Dataset: missing
# Outcome: balanced
# Effect: in all modalities (methyl + gene expression + protein)
# Train SRF and SRF-mis
# Performance
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.learn"

for(i in 1:length(mis_megepro_param_data$save_path)) {
  mis_megepro_param_data$save_path[i] <- file.path(sub("data$", "train/srf", dirname(mis_megepro_param_data$save_path[i])),
                                                    sub( "_prop_miss", "_srf_prop_miss",
                                                         sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                              basename(mis_megepro_param_data$save_path[i])))) }


mis_megepro_perf_srf <- wrap_batchtools(reg_name = "03-mis-megepro-perf-srf",
                                        work_dir = working_dir,
                                        name = "mis-megepro-perf-srf",
                                        reg_dir = reg_mis_megepro_perf_dir,
                                        r_function = calculate_performance_ref, 
                                        vec_args = data.frame(input_file = mis_megepro_param_data$save_path,
                                                              delta.methyl = mis_megepro_param_data$delta.methyl,
                                                              delta.expr = mis_megepro_param_data$delta.expr,
                                                              delta.protein = mis_megepro_param_data$delta.protein,
                                                              effect = mis_megepro_param_data$effect,
                                                              seed = mis_megepro_param_data$seed,
                                                              result_dir = res_mis_megepro_perf_dir,
                                                              folder = "srf"),
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
  file.dir = file.path(reg_mis_megepro_perf_dir, "03-mis-megepro-perf-srf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)


##########################################
for(i in 1:length(mis_megepro_param_data$save_path)) {
  mis_megepro_param_data$save_path[i] <- file.path(sub("data$", "train/srf_mis", dirname(mis_megepro_param_data$save_path[i])),
                                                    sub( "_prop_miss", "_srf_prop_miss",
                                                         sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                              basename(mis_megepro_param_data$save_path[i])))) }


mis_megepro_perf_srf_mis <- wrap_batchtools(reg_name = "03-mis-megepro-perf-srf-mis",
                                            work_dir = working_dir,
                                            name = "mis-megepro-perf-srf-mis",
                                            reg_dir = reg_mis_megepro_perf_dir,
                                            r_function = calculate_performance_ref, 
                                            vec_args = data.frame(input_file = mis_megepro_param_data$save_path,
                                                                  delta.methyl = mis_megepro_param_data$delta.methyl,
                                                                  delta.expr = mis_megepro_param_data$delta.expr,
                                                                  delta.protein = mis_megepro_param_data$delta.protein,
                                                                  effect = mis_megepro_param_data$effect,
                                                                  seed = mis_megepro_param_data$seed,
                                                                  result_dir = res_mis_megepro_perf_dir,
                                                                  folder = "srf_mis"),
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
  file.dir = file.path(reg_mis_megepro_perf_dir, "03-mis-megepro-perf-srf-mis"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)
