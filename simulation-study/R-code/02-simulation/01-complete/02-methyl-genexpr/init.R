source("../init.R", chdir = TRUE)
source(file.path(function_dir, "mege-effect.R"))

set.seed(4157)
com_mege_param_data <- mege_effect(n = 100L,
                                    save_dir = data_com_mege_data_dir)

prop_missing_train <- 0.00
for(i in 1:length(com_mege_param_data$save_path)) {com_mege_param_data$save_path[i] <- sub(pattern = "\\.rds$",
                                                                                            replacement = sprintf("_prop_miss%s.rds", prop_missing_train * 100L),
                                                                                            x = com_mege_param_data$save_path[i])
}