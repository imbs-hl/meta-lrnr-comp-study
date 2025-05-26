# This file will run a single replication and estimate prediction performance 
# for logistic regression.
# The code is similar to the code provided in the vignette of fuseMLR.
single_run_cobra <- function (
    data_file = file.path(data_simulation, "multi_omics.rds"),
    seed = 124,
    delta.methyl = param_df$delta.methyl,
    delta.expr = param_df$delta.expr,
    delta.protein = param_df$delta.protein,
    effect = "effect",
    na_action = "na.keep"
) {
  multi_omics <- readRDS(data_file)
  training_file <- file.path(dirname(data_file), 
                             paste0(seed, 
                                    sprintf("%s_meta_%s.rds",
                                            effect, na_action),
                                    collapse = ""))
  training <- readRDS(training_file)
  # Update meta layer learner with RF.
  meta_layer <- training$getTrainMetaLayer()
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
  # fusemlr(training = training,
  #         use_var_sel = TRUE)
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
  predictions <- predict(object = training, testing = testing)
  end_time <- Sys.time()  # Record end time
  pred_values <- predictions$predicted_values
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  y <- as.numeric(actual_pred$disease == "1")
  # On all patients
  perf_bs <- sapply(X = actual_pred[ , 2L:5L], FUN = function (my_pred) {
    bs <- mean((y[complete.cases(my_pred)] - my_pred[complete.cases(my_pred)])^2)
    # bs2 <- mean((y[complete.cases(my_pred)] - (1 - my_pred[complete.cases(my_pred)]))^2)
    # bs <- min(bs1, bs2)
    roc_obj <- pROC::roc(y[complete.cases(my_pred)],
                         my_pred[complete.cases(my_pred)])
    auc <- pROC::auc(roc_obj)
    performances = rbind(bs, auc)
    return(performances)
  })
  rownames(perf_bs) <- c("BS", "AUC")
  perf_bs <- as.data.frame(perf_bs)
  perf_bs$perf_measure <- rownames(perf_bs)
  perf_bs$delta.methyl <- delta.methyl
  perf_bs$delta.expr <- delta.expr
  perf_bs$delta.protein <- delta.protein
  perf_bs$seed <- seed
  perf_bs$effect <- effect
  perf_bs$runtime <- start_time - end_time
  # Save the Training object
  training_file <- file.path(dirname(data_file), 
                             paste0(seed, 
                                    sprintf("%s_meta_cobra_%s.rds",
                                            effect, na_action),
                                    collapse = ""))
  saveRDS(object = training, file = training_file)
  return(perf_bs)
}
