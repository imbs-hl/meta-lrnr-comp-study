source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
dep_missunbalanced_me_dir <- file.path(data_dep_missunbalanced_dir, "me")
dep_missunbalanced_mege_dir <- file.path(data_dep_missunbalanced_dir,
                                                    "mege")
dep_missunbalanced_megepro_dir <- file.path(
  data_dep_missunbalanced_dir,
  "megepro")
dir.create(dep_missunbalanced_me_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_missunbalanced_mege_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_missunbalanced_megepro_dir,
           showWarnings = FALSE,
           recursive = TRUE)

# ==============================================================================
# Registries for dependent differentially expressed markers
# ==============================================================================
#
reg_dep_missunbalanced_me <- file.path(reg_dep_missunbalanced_dir, "me")
reg_dep_missunbalanced_mege <- file.path(reg_dep_missunbalanced_dir, "mege")
reg_dep_missunbalanced_megepro <- file.path(reg_dep_missunbalanced_dir, "megepro")
dir.create(reg_dep_missunbalanced_me, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_dep_missunbalanced_mege, showWarnings = FALSE, 
           recursive = TRUE)
dir.create(reg_dep_missunbalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
