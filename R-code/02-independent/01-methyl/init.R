source("../init.R", chdir = TRUE)
source(file.path(function_dir, "methyl-effect.R"))
source(file.path(function_dir, "single-run-best.R"))
source(file.path(function_dir, "single-run-rf.R"))
source(file.path(function_dir, "single-run-lasso.R"))
source(file.path(function_dir, "single-run-lr.R"))
source(file.path(function_dir, "single-run-cobra.R"))

set.seed(4157)
indep_methy_param_data <- methyl_effect(n = 100L, save_dir = indep_methyl_dir)

