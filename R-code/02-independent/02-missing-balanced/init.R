source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
indep_missbalanced_me_dir <- file.path(data_indep_missbalanced_dir, "me")
indep_missbalanced_megepro_dir <- file.path(data_indep_missbalanced_dir,
                                                    "mege")
indep_missbalanced_megepro_dir <- file.path(
  data_indep_missbalanced_dir,
  "megepro")
dir.create(indep_missbalanced_me_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_missbalanced_mege_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_missbalanced_megepro_dir,
           showWarnings = FALSE,
           recursive = TRUE)

# ==============================================================================
# Registries for independent differentially expressed markers
# ==============================================================================
#
reg_indep_missbalanced_me <- file.path(reg_indep_missbalanced_dir, "me")
reg_indep_missbalanced_megepro <- file.path(reg_independent_dir, "megepro")
reg_indep_missbalanced_megepro <- file.path(reg_independent_dir, "megepro")
dir.create(reg_indep_missbalanced_me, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_indep_missbalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
dir.create(reg_indep_missbalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
