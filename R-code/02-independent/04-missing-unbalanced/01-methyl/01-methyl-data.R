source("init.R", chdir = TRUE)
## Send jobs
no.threads <- 5
prop_missing_train <- 0.05
indep_missunbalanced_me_param_data$effect <- NULL
me_data <- wrap_batchtools(reg_name = "01-data",
                           work_dir = working_dir,
                           reg_dir = reg_indep_missunbalanced_me,
                           r_function = simuldata,
                           vec_args = indep_missunbalanced_me_param_data,
                           more_args = list(
                             empirical_param_prefix = data_tcga,
                             n.sample = 300,
                             cluster.sample.prop = c(0.7, 0.3),
                             p.DMP = 0.2,
                             p.DEG = NULL,
                             p.DEP = NULL,
                             do.plot = FALSE,
                             sample.cluster = TRUE,
                             feature.cluster = FALSE,
                             training_prop = 2/3,
                             prop_missing_train = prop_missing_train,
                             prop_missing_test = prop_missing_train,
                             function_dir = function_dir
                           ),
                           name = "me-missunb-me-data",
                           overwrite = TRUE,
                           memory = "40g",
                           n_cpus = no.threads,
                           walltime = "60",
                           sleep = 5,
                           partition = "prio", ## Set partition in init-global
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
