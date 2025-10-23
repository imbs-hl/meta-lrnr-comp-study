# This file will run a single replication and estimate prediction performance 
# for standard random forests
single_run_srf <- function (
    data_file = file.path(data_simulation, "multi_omics.rds"),
    seed = 124,
    delta.methyl = param_df$delta.methyl,
    delta.expr = param_df$delta.expr,
    delta.protein = param_df$delta.protein,
    effect = "effect",
    num.tree.boruta = 25000L,
    num.tree.ranger = 8000L,
    na_action = "na.learn"
) {
  multi_omics <- readRDS(data_file)
  
  # Training dataset
  x_training <- merge(x = multi_omics$training$methylation,
                      y = multi_omics$training$geneexpr,
                      by = "IDS",
                      all = TRUE)
  x_training <- merge(x = x_training,
                      y = multi_omics$training$proteinexpr,
                      by = "IDS",
                      all = TRUE)
  x_training <- merge(x = x_training,
                      multi_omics$training$target,
                      by = "IDS",
                      all = TRUE)
  x_training$IDS <- NULL
  y_training <- x_training$disease
  x_training$disease <- NULL
  x_training <- as.matrix(x_training)
  
  # Testing dataset
  x_testing <- merge(x = multi_omics$testing$methylation,
                     y = multi_omics$testing$geneexpr,
                     by = "IDS",
                     all = TRUE)
  x_testing <- merge(x = x_testing,
                     y = multi_omics$testing$proteinexpr,
                     by = "IDS",
                     all = TRUE)
  
  x_testing <- merge(x = x_testing,
                      multi_omics$testing$target,
                      by = "IDS",
                      all = TRUE)
  y_testing <- x_testing$disease
  test_ids <- x_testing$IDS
  x_testing$IDS <- NULL
  x_testing$disease <- NULL
  x_testing <- as.matrix(x_testing)
  start_time <- Sys.time()  # Record start time
  # Variable selection with SRF
  message("Variable selection for SRF model started...\n")
  varsel <- Boruta::Boruta(x = x_training,
                           y = y_training,
                           num.trees = num.tree.boruta)
  varsel <- varsel$finalDecision
  varsel_confirmed <- names(varsel[varsel == "Confirmed"])
  print("Here is the list of selected variables...")
  print(varsel_confirmed)
  varsel <- if(length(varsel_confirmed)) {
    varsel_confirmed
  } else {
    colnames(x_training)
  }
  # We train SRF model
  message("Training of SRF model started...\n")
  srf_trained <- ranger(x = x_training[ , varsel_confirmed, drop = FALSE],
                        y = as.numeric(y_training == "1"),
                        num.trees = num.tree.ranger,
                        na.action = na_action,
                        probability = TRUE)
  # We predict on the test set
  predictions <- predict(object = srf_trained,
                         data = x_testing)
  end_time <- Sys.time()  # Record end time
  pred_values <- data.frame(test_ids, predictions$predictions[ , 2L])
  names(pred_values) <- c("IDS", "predictions")
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  y <- as.numeric(actual_pred$disease == "1")
  # On all patients
  perf_bs <- sapply(X = actual_pred[ , "predictions", drop = FALSE], FUN = function (my_pred) {
    bs <- mean((y[complete.cases(my_pred)] - my_pred[complete.cases(my_pred)])^2)
    roc_obj <- pROC::roc(y[complete.cases(my_pred)], my_pred[complete.cases(my_pred)])
    auc <- pROC::auc(roc_obj)
    f1 <- MLmetrics::F1_Score(y_true = y[complete.cases(my_pred)],
                              y_pred = as.numeric(my_pred[complete.cases(my_pred)] > 0.5),
                              positive = 1)
    performances = rbind(bs, auc, f1)
    return(performances)
  })
  rownames(perf_bs) <- c("BS", "AUC", "F1")
  perf_bs <- as.data.frame(perf_bs)
  perf_bs$perf_measure <- rownames(perf_bs)
  perf_bs$delta.methyl <- delta.methyl
  perf_bs$delta.expr <- delta.expr
  perf_bs$delta.protein <- delta.protein
  perf_bs$seed <- seed
  perf_bs$effect <- effect
  perf_bs$runtime <- end_time - start_time
  # Save the Training object
  training_file <- file.path(dirname(data_file), 
                             paste0(seed, 
                                    sprintf("%s_srf_%s.rds",
                                            effect, na_action),
                                    collapse = ""))
  saveRDS(object = srf_trained, file = training_file)
  return(perf_bs)
}
