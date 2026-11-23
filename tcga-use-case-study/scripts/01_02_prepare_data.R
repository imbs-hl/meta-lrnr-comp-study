#########################################################
# TCGA: Prepare datasets for classification
# Purpose: Prepare RNA, miRNA and RPPA datasets and encode the binary target variables.
# Run from: tcga-use-case-study/scripts
#########################################################

## Load project paths, functions, and packages.
source("../init.R", chdir = TRUE)


# Load the selected cancer types and candidate target variables.
info_cl_var <- readr::read_csv(info_cl_var_file)

# Load the prepared MAE objects for the selected cancer types.
pattern <- c("LGG|LGG|PRAD|STAD")
mae_l <- load_mae_objects(mae.dir = mae_path,
                          pattern = pattern)

# Define the modalities used for classification.
omics <-  c("RNASeq2GeneNorm", "miRNASeqGene", "RPPAArray")
data_stats_list <- list()

# Prepare one dataset for each cancer type and target variable.
data_list <- lapply(1:nrow(info_cl_var), function(i){
  row <- info_cl_var[i,]
  cancer <- row$cancer
  cl_var <- row$variable
  # mae for particular disease
  mae <- mae_l[[cancer]]
  
 omics_list <- lapply(omics, function(o){
    ## extract single omics as SE
    se = getWithColData(mae, o, mode = "append")
    # extract omics-data
    expr = assays(se)[[1]]
    # extract outcome variable
    outcome = colData(se)[, c("patientID", cl_var)]
    
    # merge expr and outcome
    dat <- data.frame(outcome, t(expr))
    n_id_empty_out_before <- nrow(dat)
    dat <- dat %>% 
      # remove samples with empty outcome variable
      dplyr::filter(!is.na(.[cl_var])) %>%
      dplyr::arrange(patientID) %>% 
      dplyr::select(-patientID)
    
    n_id_empty_out_removed <- n_id_empty_out_before - nrow(dat)
    
     # remove features with more than 20% missing values
     n_cols_miss_before <- ncol(dat)
     dat <- dat[, colMeans(is.na(dat)) <= 0.2]
     n_cols_miss_removed <- n_cols_miss_before - ncol(dat)
     
     # remove zero-variance features
     feature_cols <- setdiff(names(dat), cl_var)
     
     nzv_idx <- nearZeroVar(dat[, feature_cols, drop = FALSE])
     zero_var_cols <- feature_cols[nzv_idx$Position]

     dat <- dat[, !(names(dat) %in% zero_var_cols)]
     
     n_cols_zero_var_removed <- length(zero_var_cols)

    # LGG: TERT.promoter.status: Mutant  = 1/ WT = 0
    # LGG: TERT.expression.status: Expressed = 1 / Not expressed = 0
    # PRAD: ERG_status: fusion = 1 / none = 0
    # STAD: Copy.Number.Cluster: High = 1 / Low = 0
    
    dat <- dat %>%
      mutate(
        target = case_when(
          .data[[cl_var]] %in% c("Mutant", "Expressed", "fusion", "High") ~ 1,
          .data[[cl_var]] %in% c("WT", "Not expressed", "none", "Low") ~ 0,
          TRUE ~ NA_real_),
        target = factor(target, levels = c(0, 1))) %>%
      dplyr::select(-all_of(cl_var)) %>% 
      mutate(ID = row.names(.)) %>%
      dplyr::select(ID, target, everything())
    
    data_stats <- data.frame(
      cancer = cancer,
      target = cl_var,
      modality = o,
      removed_samples = n_id_empty_out_removed,
      removed_na_features = n_cols_miss_removed,
      removed_zero_var = n_cols_zero_var_removed)
    
    rownames(dat) <- NULL
    list(dat = dat, 
         data_stats = data_stats)
  })
 
  # create dataset with all available target variable for each ID
  # variables are ID and target
  df_target <- bind_rows(omics_list[[1]]$dat[c("ID", "target")],
                         omics_list[[2]]$dat[c("ID", "target")],
                         omics_list[[3]]$dat[c("ID", "target")]) %>%
    distinct(ID, .keep_all = TRUE)
  
   data_stats_list[[i]] <<- dplyr::bind_rows(omics_list[[1]]$data_stats,
                            omics_list[[2]]$data_stats,
                            omics_list[[3]]$data_stats)
  return(list(
     RNASeq2GeneNorm = dplyr::select(omics_list[[1]]$dat, -target),
     miRNASeqGene = dplyr::select(omics_list[[2]]$dat, -target),
     RPPAArray = dplyr::select(omics_list[[3]]$dat, -target),
     df_target = df_target))
  
})

names(data_list) <- paste(info_cl_var$cancer, info_cl_var$variable, sep = "_")

save(data_list, file = paste0(datasets_path, "/data_list.RData"))

#data_stats <- dplyr::bind_rows(data_stats_list)


