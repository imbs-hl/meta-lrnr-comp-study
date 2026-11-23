
# This function runs a single simulation replicate using Cobra (fuseMLR)

single_run_cobra <- function (
    data_file,
    seed = 124,
    na_action = "na.keep"
) {
  multi_omics <- readRDS(data_file)
  
  # best meta file
  training_file <- file.path(sub("data$", "train/best", dirname(data_file)),
                             sub( "_prop_miss", "_best_prop_miss",
                                  sub("\\.rds$", paste0("_", na_action, ".rds"),
                                      basename(data_file))))
  
  training <- readRDS(training_file)
  # Update meta layer learner with RF.
  meta_layer <- training$training$getTrainMetaLayer()
  new_lnr <- Lrner$new(id = "cobra",
                       package = NULL,
                       lrn_fct = "cobra",
                       param_train_list = list(tune = "epsilon"),
                       train_layer = meta_layer,
                       na_action = na_action)
  # Remove the old model
  tmp_key <- meta_layer$getKeyClass()
  meta_layer$removeFromHashTable(tmp_key[tmp_key$class == "Model", "key"])
  # Access, update and train the new meta-learner lolly
  set.seed(seed)
  start_time <- Sys.time()  # Record start time
  # Re-train the meta learner only.
  meta_layer$train()
  # Create testing for predictions
  testing <- createTesting(id = "testing",
                           ind_col = "IDS")
  # Create methylation layer
  createTestLayer(testing = testing,
                  test_layer_id = "methylation",
                  test_data = multi_omics$testing$methylation)
  # Create gene expression layer
  createTestLayer(testing = testing,
                  test_layer_id = "geneexpr",
                  test_data = multi_omics$testing$geneexpr)
  # Create gene protein abundance layer
  createTestLayer(testing = testing,
                  test_layer_id = "proteinexpr",
                  test_data = multi_omics$testing$proteinexpr)
  predictions <- predict(object = training$training, testing = testing)
  end_time <- Sys.time()  # Record end time
  
  pred_values <- predictions$predicted_values
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  
  runtime <- end_time - start_time
  
  
  # Save the Training object
  training_file <- file.path(sub("data$", "train/cobra", dirname(data_file)),
                             sub( "_prop_miss", "_cobra_prop_miss",
                                  sub("\\.rds$", paste0("_", na_action, ".rds"),
                                      basename(data_file))))
  
  training_dir <- dirname(training_file)
  if (!dir.exists(training_dir)) {
    dir.create(training_dir, recursive = TRUE)
  }
  
  saveRDS(object = list(training_best = training,
                        actual_pred = actual_pred,
                        runtime = runtime,
                        runtime_basemodel = training$runtime_basemodel),
          file = training_file)
  
  
  return(list(training_best = training,
              actual_pred = actual_pred,
              runtime = runtime,
              runtime_basemodel = training$runtime_basemodel))
}
