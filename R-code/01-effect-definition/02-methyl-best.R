source(file.path(code_dir, "01-effect-definition/init.R"), chdir = TRUE)

# Prepare parameters
# param_df <- expand.grid(delta.methyl = c(0, 0.001, 0.01, 0.1), 
#                         delta.expr = c(0, 0.01, 0.1, 1), 
#                         delta.protein = c(0, 0.001, 0.01, 0.1))
param_df <- expand.grid(delta.methyl = c(0, 0.001, 0.01, 0.1, 0.2), 
                        delta.expr = c(0, 0, 0, 0, 0), 
                        delta.protein = c(0, 0, 0, 0, 0))
# Add seeds
set.seed(123)
random_integers <- sample(1:2000, nrow(param_df), replace = FALSE)
param_df$seed <- random_integers
param_df$save_path <- file.path(data_effect_def,
                                paste("methyl",
                                      paste(param_df$seed, "rds", sep = "."),
                                      sep = "/"))
## Send jobs
no.threads <- 5
run_boruta10 <- wrap_batchtools(reg_name = "02-def-methyl-best",
                                work_dir = working_dir,
                                reg_dir = registry_dir,
                                r_function = single_run_best,
                                vec_args = data.frame(
                                  data_file = param_df$save_path,
                                  seed = param_df$seed,
                                  delta.methyl = param_df$delta.methyl,
                                  delta.expr = param_df$delta.expr,
                                  delta.protein = param_df$delta.protein
                                ),
                                more_args = list(
                                  num.tree.boruta.methyl = 25000L,
                                  num.tree.ranger.methyl = 5000L,
                                  num.tree.boruta.genexpr = 10000L,
                                  num.tree.ranger.genexpr = 2000L,
                                  num.tree.boruta.proexpr = 5000L,
                                  num.tree.ranger.proexpr = 1000L
                                ),
                                name = "methyl-train",
                                overwrite = TRUE,
                                memory = "40g",
                                n_cpus = no.threads,
                                walltime = "0",
                                sleep = 10,
                                partition = partition, ## Set partition in init-global
                                account = "imbs", ## Set account in init-global
                                test_job = FALSE,
                                wait_for_jobs = FALSE,
                                packages = c(
                                  "devtools",
                                  "data.table",
                                  "mgcv"
                                ),
                                config_file = config_file,
                                interactive_session = interactive_session)
