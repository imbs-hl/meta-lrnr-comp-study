source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 8
dep_combalanced_megepro_param_data$effect <- NULL
megepro_data <- wrap_batchtools(reg_name = "01-data",
                               work_dir = working_dir,
                               reg_dir = reg_dep_combalanced_megepro,
                               r_function = simuldata,
                               vec_args = dep_combalanced_megepro_param_data,
                               more_args = list(
                                 empirical_param_prefix = data_tcga,
                                 n.sample = 300,
                                 cluster.sample.prop = c(0.5, 0.5),
                                 p.DMP = 0.2,
                                 p.DEG = 0.2,
                                 p.DEP = 0.2,
                                 do.plot = FALSE,
                                 sample.cluster = TRUE,
                                 feature.cluster = FALSE,
                                 training_prop = 2/3,
                                 prop_missing_train = prop_missing_train,
                                 prop_missing_test = 0,
                                 function_dir = function_dir
                               ),
                               name = "dep-com-megepro-data",
                               overwrite = TRUE,
                               memory = "40g",
                               n_cpus = no.threads,
                               walltime = "0",
                               sleep = 5,
                               partition = "batch", ## Set partition in init-global
                               account = "dzhk-omics", ## Set account in init-global
                               test_job = FALSE,
                               wait_for_jobs = FALSE,
                               packages = c(
                                 "devtools",
                                 "data.table",
                                 "mgcv"
                               ),
                               config_file = config_file,
                               interactive_session = interactive_session)
