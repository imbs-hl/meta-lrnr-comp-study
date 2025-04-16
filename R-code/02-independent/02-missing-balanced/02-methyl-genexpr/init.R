source("../init.R", chdir = TRUE)
source(file.path(function_dir, "methyl-genexpr-effect.R"))

set.seed(4157)
indep_incombalanced_mege_param_data <- methyl_genexpr_effect(
  n = 100L,
  save_dir = indep_methyl_genexpr_dir
)

# Rename path to indicate the proportion of missingness
for(i in 1:length(indep_incombalanced_mege_param_data$save_path)) {
  indep_incombalanced_mege_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                                            replacement = sprintf("_prop_miss%s.rds", prop_missing_train * 100L),
                                                            x = indep_incombalanced_mege_param_data$save_path[i])
}