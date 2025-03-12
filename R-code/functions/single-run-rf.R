# This file will run a single replication and estimate prediction performance 
# for random forests.
# The code is similar to the code provided in the vignette of fuseMLR.
single_run_rf <- function (
    data_file = file.path(data_simulation, "multi_omics.rds"),
    seed = 124,
    delta.methyl = param_df$delta.methyl,
    delta.expr = param_df$delta.expr,
    delta.protein = param_df$delta.protein,
    num.tree.meta = 1000L,
    effect = "effect"
) {
  multi_omics <- readRDS(data_file)
  training_file <- file.path(dirname(data_file), 
                             paste0(seed, 
                                    sprintf("%s_meta.rds", effect),
                                    collapse = ""))
  training <- readRDS(training_file)
  # Update meta layer learner with RF and re-train it.
  meta_layer <- training$getTrainMetaLayer()
  Lrner$new(id = "ranger",
            package = "ranger",
            lrn_fct = "ranger",
            param_train_list = list(num.tree = num.tree.meta),
            param_pred_list = list(na_rm = TRUE),
            na_action = "na.rm",
            train_layer = meta_layer)
  meta_layer$train()
  print(meta_layer)
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
    roc_obj <- pROC::roc(y[complete.cases(my_pred)], my_pred[complete.cases(my_pred)])
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
  # Save the Training object
  training_file <- file.path(dirname(data_file), 
                             paste0(seed, 
                                    sprintf("%s_meta_rf.rds", effect),
                                    collapse = ""))
  saveRDS(object = training, file = training_file)
  return(perf_bs)
}
