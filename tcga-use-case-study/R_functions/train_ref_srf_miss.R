###############################################################################
# Train the SRF reference model for one TCGA dataset.
# The function processes all cross-validation folds and saves the results.
# Method body from tcga/scripts/04_04_train_ref_srf_miss.R
###############################################################################

train_ref_srf_miss <- function(nam, input_file, output_file) {
  data_list <- readRDS(input_file)
  results_ranger <- data_list
  nams <- names(data_list)
  stopifnot(nam >= 1L, nam <= length(nams), length(data_list[[nam]]) == 10L)
  
  message("Disease: ", nams[nam])
  folds <- data_list[[nam]]
    
    res_list <- lapply(seq_along(folds), function(current_fold){
      # Create reproducible cross-validation folds
      set.seed(1000 + nam*1000 + current_fold)
      
      message("Processing fold ", current_fold)
      
      fold <- folds[[current_fold]]
      # Train Data
      train_data <- fold$training$x_training %>% 
        dplyr::select(-ID)
      # Test Data
      test_data <- fold$test$x_test %>% 
        dplyr::select(-ID)
      
      #blocks <- fold$blocks_idx

      # Apply the same row filter to target variable
      target <- fold$training$target_df$target

      # Record start time
      start_time <- Sys.time()
      
      # Variable selection with SRF
      message("Variable selection for SRF model started...\n")
      varsel <- Boruta::Boruta(x = train_data,
                               y = target,
                               num.trees = 25000)
      varsel <- varsel$finalDecision
      # 
      varsel_confirmed <- names(varsel[varsel == "Confirmed"])
      print("Here is the list of selected variables...")
      print(varsel_confirmed)
      varsel <- if(length(varsel_confirmed)) {
        varsel_confirmed
      } else {
        colnames(train_data)
      }
     
      # train model on training set
      srf_model <- ranger(x = train_data[ , varsel, drop = FALSE],
                          y = target,
                          #num.trees = 25000,
                          num.trees = 8000,
                          na.action = "na.learn",
                          probability = TRUE)
    
     predictions <- predict(object = srf_model,
                            data = test_data[ , varsel, drop = FALSE])
     
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
                        srf_model = srf_model, 
                        pred_truth = pred_truth)
       
       return(fold_list)
       })
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(res_list, output_file)
  output_file
}
