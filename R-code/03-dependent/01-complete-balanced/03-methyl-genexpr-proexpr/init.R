source("../init.R", chdir = TRUE)
source(file.path(function_dir, "megepro-effect.R"))

set.seed(4157)
dep_combalanced_megepro_param_data <- megepro_effect(
  n = 100L,
  save_dir = dep_combalanced_megepro_dir
)

# Rename path to indicate the proportion of missingness
prop_missing_train <- 0.0
for(i in 1:length(dep_combalanced_megepro_param_data$save_path)) {
  dep_combalanced_megepro_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                                          replacement = sprintf("_prop_miss%s.rds", prop_missing_train * 100L),
                                                          x = dep_combalanced_megepro_param_data$save_path[i])
}