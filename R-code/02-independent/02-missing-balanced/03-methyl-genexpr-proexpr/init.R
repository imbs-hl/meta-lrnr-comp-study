source("../init.R", chdir = TRUE)
source(file.path(function_dir, "megepro.R"))

set.seed(4157)
indep_megepro_param_data <- megepro_effect(
  n = 100L,
  save_dir = indep_methyl_genexpr_proexpr_dir
)
