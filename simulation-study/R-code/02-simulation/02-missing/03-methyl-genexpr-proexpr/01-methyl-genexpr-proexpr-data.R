###############################################################################
# path: 02-simulation\02-missing\03-methyl-genexpr-proexpr
# Dataset: missing
# Outcome: balanced
# Effect: in all modalities (methyl + gene expression + protein)
###############################################################################

source("init.R", chdir = TRUE)

mis_megepro_param_data$effect <- NULL

mis_megepro_data <- wrap_batchtools(reg_name = "03-mis-megepro-data",
                                    name = "mis-megepro-data",
                                    work_dir = working_dir,
                                    reg_dir = reg_mis_megepro_data_dir,
                                    r_function = simuldata,
                                    vec_args = mis_megepro_param_data,
                                    more_args = list(
                                      empirical_param_prefix = data_tcga_dat,
                                      n.sample = 300,
                                      cluster.sample.prop = c(0.5, 0.5),
                                      p.DMP = 0.2,
                                      p.DEG = 0.2,
                                      p.DEP = 0.2,
                                      cor.methyl.expr = NULL,
                                      cor.expr.protein = NULL,
                                      do.plot = FALSE,
                                      sample.cluster = TRUE,
                                      feature.cluster = FALSE,
                                      training_prop = 2/3,
                                      prop_missing_train = prop_missing_train,
                                      prop_missing_test = prop_missing_train,
                                      function_dir = function_dir
                                    ),
                                    overwrite = TRUE,
                                    memory = "70g",
                                    n_cpus = 1,
                                    walltime = "60",
                                    sleep = 5,
                                    partition = "batch,fast", ## Set partition in init-global
                                    account = "imbs", ## Set account in init-global
                                    test_job = FALSE,
                                    wait_for_jobs = FALSE,
                                    packages = c(
                                      "devtools",
                                      "data.table",
                                      "mgcv"),
                                    config_file = config_file,
                                    interactive_session = interactive_session)
