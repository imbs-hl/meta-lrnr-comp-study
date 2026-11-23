# init.R
# Initialization script for the TCGA interconnect use case project.
# Defines project paths, loads helper functions, and attaches required libraries

# ------------------------------------------------------------
# Determine the project root directory
# ------------------------------------------------------------
.libPaths(c("/home/bleskina/R-pkg", .libPaths() ))

project_root <- normalizePath(".") 

result_project_root <- "/imbs/projects/p23048/interconnect_use_case/tcga" 
scripts_path <- file.path(project_root, "scripts")
functions_path <- file.path(project_root, "R_functions")


data_path <- file.path(result_project_root, "data") 
mae_path <- file.path(data_path, "mae") 
datasets_path <- file.path(data_path, "datasets") 
results_path <- file.path(result_project_root, "results") 
registry_path <- file.path(result_project_root, "registries") 


results_ranger_path <- file.path(results_path, "ranger")
results_cobra_path <- file.path(results_path, "cobra")
results_best_path <- file.path(results_path, "best")
results_wa_path <- file.path(results_path, "wa")
results_lasso_path <- file.path(results_path, "lasso") 
results_lr_path <- file.path(results_path, "lr") 
results_ref_priolasso_miss_path <- file.path(results_path, "priolasso_miss") 
results_ref_bf_path <- file.path(results_path, "ref_bf")
results_ref_diablo_path <- file.path(results_path, "ref_diablo")
results_ref_srf_25_8_path <- file.path(results_path, "ref_srf_25_8")
results_ref_srf_25_8_miss_path <- file.path(results_path, "ref_srf_miss_25_8")



# ------------------------------------------------------------
# Define data file paths
# ------------------------------------------------------------
data_list_file <- file.path(data_path,
                            "datasets/data_list.RData")
info_cl_var_file <- file.path(data_path,
                              "info_target_variables.csv")



# ------------------------------------------------------------
# Load custom helper functions
# ------------------------------------------------------------

files <- dir(functions_path, pattern = ".R*", full.names = TRUE)
if (length(files) > 0) {
  print(paste("loading", length(files), "file(s) ..."))
  for (f in files) {
    source(f)
  }
}

# ------------------------------------------------------------
# Ensure required data directories exist
# ------------------------------------------------------------

create_dir(data_path)
create_dir(mae_path)
create_dir(datasets_path)
create_dir(results_path)
create_dir(results_cobra_path)
create_dir(results_ranger_path)
create_dir(results_best_path)
create_dir(results_wa_path)
create_dir(results_lasso_path) 
create_dir(results_lr_path) 


create_dir(results_ref_bf_path)
create_dir(results_ref_diablo_path)
create_dir(results_ref_priolasso_miss_path)
create_dir(results_ref_srf_25_8_path)
create_dir(results_ref_srf_25_8_miss_path)



#############################################################
# Package installation
# Run these commands once if the packages are not already installed.
#############################################################
# -----------------------------------------------------------------------------
# Package installation
# Run these commands once if the packages are not already installed.
# -----------------------------------------------------------------------------
# install.packages("UpSetR")
# install.packages("plyr")
# install.packages("visdat")
# install.packages("dplyr")
# install.packages("knitr")
# install.packages("rio")
# install.packages("ggplot2")
# install.packages("ranger")
# install.packages("caret")
# install.packages("pROC")
# install.packages("kableExtra")
# install.packages("fuseMLR")
# install.packages("Boruta")
# install.packages("data.table")
# install.packages("tidyr")
# install.packages("DT")
# install.packages("glmnet")
# install.packages("blockForest")
# install.packages("prioritylasso")


# install.packages("batchtools")
# install.packages("readr")

# Bioconductor packages
 # if (!requireNamespace("BiocManager", quietly = TRUE)) {
 #   install.packages("BiocManager")
 # }
 # BiocManager::install("curatedTCGAData")
 # BiocManager::install("MultiAssayExperiment")
 # BiocManager::install("SummarizedExperiment")
 # BiocManager::install("RaggedExperiment")
 # BiocManager::install("TCGAutils")
 # BiocManager::install("mixOmics")


library(curatedTCGAData)
library(MultiAssayExperiment)
library(SummarizedExperiment)
library(RaggedExperiment)
library(TCGAutils)
library(UpSetR)
library(grid)
library(plyr)
library(visdat)
library(dplyr)
library(knitr)
library(rio)
library(ggplot2)
library(ranger)
library(caret)
library(pROC)
library(kableExtra)
library(fuseMLR)
library(Boruta)
library(data.table)
library(tidyr)
library(DT)
library(glmnet)
library(blockForest)
library(mixOmics)
library(prioritylasso)


# batchtools paths and parameter tables, as in the simulation study.
working_dir <- project_root
code_dir <- project_root
interactive_session <- FALSE

