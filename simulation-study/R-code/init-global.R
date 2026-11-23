#############################################################
## Set global configurations
#############################################################
## Note: This part need to be checked by the user to ensure variables match with 
## indications mentioned in the Readme file.

.libPaths(c("/home/bleskina/R-pkg", .libPaths() ))

## Do the scripts will be run in testing or in normal mode?
testing_mode <- FALSE

## Do the jobs should be run in interactive session?
interactive_session <- FALSE

## Set the main directory
if(!("this.path" %in% installed.packages())){
  install.packages("this.path")
}
# Proc directory
proc_dir <- "~/interconnect/scripts/meta-lrnr-comp-study-2026/simulation-study"

# The project directory
working_dir <- "/imbs/projects/p23048/meta-lrnr-comp-study-2026"

code_dir <- file.path(proc_dir, "R-code")

## Set your current working directory to "R-code" (setwd("path/to/R-code"))

## Note: If you are in interactive session, you are done with configuration. 
## Otherwise, configure your batchtools system.

#############################################################
## batchtools' configurations     
#############################################################
##
if(!interactive_session){
  ## Provide a configuration and a template file
  ## Example: template <- file.path(code_dir, "batchtools-config/.batchtools.slurm.tmpl")
  config_file <- file.path(code_dir, "batchtools-config/batchtools.conf.R")
  template <- file.path(code_dir, "batchtools-config/.batchtools.slurm.tmpl")
  ##  (e.g. SLURM) Node, partition and account (See batchtools for details)
  nodename <- "localhost"
  partition <- "prio"
  account <- "p23048"
} else {
  ## Do not modify this "else" block!
  config_file <- file.path(code_dir, "batchtools-config/batchtools.multicore.R")
  template <- nodename <- partition <- account <- NULL
}
## Batchtools wrapper. Do not motify this line
source(file.path(file.path(code_dir, "functions"),
                 "batchtoolswrapper.R"), chdir = TRUE)

#############################################################
# Package installation
# Run these commands once if the packages are not already installed.
#############################################################

# install.packages("fuseMLR")
# install.packages("data.table")
# install.packages("ggplot2")
# install.packages("batchtools")
# install.packages("InterSIM")
# install.packages("this.path")
# install.packages("MASS")
# install.packages("mgcv")
# install.packages("MLmetrics")
# install.packages("prioritylasso")
# install.packages("Boruta")
# install.packages("readxl") 

# Install required package to estimate the empirical correlation matrices.
# install.packages("corpcor")
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("MultiAssayExperiment")
# BiocManager::install("AnnotationDbi")
# BiocManager::install("curatedTCGAData")
# BiocManager::install("TxDb.Hsapiens.UCSC.hg19.knownGene")
# BiocManager::install("ChIPseeker")
# BiocManager::install("org.Hs.eg.db")
# BiocManager::install(c("IlluminaHumanMethylation450kanno.ilmn12.hg19"))
# BiocManager::install("biomaRt")
# BiocManager::install("minfi")


library(fuseMLR)
library(data.table)
library(ggplot2)
library(batchtools)
library(this.path)
library(MASS)
library(mgcv)
library(MLmetrics)
library(gridExtra)
library(grid)
library(prioritylasso)
library(Boruta)
library(tidyverse)
library(InterSIM)
library(readxl)
# Load required package to estimate the empirical correlation matrices.
library(BiocManager)
library(curatedTCGAData)
library(corpcor)
library(MultiAssayExperiment)
library(AnnotationDbi)
library(org.Hs.eg.db)
library(minfi)
library(IlluminaHumanMethylation450kanno.ilmn12.hg19) 
library(IlluminaHumanMethylation450kmanifest)
library(TxDb.Hsapiens.UCSC.hg19.knownGene) 
library(ChIPseeker)
library(data.table)


function_dir <- file.path(code_dir, "functions")
dir.create(function_dir, showWarnings = FALSE, recursive = TRUE)

data_dir <- file.path(working_dir, "data")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
result_dir <- file.path(working_dir, "results")
dir.create(result_dir, showWarnings = FALSE, recursive = TRUE)
image_dir <- file.path(working_dir, "images")
dir.create(image_dir, showWarnings = FALSE, recursive = TRUE)
registry_dir <- file.path(working_dir, "registry")
dir.create(registry_dir, showWarnings = FALSE, recursive = TRUE)

# Simulation directories

# Preprocessing: we compute data for simulation with InterSIM package
# Data
data_tcga <- file.path(data_dir, "01-preparation")
data_tcga_ext <- file.path(data_tcga, "external")
data_tcga_dat <- file.path(data_tcga, "data")
dir.create(data_tcga, showWarnings = FALSE, recursive = TRUE)
dir.create(data_tcga_ext, showWarnings = FALSE, recursive = TRUE)
dir.create(data_tcga_dat, showWarnings = FALSE, recursive = TRUE)

# Processing: simulation
data_simulation <- file.path(data_dir, "02-simulation")
dir.create(data_simulation, showWarnings = FALSE, recursive = TRUE)

# Registry dir
reg_simulation <- file.path(registry_dir, "02-simulation")
dir.create(reg_simulation, showWarnings = FALSE, recursive = TRUE)

# Results dir
res_simulation <- file.path(result_dir, "02-simulation")
dir.create(res_simulation, showWarnings = FALSE, recursive = TRUE)

