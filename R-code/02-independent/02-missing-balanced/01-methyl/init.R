source("../init.R", chdir = TRUE)
source(file.path(function_dir, "me-effect.R"))
set.seed(4157)
indep_missbalanced_me_param_data <- me_effect(
  n = 100L,
  save_dir = indep_missbalanced_me_dir)
# Rename path to indicate the proportion of missingness
prop_missing_train <- 0.05
for(i in 1:length(indep_missbalanced_me_param_data$save_path)) {
  indep_missbalanced_me_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                                            replacement = sprintf("_prop_miss%s.rds", prop_missing_train * 100L),
                                                            x = indep_missbalanced_me_param_data$save_path[i])
  
}