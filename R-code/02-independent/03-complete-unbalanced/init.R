source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
indep_comunbalanced_me_dir <- file.path(data_indep_comunbalanced_dir, "me")
indep_comunbalanced_mege_dir <- file.path(data_indep_comunbalanced_dir,
                                                    "mege")
indep_comunbalanced_megepro_dir <- file.path(
  data_indep_comunbalanced_dir,
  "megepro")
dir.create(indep_comunbalanced_me_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_comunbalanced_mege_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_comunbalanced_megepro_dir,
           showWarnings = FALSE,
           recursive = TRUE)

# ==============================================================================
# Registries for independent differentially expressed markers
# ==============================================================================
#
reg_indep_comunbalanced_me <- file.path(reg_indep_comunbalanced_dir, "me")
reg_indep_comunbalanced_mege <- file.path(reg_indep_comunbalanced_dir, "mege")
reg_indep_comunbalanced_megepro <- file.path(reg_indep_comunbalanced_dir, "megepro")
dir.create(reg_indep_comunbalanced_me, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_indep_comunbalanced_mege, showWarnings = FALSE, 
           recursive = TRUE)
dir.create(reg_indep_comunbalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
