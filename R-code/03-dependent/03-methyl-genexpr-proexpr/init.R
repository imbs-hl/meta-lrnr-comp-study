source("../init.R", chdir = TRUE)
source(file.path(function_dir, "methyl-genexpr-proexpr-effect.R"))

set.seed(4157)
dep_methyl_genexpr_proexpr_param_data <- methyl_genexpr_proexpr_effect(
  n = 100L,
  save_dir = dep_methyl_genexpr_proexpr_dir
)
