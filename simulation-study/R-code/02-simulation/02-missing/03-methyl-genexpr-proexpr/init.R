source("../init.R", chdir = TRUE)
source(file.path(function_dir, "megepro-effect.R"))

set.seed(4157)

mis_megepro_param_data <- megepro_effect(n = 100L,
                                          save_dir = data_mis_megepro_data_dir)
# Rename path to indicate the proportion of missingness
prop_missing_train <- 0.2

for(i in 1:length(mis_megepro_param_data$save_path)) {
  mis_megepro_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                              replacement = sprintf("_prop_miss%s.rds",
                                                                    prop_missing_train * 100L),
                                              x = mis_megepro_param_data$save_path[i])
}