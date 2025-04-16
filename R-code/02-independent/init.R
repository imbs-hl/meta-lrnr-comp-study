source("../init-global.R", chdir = TRUE)
source(file.path(function_dir, "simuldata.R"))
source(file.path(function_dir, "single-run-best.R"))
source(file.path(function_dir, "single-run-rf.R"))
source(file.path(function_dir, "single-run-lasso.R"))
source(file.path(function_dir, "single-run-lr.R"))
source(file.path(function_dir, "single-run-cobra.R"))
source(file.path(function_dir, "single-run-wa.R"))

# ------------------------------------------------------------------------------
# Set directories for complete case and balanced scenarios
# ------------------------------------------------------------------------------
#
# Independent differentially expressed markers
data_indep_combalanced_dir <- file.path(data_independent_dir, "combalanced")
dir.create(data_indep_combalanced_dir, showWarnings = FALSE, recursive = TRUE)

# Dependent differentially expressed markers
data_indep_incombalanced_dir <- file.path(data_independent_dir, "incombalanced")
dir.create(data_indep_incombalanced_dir, showWarnings = FALSE, recursive = TRUE)