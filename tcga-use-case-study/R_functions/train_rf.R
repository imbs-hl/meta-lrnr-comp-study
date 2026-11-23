###############################################################################
# Train the random forest base models for one TCGA dataset.
# The function processes all cross-validation folds and saves the results.
# Method body from tcga/scripts/03_01_train_rf.R
###############################################################################

train_rf <- function(nam, input_file, output_file) {
  data_list <- readRDS(input_file)
  results_ranger <- data_list
  nams <- names(data_list)
  stopifnot(nam >= 1L, nam <= length(nams), length(data_list[[nam]]) == 10L)
  message(sprintf("Omics data: %s\n", nams[nam]))
  
  folds <- data_list[[nam]]
  
  # Run cross-validation
  res_list <- lapply(seq_along(folds), FUN = function(current_fold){
      # Create reproducible cross-validation folds
      set.seed(1000 + nam*100 + current_fold)
      message("Processing fold ", current_fold)
      
      fold_data <- folds[[current_fold]]
      
      # training data
      target_df_training <- fold_data$training$target_df
      training_modality_1 <- fold_data$training$rna
      training_modality_2 <- fold_data$training$mirna
      training_modality_3 <- fold_data$training$rppa

      # test data
      target_df_test <- fold_data$test$target_df
      test_modality_1 <- fold_data$test$rna
      test_modality_2 <- fold_data$test$mirna
      test_modality_3 <- fold_data$test$rppa
      
      # Create fuseMLR training object
      training <- createTraining(id = "training",
                                 ind_col = "ID",
                                 target = "target",
                                 target_df = target_df_training,
                                 verbose = TRUE)
      
      # Create modality 1
      createTrainLayer(training = training,
                       train_layer_id = "rna",
                       train_data = training_modality_1,
                       lrner_package = "ranger",
                       lrn_fct = "ranger",
                       param_train_list = list(probability = TRUE,
                                               num.trees = 10000L),
                       param_pred_list = list(),
                       na_action = "na.keep")
      
      # Create modalyty 2
      createTrainLayer(training = training,
                       train_layer_id = "mirna",
                       train_data = training_modality_2,
                       lrner_package = "ranger",
                       lrn_fct = "ranger",
                       param_train_list = list(probability = TRUE, 
                                               num.trees = 10000L),
                       param_pred_list = list(),
                       na_action = "na.keep")
  
      
      # Create modality 3
      createTrainLayer(training = training,
                       train_layer_id = "rppa",
                       train_data = training_modality_3,
                       lrner_package = "ranger",
                       lrn_fct = "ranger",
                       param_train_list = list(probability = TRUE, 
                                               num.trees = 8000L),
                       param_pred_list = list(),
                       na_action = "na.keep")

      # Create meta-layer.
      createTrainMetaLayer(training = training,
                           meta_layer_id = "meta_layer",
                           lrner_package = NULL,
                           lrn_fct = "ranger", 
                           param_train_list = list(probability = TRUE, 
                                                   num.trees= 2500L),
                           param_pred_list = list(),
                           na_action = "na.keep")
    
      # Measure the complete fuseMLR training as in single-run-best.R.
      start_time_all <- Sys.time()
      
      # Train fuseMLR model: from modalaty specific till meta model
      fusemlr(training = training,
              use_var_sel = TRUE)
      
      # Includes variable selection, base-model CV and the first meta fit.
      runtime_training_all <- difftime(Sys.time(), 
                                       start_time_all, 
                                       units = "secs")
      
      # Part only to record the time
      meta_layer <- training$getTrainMetaLayer()
      start_time <- Sys.time()  # Record start time
      # Re-run  to save the meta-learning time only
      meta_layer$train()
      
      # Create test object
      test <- createTesting(id = "test",
                         ind_col = "ID")
      
      # Estimate the joint base-model runtime as in the simulation study.
      runtime_meta_train <- difftime(Sys.time(), 
                                     start_time,
                                     units = "secs")
      runtime_basemodel <- runtime_training_all - runtime_meta_train
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
      predictions <- predict(object = training,
                             testing = test)

      # Measure runtime
      elapsed_time <- difftime(Sys.time(), start_time, units = "secs")
      
      # Combine predictions with ground truth
      pred_truth <- predictions$predicted_values %>%
        left_join(target_df_test, by = "ID") %>% 
        mutate(Runtime = elapsed_time,
               Runtime_basemodel = as.numeric(runtime_basemodel,
                                              units = "secs"))
      
      # Store results
      fold_list <- list(training = training,
                        test = test,
                        pred_truth = pred_truth,
                        target_df_test = target_df_test)
      
      return(fold_list)
      })
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(res_list, output_file)
  output_file
}
