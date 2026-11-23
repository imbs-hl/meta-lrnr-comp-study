source("../init-global.R", chdir = TRUE)
source(file.path(function_dir, "simuldata.R"))
source(file.path(function_dir, "single-run-best.R"))
source(file.path(function_dir, "single-run-rf.R"))
source(file.path(function_dir, "single-run-lasso.R"))
source(file.path(function_dir, "single-run-lr.R"))
source(file.path(function_dir, "single-run-cobra.R"))
source(file.path(function_dir, "single-run-wa.R"))
source(file.path(function_dir, "single-run-priolasso.R"))
source(file.path(function_dir, "single-run-srf.R"))
source(file.path(function_dir, "single-run-srf-mis.R"))
source(file.path(function_dir, "single-run-bf.R"))
source(file.path(function_dir, "single-run-diablo_miss.R"))
source(file.path(function_dir, "calculate_performance.R"))
source(file.path(function_dir, "calculate_performance_ref.R"))
# ------------------------------------------------------------------------------
# Set directories for balanced scenarios
# ------------------------------------------------------------------------------
#
# Complete modalities:
data_complete_dir <- file.path(data_simulation, "01-complete")
dir.create(data_complete_dir, showWarnings = FALSE, recursive = TRUE)


# Missing modalities
data_missing_dir <- file.path(data_simulation, "02-missing")
dir.create(data_missing_dir, showWarnings = FALSE, recursive = TRUE)
# ------------------------------------------------------------------------------
# Set registires for balanced scenarios
# ------------------------------------------------------------------------------
#
# Complete modalities
reg_complete_dir <- file.path(reg_simulation, "01-complete")
dir.create(reg_complete_dir, showWarnings = FALSE, recursive = TRUE)
# 
# # Missing modalities
reg_missing_dir <- file.path(reg_simulation, "02-missing")
dir.create(reg_missing_dir, showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------------------------
# Set result for balanced scenarios
# ------------------------------------------------------------------------------
#
# Complete modalities
res_complete_dir <- file.path(res_simulation, "01-complete")
dir.create(res_complete_dir, showWarnings = FALSE, recursive = TRUE)
# 
# # Missing modalities
res_missing_dir <- file.path(res_simulation, "02-missing")
dir.create(res_missing_dir, showWarnings = FALSE, recursive = TRUE)







