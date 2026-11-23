
# This function runs a single simulation replicate using Best (fuseMLR)

single_run_best <- function (
    data_file,
    seed = 124,
    num.tree.ranger.methyl = 5000L,
    num.tree.ranger.genexpr = 2000L,
    num.tree.ranger.proexpr = 1000L,
    na_action = "na.keep"
) {
  multi_omics <- readRDS(data_file)
  # Set up a training object
  training <- createTraining(id = "training",
                             ind_col = "IDS",
                             target = "disease",
                             target_df = multi_omics$training$target,
                             verbose = FALSE)
  # Create methylation layer
  createTrainLayer(training = training,
                   train_layer_id = "methylation",
                   train_data = multi_omics$training$methylation,
                   lrner_package = "ranger",
                   lrn_fct = "ranger",
                   param_train_list = list(num.trees = num.tree.ranger.methyl,
                                           probability = TRUE),
                   param_pred_list = list(),
                   na_action = "na.keep")
  # Create gene expression layer.
  createTrainLayer(training = training,
                   train_layer_id = "geneexpr",
                   train_data = multi_omics$training$geneexpr,
                   lrner_package = "ranger",
                   lrn_fct = "ranger",
                   param_train_list = list(num.trees = num.tree.ranger.genexpr,
                                           probability = TRUE),
                   param_pred_list = list(),
                   na_action = "na.keep")
  
  # Create gene protein abundance layer
  createTrainLayer(training = training,
                   train_layer_id = "proteinexpr",
                   train_data = multi_omics$training$proteinexpr,
                   lrner_package = "ranger",
                   lrn_fct = "ranger",
                   param_train_list = list(num.trees = num.tree.ranger.proexpr,
                                           probability = TRUE),
                   param_pred_list = list(type = "response"),
                   na_action = "na.keep")
  
  # Create meta layer with imputation of missing values.
  if (na_action == "na.rm") {
    createTrainMetaLayer(training = training,
                         meta_layer_id = "meta_layer",
                         lrner_package = NULL,
                         lrn_fct = "bestLayerLearner",
                         param_train_list = list(),
                         param_pred_list = list(),
                         na_action = "na.rm")
  } else {
    if (na_action == "na.keep") {
      createTrainMetaLayer(training = training,
                           meta_layer_id = "meta_layer",
                           lrner_package = NULL,
                           lrn_fct = "bestLayerLearner",
                           param_train_list = list(),
                           param_pred_list = list(),
                           na_action = "na.keep")
    } else {
      if (na_action == "na.impute") {
        createTrainMetaLayer(training = training,
                             meta_layer_id = "meta_layer",
                             lrner_package = NULL,
                             lrn_fct = "bestLayerLearner",
                             param_train_list = list(),
                             param_pred_list = list(),
                             na_action = "na.impute")
      } 
    }
  }

  set.seed(seed)
  # Measure all training (base models, CV, and the first meta fit).
  start_time_all <- Sys.time()
  fusemlr(training = training,
          use_var_sel = FALSE)
  runtime_training_all <- Sys.time() - start_time_all
  meta_layer <- training$getTrainMetaLayer()
 
  
  start_time <- Sys.time()  # Record start time
  # We re-run it to save the meta-learning time only
  meta_layer$train()
  runtime_meta_train <- Sys.time() - start_time
  runtime_basemodel <- runtime_training_all - runtime_meta_train
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
  predictions <- predict(object = training, testing = testing)
  end_time <- Sys.time()  # Record end time
  pred_values <- predictions$predicted_values
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  
 runtime <- end_time - start_time
 
 # Save the Training object
 training_file <- file.path(sub("data$", "train/best", dirname(data_file)),
                            sub( "_prop_miss", "_best_prop_miss",
                                 sub("\\.rds$", paste0("_", na_action, ".rds"),
                                     basename(data_file))))
 
 training_dir <- dirname(training_file)
 if (!dir.exists(training_dir)) {
   dir.create(training_dir, recursive = TRUE)
 }

 saveRDS(object = list(training = training,
                       actual_pred = actual_pred,
                       runtime = runtime,
                       runtime_basemodel = runtime_basemodel),
         file = training_file)
 

 return(list(training = training,
             actual_pred = actual_pred,
             runtime = runtime,  
             runtime_basemodel = runtime_basemodel))
}


