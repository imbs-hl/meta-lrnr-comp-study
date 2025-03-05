# install.packages("fuseMLR")
# install.packages("data.table")
# install.packages("ggplot2")
# install.packages("batchtools")
# install.packages("InterSIM")
# install.packages(this.path)

# Install required package to estimate the empirical correlation matrices.
# install.packages(corpcor)
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("curatedTCGAData")
# BiocManager::install("rtracklayer", force = TRUE)
# BiocManager::install("GenomicFeatures", force = TRUE)
# BiocManager::install("TCGAbiolinks")
# BiocManager::install("GenomicRanges")
# BiocManager::install("TxDb.Hsapiens.UCSC.hg38.knownGene")
# install.packages("ggnewscale")
# BiocManager::install("enrichplot")
# BiocManager::install("ChIPseeker")
# BiocManager::install("org.Hs.eg.db")
# BiocManager::install("IlluminaHumanMethylation450kanno.ilmn12.hg19")
# BiocManager::install("biomaRt")

library(fuseMLR)
library(data.table)
library(ggplot2)
library(batchtools)
library(InterSIM)
library(this.path)

# Load required package to estimate the empirical correlation matrices.
library(corpcor)
library(curatedTCGAData)
library(MultiAssayExperiment)
library(TCGAutils)
library(TCGAbiolinks)
library(GenomicRanges)
library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(ChIPseeker)
library(AnnotationDbi)
library(org.Hs.eg.db)
library(IlluminaHumanMethylation450kanno.ilmn12.hg19)
library(biomaRt)

# The project directory is the absolute path to meta-lrnr-comp-study directory.
proc_dir <- "~/projects/interconnect-publications/meta-lrnr-comp-study"
working_dir <- "/imbs/projects/p23048/meta-lrnr-comp-study"
code_dir <- file.path(proc_dir, "R-code")
data_dir <- file.path(working_dir, "data")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
data_tcga <- file.path(data_dir, "tcga")
dir.create(data_tcga, showWarnings = FALSE, recursive = TRUE)
result_dir <- file.path(working_dir, "results")
dir.create(result_dir, showWarnings = FALSE, recursive = TRUE)
image_dir <- file.path(working_dir, "images")

# Simulation directories
data_simulation <- file.path(data_dir, "simulation")
dir.create(data_simulation, showWarnings = FALSE, recursive = TRUE)

data_effect_def <- file.path(data_dir, "effect_def")
dir.create(data_effect_def, showWarnings = FALSE, recursive = TRUE)

