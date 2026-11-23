###############################################################################
# Train the BlockForest reference model for one TCGA dataset.
# The function processes all cross-validation folds and saves the results.
# Method body from tcga/scripts/04_01_train_ref_bf.R
###############################################################################

train_ref_bf <- function(nam, input_file, output_file) {
  data_list <- readRDS(input_file)
  results_ranger <- data_list
  nams <- names(data_list)
  stopifnot(nam >= 1L, nam <= length(nams), length(data_list[[nam]]) == 10L)
  
  message("Disease: ", nams[nam])
  folds <- data_list[[nam]]
    
    res_list <- lapply(seq_along(folds), function(current_fold){
      # Create reproducible cross-validation folds
      set.seed(1000 + nam*700 + current_fold)
      
      message("Processing fold ", current_fold)
      
      fold <- folds[[current_fold]]
      train_data <- fold$training$x_training %>% 
        dplyr::select(-ID)
      test_data <- fold$test$x_test %>% 
        dplyr::select(-ID)

      # Apply the same row filter to target variable
      target <- fold$training$target_df$target
    
      # Record start time
      start_time <- Sys.time()
     
      # train final model on training set
      final_blockForest_model <- blockfor(
        X = train_data,
        y = target,
        blocks = fold$blocks_idx, 
        probability = TRUE,
        num.trees = 25000, 
        block.method = "BlockForest"
      )
   
     # Predict on test data
      predictions <- predict(final_blockForest_model$forest,
                             data = test_data,
                             block.method = "BlockForest")
      
      pred_values <- predictions$predictions

     # Measure runtime
     elapsed_time <- difftime(Sys.time(), start_time, units = "secs")
   
     # Combine predictions with ground truth
     pred_truth <- tibble(ID = fold$test$target_df$ID,
                          predictions = predictions$predictions[, 2]) %>%
       left_join(fold$test$target_df, by = "ID") %>%
       mutate(Runtime = elapsed_time)
   
    # Store results
    fold_list <- list(training = fold$training,
                      test = fold$test,
                      pred_truth = pred_truth,
                      model = final_blockForest_model)

    return(fold_list)
  })
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(res_list, output_file)
  output_file
}
