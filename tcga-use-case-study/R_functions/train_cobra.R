###############################################################################
# Train the COBRA meta-learner for one TCGA dataset.
# The function processes all cross-validation folds and saves the results.
# Method body from tcga/scripts/03_04_train_cobra.R
###############################################################################

train_cobra <- function(nam, input_file, output_file) {

  folds <- readRDS(input_file)
  
  stopifnot(
    nam %in% seq_len(4L),
    length(folds) == 10L
  )
  
  message(
    "Disease index: ", nam,
    "; RF input: ", basename(input_file)
  )
    
    res_list <- lapply(seq_along(folds), function(current_fold){
      # Create reproducible cross-validation folds
      set.seed(1000 + nam*400 + current_fold)
      
      message("Processing fold ", current_fold)
      
      obj <- folds[[current_fold]]

      # Extract the meta layer from the training object
      # and pass it as train_layer to Learner$new
      meta_layer <- obj$training$getTrainMetaLayer()
  
      # Remove old model (ranger)
      tmp_key <- meta_layer$getKeyClass()
      meta_layer$removeFromHashTable(tmp_key[tmp_key$class == "Model", "key"])
  
      # Define new meta-learner
      new_lnr <- Lrner$new(id = "cobra",
                           package = NULL,
                           lrn_fct = "cobra",
                           param_train_list = list(tune = "epsilon"), 
                           train_layer = meta_layer,
                           na_action = "na.keep")
     # Test data
     test_modality_1 <- obj$test$getData()$rna
     test_modality_2 <- obj$test$getData()$mirna
     test_modality_3 <- obj$test$getData()$rppa

     target_df_test <- obj$target_df_test
    
     # Record start time
     start_time <- Sys.time()  
   
     # Train new meta learner 
     meta_layer$train()
    
     # Create test object
     test <- createTesting(id = "test",
                          ind_col = "ID")
      
     # Add test modalities
     createTestLayer(testing = test,
                     test_layer_id = "rna",
                     test_data = test_modality_1)
      
     createTestLayer(testing = test,
                     test_layer_id = "mirna",
                     test_data = test_modality_2)
      
    createTestLayer(testing = test,
                    test_layer_id = "rppa",
                    test_data = test_modality_3)
   
    # Predict on test data
    predictions <- predict(object = obj$training,
                           testing = test)
   
    # Measure runtime
    elapsed_time <- difftime(Sys.time(), start_time, units = "secs")
   
    # Combine predictions with ground truth
    pred_truth <- predictions$predicted_values %>%
      left_join(target_df_test, by = "ID") %>% 
      mutate(Runtime = elapsed_time,
             Runtime_basemodel = as.numeric(obj$pred_truth$Runtime_basemodel,
                                            units = "secs"))
   
    # Store results
    fold_list <- list(training = obj$training,
                      test = test,
                      pred_truth = pred_truth,
                      target_df_test = target_df_test)

    return(fold_list)
  })
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(res_list, output_file)
  output_file
}
