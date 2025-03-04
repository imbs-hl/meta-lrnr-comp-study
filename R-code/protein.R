# This file contains pre-processing steps for transforming protein abundance data
# available the in Proteomics Data Commons data base into a useful format so that
# individual IDs match with TCGA individual IDs. We use the dataset from the 
# TCGA Breast Cancer Proteome study with more than 120 individuals and approxi-
# mately 10,000 protein expression information. To re-use this file, download
# and save the data in the directory specified by the data_tcga variable defined
# in the init-global file.
# URL: https://pdc.cancer.gov/pdc/browse/filters/pdc_study_id:PDC000173%7CPDC000174%7CPDC000290%7CPDC000291
# File names:
# itraq: TCGA_Breast_BI_Proteome.itraq.tsv
# meta: CPTAC_TCGA_BreastCancer_select_clinical_data_r1.xlsx
# The following code is inspired by the code available at:
# https://github.com/hussius/TCGA_proteomics_tutorial/blob/master/TCGA_protein_tutorial.ipynb
library("data.table")
library("readxl") # Use install.packages("readxl") to install if not existing.

itraq <- data.table::fread(file.path(data_tcga,
                                     "TCGA_Breast_BI_Proteome.itraq.tsv"))
meta <- read_excel(file.path(data_tcga,
                             "CPTAC_TCGA_BreastCancer_select_clinical_data_r1.xlsx"),
                   sheet = 1, skip = 3)
meta2 <- read_excel(file.path(data_tcga, 
                              "CPTAC_TCGA_BreastCancer_select_clinical_data_r1.xlsx"),
                    sheet = 2, skip = 5)

itraq[1:6, 1:6]
N <- ncol(itraq)
itraq[1:6, (N-6):N]


# Select only the part of the matrix that contains log2 ratios for gene products.
itraq.num <- itraq[4:nrow(itraq), 1:(N-5)]
# Select the "unshared log ratio" columns 
itraq.log <- as.matrix(as.data.frame(itraq.num)[ , 
                                  seq(3, ncol(itraq.num), by=2)])
incompl.meas <- which(is.na(itraq.log), arr.ind=TRUE)
if (nrow(incompl.meas)) {
  incompl.genesymb <- unique(incompl.meas[,1])
  itraq.log <- itraq.log[-incompl.genesymb,]
} else {
  itraq.log <- itraq.log
}

print(c(nrow(meta2), ncol(itraq.log)))

head(meta2)
table(meta2$`PAM50 mRNA`)
head(meta2$'Complete TCGA ID')
head(colnames(itraq.log))

# Get "short ID" from the metadata sample name format
get_id_from_pam_name <- function(id){
  a <- unlist(strsplit(id, "-"))
  return(paste(a[2], a[3], sep = "-"))
}
# Get "short ID" from the sample name format in the itraq.log matrix
get_id_from_itraq_name <- function(id){
  tmp <- unlist(strsplit(id, " "))[1]
  tmp2 <- unlist(strsplit(tmp, "-"))
  return(paste(tmp2[1], tmp2[2], sep="-"))
}

short_id <- NULL
for(long_id in colnames(itraq.log)){
  short_id[[long_id]] <- get_id_from_itraq_name(long_id)
  short_id[[long_id]] <- paste("TCGA-", 
                               short_id[[long_id]], 
                               sep = "")
}
head(short_id)

# Transform the itraq colnames
selected_names <- c("Gene", names(unlist(short_id)))
itraq_tcga <- itraq[ , ..selected_names]
for(nm in names(unlist(short_id))) {
  colnames(itraq_tcga)[colnames(itraq_tcga) == nm] <- unlist(short_id)[nm]
}
itraq_tcga <- itraq_tcga[complete.cases(itraq_tcga), ]
dim(itraq_tcga)

# Now save protein abundances with unique TCGA-ID format.
fwrite(x = itraq_tcga[-(1:4), ],
       file = file.path(data_tcga, "protein.txt"),
       sep = "\t")

