source("../init.R", chdir = TRUE)
source(file.path(function_dir, "methyl-effect.R"))
set.seed(4157)
dep_methy_param_data <- methyl_effect(n = 100L, save_dir = dep_methyl_dir)

