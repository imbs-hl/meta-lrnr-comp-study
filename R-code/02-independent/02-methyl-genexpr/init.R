source("../init.R", chdir = TRUE)
source(file.path(function_dir, "methyl-genexpr-effect.R"))

set.seed(4157)
indep_methy_genexpr_param_data <- methyl_genexpr_effect(
  n = 100L,
  save_dir = indep_methyl_genexpr_dir
)
