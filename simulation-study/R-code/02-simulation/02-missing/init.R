source("../init.R", chdir = TRUE)
# ==============================================================================
# Modality directories for the missing-case scenarios
# ==============================================================================
#
# Methyl
data_mis_me_dir <- file.path(data_missing_dir, "01-methyl")
data_mis_me_data_dir <- file.path(data_mis_me_dir, "data")
data_mis_me_train_dir <- file.path(data_mis_me_dir, "train")
# Methyl-Genexpr
data_mis_mege_dir <- file.path(data_missing_dir, "02-methyl-genexpr")
data_mis_mege_data_dir <- file.path(data_mis_mege_dir, "data")
data_mis_mege_train_dir <- file.path(data_mis_mege_dir, "train")
# Methyl-Genexpr-Proexpr
data_mis_megepro_dir <- file.path(data_missing_dir, "03-methyl-genexpr-proexpr")
data_mis_megepro_data_dir <- file.path(data_mis_megepro_dir, "data")
data_mis_megepro_train_dir <- file.path(data_mis_megepro_dir, "train")

dir.create(data_mis_me_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_mis_me_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_mis_me_train_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(data_mis_mege_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_mis_mege_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_mis_mege_train_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(data_mis_megepro_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_mis_megepro_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_mis_megepro_train_dir, showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# Registries for independent differentially expressed markers
# ==============================================================================
#
# Methyl
reg_mis_me_dir <- file.path(reg_missing_dir, "01-methyl")
reg_mis_me_data_dir <- file.path(reg_mis_me_dir, "data")
reg_mis_me_train_dir <- file.path(reg_mis_me_dir, "train")
reg_mis_me_perf_dir <- file.path(reg_mis_me_dir, "perf")
# Methyl-Genexpr
reg_mis_mege_dir <- file.path(reg_missing_dir, "02-methyl-genexpr")
reg_mis_mege_data_dir <- file.path(reg_mis_mege_dir, "data")
reg_mis_mege_train_dir <- file.path(reg_mis_mege_dir, "train")
reg_mis_mege_perf_dir <- file.path(reg_mis_mege_dir, "perf")
# Methyl-Genexpr-Proexpr
reg_mis_megepro_dir <- file.path(reg_missing_dir, "03-methyl-genexpr-proexpr")
reg_mis_megepro_data_dir <- file.path(reg_mis_megepro_dir, "data")
reg_mis_megepro_train_dir <- file.path(reg_mis_megepro_dir, "train")
reg_mis_megepro_perf_dir <- file.path(reg_mis_megepro_dir, "perf")

dir.create(reg_mis_me_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_me_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_me_train_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_me_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(reg_mis_mege_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_mege_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_mege_train_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_mege_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(reg_mis_megepro_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_megepro_data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_megepro_train_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(reg_mis_megepro_perf_dir, showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# Results for independent differentially expressed markers
# ==============================================================================
#
# Methyl
res_mis_me_dir <- file.path(res_missing_dir, "01-methyl")
res_mis_me_perf_dir <- file.path(res_mis_me_dir, "perf")
# Methyl-Genexpr
res_mis_mege_dir <- file.path(res_missing_dir, "02-methyl-genexpr")
res_mis_mege_perf_dir <- file.path(res_mis_mege_dir, "perf")
# Methyl-Genexpr-Proexpr
res_mis_megepro_dir <- file.path(res_missing_dir, "03-methyl-genexpr-proexpr")
res_mis_megepro_perf_dir <- file.path(res_mis_megepro_dir, "perf")

dir.create(res_mis_me_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(res_mis_me_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(res_mis_mege_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(res_mis_mege_perf_dir, showWarnings = FALSE, recursive = TRUE)

dir.create(res_mis_megepro_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(res_mis_megepro_perf_dir, showWarnings = FALSE, recursive = TRUE)
