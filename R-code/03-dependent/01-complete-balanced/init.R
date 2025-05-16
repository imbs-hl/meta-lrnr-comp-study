source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
dep_combalanced_me_dir <- file.path(data_dep_combalanced_dir, "me")
dep_combalanced_mege_dir <- file.path(data_dep_combalanced_dir,
                                                    "mege")
dep_combalanced_megepro_dir <- file.path(
  data_dep_combalanced_dir,
  "megepro")
dir.create(dep_combalanced_me_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_combalanced_mege_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_combalanced_megepro_dir,
           showWarnings = FALSE,
           recursive = TRUE)

# ==============================================================================
# Registries for independent differentially expressed markers
# ==============================================================================
#
reg_dep_combalanced_me <- file.path(reg_dep_combalanced_dir, "me")
reg_dep_combalanced_mege <- file.path(reg_dep_combalanced_dir, "mege")
reg_dep_combalanced_megepro <- file.path(reg_dep_combalanced_dir, "megepro")
dir.create(reg_dep_combalanced_me, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_dep_combalanced_mege, showWarnings = FALSE, 
           recursive = TRUE)
dir.create(reg_dep_combalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
