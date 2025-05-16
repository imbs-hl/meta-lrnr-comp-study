source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
dep_missbalanced_me_dir <- file.path(data_dep_missbalanced_dir, "me")
dep_missbalanced_mege_dir <- file.path(data_dep_missbalanced_dir,
                                                    "mege")
dep_missbalanced_megepro_dir <- file.path(
  data_dep_missbalanced_dir,
  "megepro")
dir.create(dep_missbalanced_me_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_missbalanced_mege_dir,
           showWarnings = FALSE,
           recursive = TRUE)
dir.create(dep_missbalanced_megepro_dir,
           showWarnings = FALSE,
           recursive = TRUE)

# ==============================================================================
# Registries for dependent differentially expressed markers
# ==============================================================================
#
reg_dep_missbalanced_me <- file.path(reg_dep_missbalanced_dir, "me")
reg_dep_missbalanced_mege <- file.path(reg_dep_missbalanced_dir, "mege")
reg_dep_missbalanced_megepro <- file.path(reg_dep_missbalanced_dir, "megepro")
dir.create(reg_dep_missbalanced_me, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_dep_missbalanced_mege, showWarnings = FALSE, 
           recursive = TRUE)
dir.create(reg_dep_missbalanced_megepro, showWarnings = FALSE, 
           recursive = TRUE)
