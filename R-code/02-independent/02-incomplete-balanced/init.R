source("init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
indep_incombalanced_methyl_dir <- file.path(data_indep_incombalanced_dir, "methyl")
indep_incombalanced_methyl_genexpr_dir <- file.path(data_indep_incombalanced_dir,
                                                    "methyl_genexpr")
indep_incombalanced_methyl_genexpr_proexpr_dir <- file.path(
  data_indep_incombalanced_dir,
  "methyl_genexpr_proexpr")
dir.create(indep_incombalanced_methyl_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_incombalanced_methyl_genexpr_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_incombalanced_methyl_genexpr_proexpr_dir,
           showWarnings = FALSE,
           recursive = TRUE)