source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the incomplete-case scenarios
# ==============================================================================
#
# Methyl
data_com_me_dir <- file.path(data_complete_dir, "01-methyl")
data_com_me_data_dir <- file.path(data_com_me_dir, "data")
data_com_me_train_dir <- file.path(data_com_me_dir, "train")

# Methyl-Genexpr
data_com_mege_dir <- file.path(data_complete_dir, "02-methyl-genexpr")
data_com_mege_data_dir <- file.path(data_com_mege_dir, "data")
data_com_mege_train_dir <- file.path(data_com_mege_dir, "train")

# Methyl-Genexpr-Proexpr
data_com_megepro_dir <- file.path(data_complete_dir, "03-methyl-genexpr-proexpr")
data_com_megepro_data_dir <- file.path(data_com_megepro_dir, "data")
data_com_megepro_train_dir <- file.path(data_com_megepro_dir, "train")


dir.create(data_com_me_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_com_me_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_com_me_train_dir, showWarnings = FALSE, recursive = TRUE)


dir.create(data_com_mege_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_com_mege_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_com_mege_train_dir, showWarnings = FALSE, recursive = TRUE)



dir.create(data_com_megepro_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_com_megepro_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_com_megepro_train_dir, showWarnings = FALSE, recursive = TRUE)


# ==============================================================================
# Registries for independent differentially expressed markers
# ==============================================================================
#

# Methyl
reg_com_me_dir <- file.path(reg_complete_dir, "01-methyl")
reg_com_me_data_dir <- file.path(reg_com_me_dir, "data")
reg_com_me_train_dir <- file.path(reg_com_me_dir, "train")
reg_com_me_perf_dir <- file.path(reg_com_me_dir, "perf")
# Methyl-Genexpr
reg_com_mege_dir <- file.path(reg_complete_dir, "02-methyl-genexpr")
reg_com_mege_data_dir <- file.path(reg_com_mege_dir, "data")
reg_com_mege_train_dir <- file.path(reg_com_mege_dir, "train")
reg_com_mege_perf_dir <- file.path(reg_com_mege_dir, "perf")
# Methyl-Genexpr-Proexpr
reg_com_megepro_dir <- file.path(reg_complete_dir, "03-methyl-genexpr-proexpr")
reg_com_megepro_data_dir <- file.path(reg_com_megepro_dir, "data")
reg_com_megepro_train_dir <- file.path(reg_com_megepro_dir, "train")
reg_com_megepro_perf_dir <- file.path(reg_com_megepro_dir, "perf")

dir.create(reg_com_me_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_me_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_me_train_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_me_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(reg_com_mege_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_mege_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_mege_train_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_mege_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(reg_com_megepro_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_megepro_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_megepro_train_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_com_megepro_perf_dir, showWarnings = FALSE, recursive = TRUE)


# ==============================================================================
# Results for independent differentially expressed markers
# ==============================================================================
#
# Methyl
res_com_me_dir <- file.path(res_complete_dir, "01-methyl")
res_com_me_perf_dir <- file.path(res_com_me_dir, "perf")
# Methyl-Genexpr
res_com_mege_dir <- file.path(res_complete_dir, "02-methyl-genexpr")
res_com_mege_perf_dir <- file.path(res_com_mege_dir, "perf")
# Methyl-Genexpr-Proexpr
res_com_megepro_dir <- file.path(res_complete_dir, "03-methyl-genexpr-proexpr")
res_com_megepro_perf_dir <- file.path(res_com_megepro_dir, "perf")

dir.create(res_com_me_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(res_com_me_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(res_com_mege_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(res_com_mege_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(res_com_megepro_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(res_com_megepro_perf_dir, showWarnings = FALSE, recursive = TRUE)

