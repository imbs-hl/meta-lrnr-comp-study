###############################################################################
# path: 02-simulation\01-complete\03-methyl-genexpr-proexpr
# Dataset: complete
# Outcome: balanced
# Effect: in all modalities (methyl + gene expression + protein)
# Train SRF und SRF-mis
# Performance 
###############################################################################

source("init.R", chdir = TRUE)

na_action = "na.learn"

for(i in 1:length(com_megepro_param_data$save_path)) {
  com_megepro_param_data$save_path[i] <- file.path(sub("data$", "train/srf", dirname(com_megepro_param_data$save_path[i])),
                                                    sub( "_prop_miss", "_srf_prop_miss",
                                                         sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                              basename(com_megepro_param_data$save_path[i])))) }


com_megepro_perf_srf <- wrap_batchtools(reg_name = "03-com-megepro-perf-srf",
                                        work_dir = working_dir,
                                        name = "com-megepro-perf-srf",
                                        reg_dir = reg_com_megepro_perf_dir,
                                        r_function = calculate_performance_ref,
                                        vec_args = data.frame(input_file = com_megepro_param_data$save_path,
                                                              delta.methyl = com_megepro_param_data$delta.methyl,
                                                              delta.expr = com_megepro_param_data$delta.expr,
                                                              delta.protein = com_megepro_param_data$delta.protein,
                                                              effect = com_megepro_param_data$effect,
                                                              seed = com_megepro_param_data$seed,
                                                              result_dir = res_com_megepro_perf_dir,
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
  file.dir = file.path(reg_com_megepro_perf_dir, "03-com-megepro-perf-srf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)


###############################
for(i in 1:length(com_megepro_param_data$save_path)) {
  com_megepro_param_data$save_path[i] <- file.path(sub("data$", "train/srf_mis", dirname(com_megepro_param_data$save_path[i])),
                                                    sub( "_prop_miss", "_srf_prop_miss",
                                                         sub("\\.rds$",paste0("_", na_action, ".rds"),
                                                              basename(com_megepro_param_data$save_path[i])))) }


com_megepro_perf_srf_mis <- wrap_batchtools(reg_name = "03-com-megepro-perf-srf-mis",
                                            work_dir = working_dir,
                                            name = "com-megepro-perf-srf-mis",
                                            reg_dir = reg_com_megepro_perf_dir,
                                            r_function = calculate_performance_ref,
                                            vec_args = data.frame(input_file = com_megepro_param_data$save_path,
                                                                  delta.methyl = com_megepro_param_data$delta.methyl,
                                                                  delta.expr = com_megepro_param_data$delta.expr,
                                                                  delta.protein = com_megepro_param_data$delta.protein,
                                                                  effect = com_megepro_param_data$effect,
                                                                  seed = com_megepro_param_data$seed,
                                                                  result_dir = res_com_megepro_perf_dir,
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
  file.dir = file.path(reg_com_megepro_perf_dir, "03-com-megepro-perf-srf"),
  conf.file = config_file,
  writeable = TRUE)

jobs <- batchtools::findJobs(reg = reg)

batchtools::getStatus(ids = jobs$job.id,
                       reg = reg)