source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
dep_comunbalanced_me_dir <- file.path(data_dep_comunbalanced_dir, "me")
dep_comunbalanced_mege_dir <- file.path(data_dep_comunbalanced_dir,
                                                    "mege")
dep_comunbalanced_megepro_dir <- file.path(
  data_dep_comunbalanced_dir,
  "megepro")
dir.create(dep_comunbalanced_me_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_comunbalanced_mege_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_comunbalanced_megepro_dir,
           showWarnings = FALSE,
           recursive = TRUE)

# ==============================================================================
# Registries for dependent differentially expressed markers
# ==============================================================================
#
reg_dep_comunbalanced_me <- file.path(reg_dep_comunbalanced_dir, "me")
reg_dep_comunbalanced_mege <- file.path(reg_dep_comunbalanced_dir, "mege")
reg_dep_comunbalanced_megepro <- file.path(reg_dep_comunbalanced_dir, "megepro")
dir.create(reg_dep_comunbalanced_me, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_dep_comunbalanced_mege, showWarnings = FALSE, 
           recursive = TRUE)
dir.create(reg_dep_comunbalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
