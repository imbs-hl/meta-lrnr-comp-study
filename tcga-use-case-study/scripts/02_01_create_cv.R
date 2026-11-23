#########################################################
# TCGA: Create cross-validation folds
# Purpose: Create 10-fold training and test splits for each TCGA dataset
# Run from: tcga-use-case-study/scripts
#########################################################

## Load project paths, functions, and packages.
source("../init.R", chdir = TRUE)

# Load the prepared dataset list
data_list <- load_data_list()

# Data list
nams <- names(data_list)
# Dataset specific seeds
seeds <- c(1228, 2478, 48211, 42303)

# Final list containing all diseases
all_datasets <- vector("list", length(nams))
names(all_datasets) <- nams

for (nam in seq_along(nams)) {
  message(sprintf("Omics data: %s\n", nams[nam]))
 
  dat <- data_list[[nam]]
  target_df <- dat[["df_target"]]
  
  # Omics modalities
  modality_1 <- dat[["RNASeq2GeneNorm"]]
  modality_2 <- dat[["miRNASeqGene"]]
  modality_3 <- dat[["RPPAArray"]]
  
  # Create cross-validation folds
  set.seed(seeds[nam])
  bench_folds <- caret::createFolds(y = target_df$target,
                                    k = 10L)
  
  # Run cross-validation
  dataset_folds <- lapply(X = 1L:10L, FUN = function(current_fold){
      message("Processing fold ", current_fold)
      
      # Define test indices
      test_index <- bench_folds[[current_fold]]
      
      # Prepare test data
      target_df_test <- target_df[test_index, ]
      
      test_modality_1 <- data.frame(modality_1[modality_1$ID %in% target_df_test$ID, ])
      test_modality_2 <- data.frame(modality_2[modality_2$ID %in% target_df_test$ID, ])
      test_modality_3 <- data.frame(modality_3[modality_3$ID %in% target_df_test$ID, ])
      
      # Prepare training data
      target_df_training <- target_df[-test_index, ]
     
      training_modality_1 <- data.frame(modality_1[!(modality_1$ID %in% target_df_test$ID), ])
      training_modality_2 <- data.frame(modality_2[!(modality_2$ID %in% target_df_test$ID), ])
      training_modality_3 <- data.frame(modality_3[!(modality_3$ID %in% target_df_test$ID), ])
      
      list(training = list(rna = training_modality_1,
                        mirna = training_modality_2,
                        rppa = training_modality_3,
                        target_df = target_df_training),
           test = list(rna = test_modality_1,
                       mirna = test_modality_2,
                       rppa = test_modality_3,
                       target_df = target_df_test))
  })

  all_datasets[[nam]] <- dataset_folds
}

# Save complete structure
saveRDS(all_datasets,
  file = file.path(datasets_path, "data_list_cv_folds.rds"))
      
