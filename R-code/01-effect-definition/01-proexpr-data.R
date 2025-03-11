source(file.path(code_dir, "01-effect-definition/init.R"), chdir = TRUE)
## Send jobs
no.threads <- 5
effect_def_proexpr <- wrap_batchtools(reg_name = "01-effect-def-proexpr",
                                      work_dir = working_dir,
                                      reg_dir = registry_dir,
                                      r_function = simuldata,
                                      vec_args = param_df_proexpr,
                                      more_args = list(
                                        empirical_param_prefix = data_tcga,
                                        n.sample = 300,
                                        cluster.sample.prop = c(0.5, 0.5),
                                        p.DMP = 0.2,
                                        p.DEG = NULL,
                                        p.DEP = 0.2,
                                        do.plot = FALSE,
                                        sample.cluster = TRUE,
                                        feature.cluster = FALSE,
                                        training_prop = 2/3,
                                        prop_missing_train = 0,
                                        prop_missing_test = 0,
                                        function_dir = function_dir
                                      ),
                                      name = "proexpr-data",
                                      overwrite = TRUE,
                                      memory = "25g",
                                      n_cpus = no.threads,
                                      walltime = "0",
                                      sleep = 5,
                                      partition = "batch", ## Set partition in init-global
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
