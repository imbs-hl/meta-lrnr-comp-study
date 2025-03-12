source("../init.R", chdir = TRUE)
source(function_dir, "methyl-genexpr-effect.R")

set.seed(4157)
dep_methy_genexpr_param_data <- methyl_genexpr_effect(
  n = 100L,
  save_dir = dep_methyl_genexpr_dir
)
