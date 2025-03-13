source("../init.R", chdir = TRUE)
source(file.path(function_dir, "methyl-effect.R"))
set.seed(4157)
indep_methy_param_data <- methyl_effect(n = 100L, save_dir = indep_methyl_dir)

