source("../init.R", chdir = TRUE)
source(file.path(function_dir, "mege-effect.R"))

set.seed(4157)
dep_missbalanced_mege_param_data <- mege_effect(
  n = 100L,
  save_dir = dep_missbalanced_mege_dir
)

# Rename path to indicate the proportion of missingness
prop_missing_train <- 0.05
for(i in 1:length(dep_missbalanced_mege_param_data$save_path)) {
  dep_missbalanced_mege_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                                            replacement = sprintf("_prop_miss%s.rds", prop_missing_train * 100L),
                                                            x = dep_missbalanced_mege_param_data$save_path[i])
}