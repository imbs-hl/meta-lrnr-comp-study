source("../init-global.R", chdir = TRUE)
source(file.path(function_dir, "simuldata.R"))
source(file.path(function_dir, "single-run-best.R"))
source(file.path(function_dir, "single-run-rf.R"))
source(file.path(function_dir, "single-run-lasso.R"))
source(file.path(function_dir, "single-run-lr.R"))
source(file.path(function_dir, "single-run-cobra.R"))
source(file.path(function_dir, "single-run-wa.R"))

# ------------------------------------------------------------------------------
# Set directories for balanced scenarios
# ------------------------------------------------------------------------------
#
# Complete modalities: Dependently and differentially expressed markers
data_dep_combalanced_dir <- file.path(data_dependent_dir, "combalanced")
dir.create(data_dep_combalanced_dir, showWarnings = FALSE, recursive = TRUE)

# Missing modalities: Dependently and differentially expressed markers
data_dep_missbalanced_dir <- file.path(data_dependent_dir, "missbalanced")
dir.create(data_dep_missbalanced_dir, showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------------------------
# Set registires for balanced scenarios
# ------------------------------------------------------------------------------
#
# Complete modalities: Dependently and differentially expressed markers
reg_dep_combalanced_dir <- file.path(reg_dependent_dir, "combalanced")
dir.create(reg_dep_combalanced_dir, showWarnings = FALSE, recursive = TRUE)

# Missing modalities: Dependently and differentially expressed markers
reg_dep_missbalanced_dir <- file.path(reg_dependent_dir, "missbalanced")
dir.create(reg_dep_missbalanced_dir, showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------------------------
# Set directories for unbalanced scenarios
# ------------------------------------------------------------------------------
#
# Complete modalities: Dependently and differentially expressed markers
data_dep_comunbalanced_dir <- file.path(data_dependent_dir, "comunbalanced")
dir.create(data_dep_comunbalanced_dir, showWarnings = FALSE, recursive = TRUE)

# Missing modalities: Dependently and differentially expressed markers
data_dep_missunbalanced_dir <- file.path(data_dependent_dir, "missunbalanced")
dir.create(data_dep_missunbalanced_dir, showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------------------------
# Set registires for unbalanced scenarios
# ------------------------------------------------------------------------------
#
# Complete modalities: Dependently and differentially expressed markers
reg_dep_comunbalanced_dir <- file.path(reg_dependent_dir, "comunbalanced")
dir.create(reg_dep_comunbalanced_dir, showWarnings = FALSE, recursive = TRUE)

# Missing modalities: Dependently and differentially expressed markers
reg_dep_missunbalanced_dir <- file.path(reg_dependent_dir, "missunbalanced")
dir.create(reg_dep_missunbalanced_dir, showWarnings = FALSE, recursive = TRUE)
