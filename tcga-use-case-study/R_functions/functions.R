###############################################################################
# Helper functions for the TCGA use case study.
#
# These functions prepare and load MultiAssayExperiment objects, identify
# suitable binary outcomes, load prepared datasets, and create directories.
###############################################################################


rename_experiments <- function(mae, omics) {
  
  meta = metadata(colData(mae))
  
  no.exp = length(names(mae))
  for (o in omics) {
    ind = grep(o, names(mae))
    if (length(ind) != 1) {
      stop(paste("omics", o, "not found"))
    }
    mae.single = mae[, , ind]
    names(mae.single) = o
    mae = c(mae, mae.single)
  }
  mae = mae[, , -c(1:no.exp)]
  metadata(colData(mae)) = meta
  return(mae)
}



remove_replicates <- function(mae) {
  
  ## extract mapping between samples and subjects
  sample.info = as.data.frame(sampleMap(mae))

  ## remove replicates for each assay separately
  assays = names(assays(mae))
  
  for (a in assays) {
    sample.info.a = subset(sample.info, assay == a)
    tab = table(sample.info.a$primary)
    id.keep = names(tab)[tab == 1]
    
    if (length(id.keep) != nrow(sample.info.a)) {
      message(paste("removing duplicates in assay", a))
      mae.a = mae[, , a]
      mae.a = mae.a[, id.keep, ]
      mae = c(mae[, , setdiff(assays, a)], mae.a)
    }
  }
  return(mae)
}

prepare_mae_object <- function(disease, omics, mae.dir) {
  
  ## get info about mae object
  info.dis = curatedTCGAData(
    diseaseCode = disease,
    assays = omics,
    version = "2.0.1")
  
  ## check if all omics data sets are available
  if (nrow(info.dis) < length(omics)) {
    stop("not all assays were found!")
  } else if (nrow(info.dis) > length(omics)) {
    warning("more assays were found!")
  }
  
  ## indices for each assay type
  ind.omics = lapply(
    omics,
    function(x) {
      grep(x, info.dis$title)})
  names(ind.omics) = omics

  ## identify assay types with more than 1
  len = sapply(ind.omics, length)
  omics.use = omics
  names(omics.use) = omics
  omics.check = names(len)[len > 1]
  if (length(omics.check) > 0) {
    for (o in omics.check) {
      if (o == "RNASeq2GeneNorm") {
        omics.use[o] = "RNASeq2GeneNorm_illuminahiseq"
      }
    }  
  }

  ## download mae object
  assay.names = paste0(omics.use, "*")
  
  mae.all.orig = curatedTCGAData(
    diseaseCode = disease,
    assays = assay.names,
#  assays = "RNASeq2GeneNorm_illuminahiseq",
    version = "2.0.1",
    dry.run = FALSE)
  
  ## rename experiments so that names are consistent across diseases
  ## complicated (see https://support.bioconductor.org/p/112805/)
  mae.all = rename_experiments(mae = mae.all.orig, omics = omics)
  
  ## use only primary tumor samples
  mae = TCGAprimaryTumors(mae.all)
  
  ## merge replicated samples (averaging)
  ## takes a long time! for BRCA only replicates in mutation data
  mae = remove_replicates(mae)

  ## remove most of the patient variables
  pheno = colData(mae)
  pheno = pheno[, !grepl("^patient\\.|^admin\\.", colnames(pheno))]
  
  ## recode some information
  values.recode = c("Indeterminate", 
                    "Not Performed", 
                    "Performed but Not Available")
  pheno[pheno %in% values.recode] = NA
  colData(mae) = pheno
  
  ## save
  saveRDS(mae,
          file = file.path(mae.dir,
                           paste0("mae_", disease, ".rds")))
}


load_mae_objects <- function(mae.dir, pattern = ".rds") {
  
  files = dir(mae.dir,
              pattern = pattern,
              full.names = TRUE)
  mae.l = lapply(files, readRDS)
  names(mae.l) = gsub("mae_|\\.rds", "", basename(files))
  return(mae.l)
}

# get_stat <- function(mae) {
#   exp = experiments(mae)
#   c(no_patients = nrow(colData(mae)),
#     sapply(exp, nrow))
# }

identify_binary_phenotypes <- function(
    mae, 
    sample.size.min = 40, 
    freq.min = 0.4) {
  
  pheno = colData(mae)
  if (any(is.na(pheno$patientID))) {
    warning("Some patient ids are missing!")
  }
  
  info.var.use = NULL
  for (i in 1:ncol(pheno)) {
    var = na.omit(pheno[, i])
    if (length(var) > sample.size.min) {
      no.values = length(unique(var))
      if (no.values == 2) {
        tab = table(var)
        if (min(tab)/sum(tab) >= freq.min) {
          new = c(colnames(pheno)[i], tab)
          names(new) = NULL
          info.var.use = rbind(info.var.use, new)
        }
      }
    }
  }
  return(info.var.use)
}

identify_binary_phenotypes_l <- function(
    mae.l, 
    sample.size.min = 40, 
    freq.min = 0.4) {
  
  info.all = NULL
  for (i in 1:length(mae.l)) {
    temp = identify_binary_phenotypes(
      mae = mae.l[[i]],
      sample.size.min = sample.size.min,
      freq.min = freq.min)
    if (!is.null(temp)) {
      temp = cbind(names(mae.l)[i], temp)
      info.all = rbind(info.all, temp)
    }
  }
  info.all = data.frame(info.all)
  rownames(info.all) = NULL
  colnames(info.all) = c("cancer", "variable", "no.1", "no.2")
  return(info.all)
}

#########################################################
# Helper function to load the data_list object
#########################################################

load_data_list <- function() {
  if (file.exists(data_list_file)) {
    load(data_list_file)  #  Load the object stored in the RData file
    return(data_list)      # Return the loaded object
  } else {
    stop("Data list not found at: ", data_list_file)
  }
}

#########################################################
# Create directory if it does not exist
#########################################################

create_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
    message("Created directory: ", path)
  }
}