# ------------------------------------------------------------
## batchtools' configurations     
# ------------------------------------------------------------
##
if(!interactive_session){
  ## Provide a configuration and a template file
  ## Example: template <- file.path(code_dir, "batchtools-config/.batchtools.slurm.tmpl")
  config_file <- file.path(code_dir, "batchtools-config/batchtools.conf.R")
  template <- file.path(code_dir, "batchtools-config/.batchtools.slurm.tmpl")
  ## (e.g. SLURM) Node, partition and account (See batchtools for details)
  nodename <- "localhost"
  partition <- "prio"
  account <- "p23048"
} else {
  ## Do not modify this "else" block!
  config_file <- file.path(code_dir, "batchtools-config/batchtools.multicore.R")
  template <- nodename <- partition <- account <- NULL
}
dir.create(registry_path, recursive = TRUE, showWarnings = FALSE)

tcga_methods <- list(
  `train_rf` = list(input = "data_list_cv_folds.rds",
                    output = "ranger",
                    fun = "train_rf"), 
    
    `train_best` = list(input = "ranger",
                        output = "best",
                        fun = "train_best"),
    
    `train_wa` = list(input = "ranger",
                      output = "wa",
                      fun = "train_wa"),
    
    `train_cobra` = list(input = "ranger",
                         output = "cobra",
                         fun = "train_cobra"),
    
    `train_lasso` = list(input = "ranger",
                         output = "lasso",
                         fun = "train_lasso"),
  
    `train_lr` = list(input = "ranger",
                      output = "lr",
                      fun = "train_lr"), 
  
    `train_ref_bf` = list(input = "data_list_cv_folds_cc.rds",
                          output = "ref_bf",
                          fun = "train_ref_bf"),
  
    `train_ref_diablo` = list(input = "data_list_cv_folds_miss.rds",
                              output = "ref_diablo",
                              fun = "train_ref_diablo"), 
    
   `train_ref_priolasso_miss` = list(input = "data_list_cv_folds_miss.rds",
                                     output = "priolasso_miss",
                                     fun = "train_ref_priolasso_miss"), 
    
   `train_ref_srf` = list(input = "data_list_cv_folds_cc.rds",
                          output = "ref_srf_25_8", 
                          fun = "train_ref_srf"), 
  
  `train_ref_srf_miss` = list(input = "data_list_cv_folds_miss.rds",
                              output = "ref_srf_miss_25_8",
                              fun = "train_ref_srf_miss"))
tcga_param_data <- list()

# train_rf
tcga_rf_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = rep(file.path(datasets_path, "data_list_cv_folds.rds"), 4L),
  output_file = file.path(results_path, "ranger", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_rf"]] <- tcga_rf_param_data

# train_best
tcga_best_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = file.path(results_ranger_path,
                         "diseases", 
                         sprintf("disease_%02d.rds", seq_len(4L))),

  output_file = file.path(results_path, "best", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_best"]] <- tcga_best_param_data

# train_wa
tcga_wa_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = file.path(results_ranger_path,"diseases",
                         sprintf("disease_%02d.rds", seq_len(4L))),
  output_file = file.path(results_path, "wa", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_wa"]] <- tcga_wa_param_data

# train_cobra
tcga_cobra_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = file.path(results_ranger_path,"diseases",
                         sprintf("disease_%02d.rds", seq_len(4L))),
  output_file = file.path(results_path, "cobra", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_cobra"]] <- tcga_cobra_param_data

# train_lasso
tcga_lasso_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = file.path(results_ranger_path,"diseases",
                         sprintf("disease_%02d.rds", seq_len(4L))),
  output_file = file.path(results_path, "lasso", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_lasso"]] <- tcga_lasso_param_data

# train_lr
tcga_lr_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = file.path(results_ranger_path,"diseases",
                         sprintf("disease_%02d.rds", seq_len(4L))),
  output_file = file.path(results_path, "lr", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_lr"]] <- tcga_lr_param_data

# train_ref_bf
tcga_ref_bf_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = rep(file.path(datasets_path, "data_list_cv_folds_cc.rds"), 4L),
  output_file = file.path(results_path, "ref_bf", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_ref_bf"]] <- tcga_ref_bf_param_data

# train_ref_diablo
tcga_ref_diablo_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = rep(file.path(datasets_path, "data_list_cv_folds_miss.rds"), 4L),
  output_file = file.path(results_path, "ref_diablo", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_ref_diablo"]] <- tcga_ref_diablo_param_data


# train_ref_priolasso_miss
tcga_ref_priolasso_miss_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = rep(file.path(datasets_path, "data_list_cv_folds_miss.rds"), 4L),
  output_file = file.path(results_path, "priolasso_miss", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_ref_priolasso_miss"]] <- tcga_ref_priolasso_miss_param_data

# train_ref_srf
tcga_ref_srf_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = rep(file.path(datasets_path, "data_list_cv_folds_cc.rds"), 4L),
  output_file = file.path(results_path, "ref_srf_25_8", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_ref_srf"]] <- tcga_ref_srf_param_data

# train_ref_srf_miss
tcga_ref_srf_miss_param_data <- data.frame(
  nam = seq_len(4L),
  input_file = rep(file.path(datasets_path, "data_list_cv_folds_miss.rds"), 4L),
  output_file = file.path(results_path, "ref_srf_miss_25_8", "diseases",
                          sprintf("disease_%02d.rds", seq_len(4L))))
tcga_param_data[["train_ref_srf_miss"]] <- tcga_ref_srf_miss_param_data

