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
# Dependent differentially expressed markers
data_dep_combalanced_dir <- file.path(data_dependent_dir, "combalanced")
dir.create(data_dep_combalanced_dir, showWarnings = FALSE, recursive = TRUE)
dep_combalanced_methyl_dir <- file.path(data_dep_combalanced_dir, "methyl")
dep_combalanced_methyl_genexpr_dir <- file.path(data_dep_combalanced_dir,
                                                "methyl_genexpr")
dep_combalanced_methyl_genexpr_proexpr_dir <- file.path(
  data_indep_combalanced_dir,
  "methyl_genexpr_proexpr")
dir.create(dep_combalanced_methyl_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_combalanced_methyl_genexpr_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_combalanced_methyl_genexpr_proexpr_dir,
           showWarnings = FALSE,
           recursive = TRUE)