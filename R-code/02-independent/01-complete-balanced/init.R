source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the complete-case scenarios
# ==============================================================================
#
indep_combalanced_methyl_dir <- file.path(data_indep_combalanced_dir, "methyl")
indep_combalanced_methyl_genexpr_dir <- file.path(data_indep_combalanced_dir,
                                                  "methyl_genexpr")
indep_combalanced_methyl_genexpr_proexpr_dir <- file.path(
  data_indep_combalanced_dir,
  "methyl_genexpr_proexpr")
dir.create(indep_combalanced_methyl_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_combalanced_methyl_genexpr_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_combalanced_methyl_genexpr_proexpr_dir,
           showWarnings = FALSE,
           recursive = TRUE)