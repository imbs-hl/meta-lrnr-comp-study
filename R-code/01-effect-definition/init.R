source(file.path(code_dir, "init-global.R"), chdir = TRUE)
source(file.path(function_dir, "simuldata.R"))
source(file.path(function_dir, "single-run-best.R"))

# ==============================
# Methylation parameters
# ==============================
#
param_df_methyl <- expand.grid(delta.methyl = c(0, 0.05, 0.1, 0.15, 0.2), 
                               delta.expr = c(0, 0, 0, 0, 0), 
                               delta.protein = c(0, 0, 0, 0, 0))
# Add seeds
set.seed(123)
random_integers <- sample(1:2000, nrow(param_df_methyl), replace = FALSE)
param_df_methyl$seed <- random_integers
param_df_methyl$save_path <- file.path(data_effect_def,
                                       paste("methyl",
                                             paste(param_df_methyl$seed, "rds", sep = "."),
                                             sep = "/"))
# ==============================
# Gene expression parameters
# ==============================
#
param_df_genexpr <- expand.grid(delta.methyl = c(0, 0, 0, 0, 0), 
                                delta.expr = c(0, 70, 90, 110, 120), 
                                delta.protein = c(0, 0, 0, 0, 0))
# Add seeds
set.seed(123)
random_integers <- sample(1:2000, nrow(param_df_genexpr), replace = FALSE)
param_df_genexpr$seed <- random_integers
param_df_genexpr$save_path <- file.path(data_effect_def,
                                        paste("genexpr",
                                              paste(param_df_genexpr$seed, "rds", sep = "."),
                                              sep = "/"))
# ==============================
# Protein expression parameters
# ==============================
#
param_df_proexpr <- expand.grid(delta.methyl = c(0, 0, 0, 0, 0), 
                                delta.protein = c(0, 1000, 2000, 3000, 4000),
                                delta.expr = c(0, 0, 0, 0, 0)
                                )
# Add seeds
set.seed(123)
random_integers <- sample(1:2000, nrow(param_df_proexpr), replace = FALSE)
param_df_proexpr$seed <- random_integers
param_df_proexpr$save_path <- file.path(data_effect_def,
                                        paste("proexpr",
                                              paste(param_df_proexpr$seed, "rds", sep = "."),
                                              sep = "/"))
param_df_proexpr <- param_df_proexpr[30:50, ]
