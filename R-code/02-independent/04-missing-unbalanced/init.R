source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
indep_missunbalanced_me_dir <- file.path(data_indep_missunbalanced_dir, "me")
indep_missunbalanced_mege_dir <- file.path(data_indep_missunbalanced_dir,
                                                    "mege")
indep_missunbalanced_megepro_dir <- file.path(
  data_indep_missunbalanced_dir,
  "megepro")
dir.create(indep_missunbalanced_me_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_missunbalanced_mege_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(indep_missunbalanced_megepro_dir,
           showWarnings = FALSE,
           recursive = TRUE)

# ==============================================================================
# Registries for independent differentially expressed markers
# ==============================================================================
#
reg_indep_missunbalanced_me <- file.path(reg_indep_missunbalanced_dir, "me")
reg_indep_missunbalanced_mege <- file.path(reg_indep_missunbalanced_dir, "mege")
reg_indep_missunbalanced_megepro <- file.path(reg_indep_missunbalanced_dir, "megepro")
dir.create(reg_indep_missunbalanced_me, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_indep_missunbalanced_mege, showWarnings = FALSE, 
           recursive = TRUE)
dir.create(reg_indep_missunbalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
