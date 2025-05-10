source("../init.R", chdir = TRUE)
source(file.path(function_dir, "mege-effect.R"))

set.seed(4157)
indep_comunbalanced_mege_param_data <- mege_effect(
  n = 100L,
  save_dir = indep_comunbalanced_mege_dir
)

# Rename path to indicate the proportion of missingness
prop_missing_train <- 0.0
for(i in 1:length(indep_comunbalanced_mege_param_data$save_path)) {
  indep_comunbalanced_mege_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                                            replacement = sprintf("_prop_miss%s.rds", prop_missing_train * 100L),
                                                            x = indep_comunbalanced_mege_param_data$save_path[i])
}