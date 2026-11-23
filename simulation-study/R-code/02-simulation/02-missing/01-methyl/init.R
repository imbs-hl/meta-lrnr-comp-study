source("../init.R", chdir = TRUE)
source(file.path(function_dir, "me-effect.R"))
set.seed(4157)

mis_me_param_data <- me_effect(n = 100L,
                                save_dir = data_mis_me_data_dir)

prop_missing_train <- 0.2

for(i in 1:length(mis_me_param_data$save_path)) {mis_me_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                                                                        replacement = sprintf("_prop_miss%s.rds", prop_missing_train * 100L),
                                                                                        x = mis_me_param_data$save_path[i])
  
}