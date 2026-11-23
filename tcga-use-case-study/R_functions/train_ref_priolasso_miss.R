###############################################################################
# Train the PriorityLasso reference model for one TCGA dataset
# The function processes all cross-validation folds and saves the results.
# Method body from tcga/scripts/04_03_train_ref_priolasso_miss.R
###############################################################################

train_ref_priolasso_miss <- function(nam, input_file, output_file) {
  data_list <- readRDS(input_file)
  results_ranger <- data_list
  nams <- names(data_list)
  stopifnot(nam >= 1L, nam <= length(nams), length(data_list[[nam]]) == 10L)
  
  message("Disease: ", nams[nam])
  folds <- data_list[[nam]]
    
    res_list <- lapply(seq_along(folds), function(current_fold){
      # Create reproducible cross-validation folds
      set.seed(1000 + nam*900 + current_fold)
      
      message("Processing fold ", current_fold)
      
      fold <- folds[[current_fold]]
      # Train Data
      train_data <- fold$training$x_training %>% 
        dplyr::select(-ID)
      # Test Data
      test_data <- fold$test$x_test %>% 
        dplyr::select(-ID)
      
      blocks <- fold$blocks_idx

      # Apply the same row filter to target variable
      target <- fold$training$target_df$target

      # Record start time
      start_time <- Sys.time()
     
      has_na_train <- anyNA(train_data)
      has_na_test <- anyNA(test_data)
      
      if (has_na_train) {
        #Use the missing-data settings
        mcontrol <- missing.control(
        handle.missingdata = "impute.offset",
        offset.firstblock = "zero",
        impute.offset.cases = "available.cases",
        nfolds.imputation = 10,
        lambda.imputation = "lambda.1se",
        perc.comp.cases.warning = 0.3,
        threshold.available.cases = 30,
        select.available.cases = "maximise.blocks")
      
        cv_offset <- FALSE
        handle_missingtestdata <- "impute.block"
        
       } else {
          # Use the complete-data settings from the simulation study.
          mcontrol <- missing.control(handle.missingdata = "none")
          cv_offset <- TRUE
        }
        
        #Complete test folds must use "none", even if training blocks are missing.
        # handle_missingtestdata <- "impute.block"
        if (!has_na_test) {
          handle_missingtestdata <- "none"
        } else if (has_na_train) {
          handle_missingtestdata <- "impute.block"
        } else {
          # No block-imputation models were trained on complete training data.
          handle_missingtestdata <- "omit.prediction"
          warning("Training fold is complete: test cases with missing blocks receive NA predictions.")
        }
        message("Missing values: training = ", has_na_train, ", test = ", has_na_test,
                "; test handling = ", handle_missingtestdata)
        
      # Compare all six block priorities on the training data, as in the simulation study.
      blocks_list <- list(
        list(rna = blocks$rna_idx, mirna = blocks$mirna_idx, rppa = blocks$rppa_idx),
        list(rna = blocks$rna_idx, rppa = blocks$rppa_idx, mirna = blocks$mirna_idx),
        list(mirna = blocks$mirna_idx, rna = blocks$rna_idx, rppa = blocks$rppa_idx),
        list(mirna = blocks$mirna_idx, rppa = blocks$rppa_idx, rna = blocks$rna_idx),
        list(rppa = blocks$rppa_idx, rna = blocks$rna_idx, mirna = blocks$mirna_idx),
        list(rppa = blocks$rppa_idx, mirna = blocks$mirna_idx, rna = blocks$rna_idx))
      
      cv_priority <- cvm_prioritylasso(X = as.matrix(train_data),
                                       Y = as.numeric(target == "1"),
                                       family = "binomial",
                                       type.measure = "auc",
                                       blocks.list = blocks_list,
                                       block1.penalization = TRUE,
                                       lambda.type = "lambda.1se",
                                       standardize = TRUE,
                                       nfolds = 10,
                                       cvoffset = cv_offset,
                                       mcontrol = mcontrol,
                                       nlambda = 100)
      
      pl_model <- cv_priority$best.model
      best_blocks <- cv_priority$best.blocks
      message("Selected block priority: ", best_blocks)
      
      # Use the same prediction settings as in the simulation study.
      prob_class1 <- predict(object = pl_model,
                             newdata = as.matrix(test_data),
                             handle.missingtestdata = handle_missingtestdata,
                             include.allintercepts = TRUE,
                             type = "response")

      # Measure runtime
      elapsed_time <- difftime(Sys.time(), start_time, units = "secs")
   
     # Combine predictions with ground truth
      pred_truth <- tibble(ID = fold$test$target_df$ID,
                           predictions = as.vector(prob_class1)) %>%
        left_join(fold$test$target_df, by = "ID") %>%
        mutate(Runtime = elapsed_time)
   
      # Store results
      fold_list <- list(training = fold$training,
                        test = fold$test,
                        blocks_idx = fold$blocks_idx, 
                        pred_truth = pred_truth,
                        best_blocks = best_blocks,
                        best_blocks_indices = cv_priority$best.blocks.indices,
                        has_na_train = has_na_train,
                        has_na_test = has_na_test,
                        cv_offset = cv_offset,
                        handle_missingtestdata = handle_missingtestdata,
                        model_priolasso = pl_model)
       
       return(fold_list)
       })
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(res_list, output_file)
  output_file
}
