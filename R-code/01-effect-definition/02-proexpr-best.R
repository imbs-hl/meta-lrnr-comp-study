source(file.path(code_dir, "01-effect-definition/init.R"), chdir = TRUE)
## Send jobs
no.threads <- 5
run_boruta10 <- wrap_batchtools(reg_name = "02-def-proexpr-best",
                                work_dir = working_dir,
                                reg_dir = registry_dir,
                                r_function = single_run_best,
                                vec_args = data.frame(
                                  data_file = param_df_proexpr$save_path,
                                  seed = param_df_proexpr$seed,
                                  delta.methyl = param_df_proexpr$delta.methyl,
                                  delta.expr = param_df_proexpr$delta.expr,
                                  delta.protein = param_df_proexpr$delta.protein
                                ),
                                more_args = list(
                                  num.tree.boruta.methyl = 15000L,
                                  num.tree.ranger.methyl = 2000L,
                                  num.tree.boruta.genexpr = 2500L,
                                  num.tree.ranger.genexpr = 2000L,
                                  num.tree.boruta.proexpr = 2500L,
                                  num.tree.ranger.proexpr = 2000L
                                ),
                                name = "proexpr-train",
                                overwrite = TRUE,
                                memory = "25g",
                                n_cpus = 5,
                                walltime = "60",
                                sleep = 5,
                                partition = "prio", ## Set partition in init-global
                                account = "dzhk-omics", ## Set account in init-global
                                test_job = FALSE,
                                wait_for_jobs = FALSE,
                                packages = c(
                                  "devtools",
                                  "data.table",
                                  "mgcv",
                                  "fuseMLR"
                                ),
                                config_file = config_file,
                                interactive_session = interactive_session)
