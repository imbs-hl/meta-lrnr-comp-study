#########################################################
# TCGA: Prepare MultiAssayExperiment objects
# Purpose: Download and prepare TCGA data and identify
# suitable binary target variables.
# Run from: tcga-use-case-study/scripts
#########################################################

## Load project paths, functions, and packages.
source("../init.R", chdir = TRUE)

omics = c("RNASeq2GeneNorm", "miRNASeqGene", "RPPAArray",
           "Mutation")


# Select the cancer types used in the study
data(diseaseCodes)

info_disease_use = subset(
  diseaseCodes,
  SubtypeData == "Yes" &
    (Study.Abbreviation %in% c("PRAD", "LGG", "STAD")))

disease_use = info_disease_use$Study.Abbreviation

# Download and prepare one MultiAssayExperiment per cancer type.
# For each dataset, prepare_mae_object():
# - retains primary tumor samples;
# - removes replicate samples;
# - removes selected administrative and patient variables
for (d in disease_use) {
  prepare_mae_object(disease = d,
                     omics = omics,
                     mae.dir = mae_path)
  }

## Load mae objects
mae_l = load_mae_objects(mae.dir = mae_path)

# Identify clinical variables with:
# binary  
# at least 40 patients
# balanced (minor class maximal 40%)  
# not gender or information about availability of specific data type

info_var = identify_binary_phenotypes_l(mae_l)

# Exclude variables that are not used as outcomes.
var_rm = c("gender", "gender.x", "gender.y", "Gender", "RPPA",
           "Grade", "TP53.mutation")
info_var = subset(info_var, 
                  !(variable %in% var_rm))

rio::export(info_var,
       file = file.path(data_path, "info_target_variables.csv"))
