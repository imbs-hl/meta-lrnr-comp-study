#########################################################
# TCGA: Prepare cross-validation data with missing modalities
# Purpose: Create 10-fold training and test splits for each TCGA dataset with missing modalities
# Run from: tcga-use-case-study/scripts
#########################################################

## Load project paths, functions, and packages.
source("../init.R", chdir = TRUE)

# Load the prepared dataset list
data_list <- readRDS(file.path(datasets_path,
                    "data_list_cv_folds.rds"))

# Data list
nams <- names(data_list)

# Final list containing all diseases
all_datasets <- vector("list", length(nams))
names(all_datasets) <- nams

for (nam in seq_along(nams)) {
  message("Disease: ", nams[nam])
  folds <- data_list[[nam]]
  
  res_list <- lapply(seq_along(folds), function(current_fold) {
    message("Processing fold ", current_fold)
    
    
    fold_data <- folds[[current_fold]]
    
    # Training data
    training_modality_1 <- fold_data$training$rna
    training_modality_2 <- fold_data$training$mirna
    training_modality_3 <- fold_data$training$rppa
    
    vars_to_remove_mod1 <- names(which(colSums(is.na(training_modality_1)) > 0))
    training_modality_1 <- training_modality_1[, !(names(training_modality_1) %in% vars_to_remove_mod1)]
    message("In Training Modality 1 were variables deleted: ", length(vars_to_remove_mod1))
    
    vars_to_remove_mod2 <- names(which(colSums(is.na(training_modality_2)) > 0))
    training_modality_2 <- training_modality_2[, !(names(training_modality_2) %in% vars_to_remove_mod2)]
    message("In Training Modality 1 were variables deleted: ", length(vars_to_remove_mod2))
    
    vars_to_remove_mod3 <- names(which(colSums(is.na(training_modality_3)) > 0))
    training_modality_3 <- training_modality_3[, !(names(training_modality_3) %in% vars_to_remove_mod3)]
    message("In Training Modality 3 were variables deleted: ", length(vars_to_remove_mod3))
        
    x_training <- training_modality_1 %>%
      full_join(training_modality_2, by = "ID") %>%
      full_join(training_modality_3, by = "ID")


     target_training_df <- fold_data$training$target_df
    
    # Get indices in x_training
    ncol_rna <- ncol(training_modality_1) - 1 # IDS column removed
    ncol_mirna <- ncol(training_modality_2) - 1
    ncol_rppa <- ncol(training_modality_3) - 1
    
    rna_idx <- 1:(ncol_rna)
    mirna_idx <- (ncol_rna + 1):(ncol_rna + ncol_mirna)
    rppa_idx <-
      (ncol_rna + ncol_mirna + 1):(ncol_rna + ncol_mirna + ncol_rppa)
    
    
    blocks_idx <- list(rna_idx = rna_idx,
                       mirna_idx = mirna_idx,
                       rppa_idx = rppa_idx)

    # Test data
    test_modality_1 <- fold_data$test$rna
    test_modality_2 <- fold_data$test$mirna
    test_modality_3 <- fold_data$test$rppa
    
    vars_to_remove_test_mod1 <- names(which(colSums(is.na(test_modality_1)) > 0))
    test_modality_1 <- test_modality_1[, !(names(test_modality_1) %in% vars_to_remove_test_mod1)]
    message("In Test Modality 1 were variables deleted: ", length(vars_to_remove_test_mod1))
    
    vars_to_remove_test_mod2 <- names(which(colSums(is.na(test_modality_2)) > 0))
    test_modality_2 <- test_modality_2[, !(names(test_modality_2) %in% vars_to_remove_test_mod2)]
    message("In Test Modality 2 were variables deleted: ", length(vars_to_remove_test_mod2))
    
    vars_to_remove_test_mod3 <- names(which(colSums(is.na(test_modality_3)) > 0))
    test_modality_3 <- test_modality_3[, !(names(test_modality_3) %in% vars_to_remove_test_mod3)]
    message("In Test Modality 3 were variables deleted: ", length(vars_to_remove_test_mod3))
    
    x_test <- test_modality_1 %>%
      full_join(test_modality_2, by = "ID") %>%
      full_join(test_modality_3, by = "ID")
    

    target_test_df <- fold_data$test$target_df
  
    # Store results
    fold_list <- list(
      training = list(x_training = x_training,
                      target_df = target_training_df),
      test = list(x_test = x_test,
                  target_df = target_test_df),
      blocks_idx = blocks_idx #,
    )
    
  })
  
  all_datasets[[nam]] <- res_list
}

# Save complete structure
saveRDS(all_datasets,
        file = file.path(datasets_path, "data_list_cv_folds_miss.rds"))
