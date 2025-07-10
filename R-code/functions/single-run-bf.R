# This file will run a single replication and estimate prediction performance 
# for BlockForest.
single_run_bf <- function (
    data_file = file.path(data_simulation, "multi_omics.rds"),
    seed = 124,
    delta.methyl = param_df$delta.methyl,
    delta.expr = param_df$delta.expr,
    delta.protein = param_df$delta.protein,
    na_action = "na.keep",
    effect = "effect",
    num.trees = 25000L
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
  x_training <- as.matrix(x_training)
  y_training <- multi_omics$training$target[ , "disease"]
  ncol_methyl <- ncol(multi_omics$training$methylation) - 1 # IDS column removed
  ncol_genexpr <- ncol(multi_omics$training$geneexpr) - 1
  ncol_proteinexpr <- ncol(multi_omics$training$proteinexpr) - 1
  
  block_methyl <- 1:(ncol_methyl)
  block_genexpr <- (ncol_methyl + 1):(ncol_methyl + ncol_genexpr)
  block_proteinexpr <- (ncol_methyl + ncol_genexpr + 1):(ncol_methyl + ncol_genexpr + ncol_proteinexpr)
  
  x_training <- merge(x = x_training,
                      y = multi_omics$training$target,
                      by = "IDS",
                      all = TRUE)
  x_training$IDS <- NULL
  # Testing dataset
  x_testing <- merge(x = multi_omics$testing$methylation,
                     y = multi_omics$testing$geneexpr,
                     by = "IDS",
                     all = TRUE)
  x_testing <- merge(x = x_testing,
                     y = multi_omics$testing$proteinexpr,
                     by = "IDS",
                     all = TRUE)
  test_ids <- x_testing$IDS
  x_testing$IDS <- NULL
  y_testing <- multi_omics$testing$target[ , "disease"]
  start_time <- Sys.time()  # Record start time
  # We train BF model
  message("Training of BF model started...\n")
  bf_trained <- blockForest(data = x_training,
                            blocks = list(block_methyl,
                                          block_genexpr,
                                          block_proteinexpr),
                            block.method = "BlockForest",
                            mtry = c(floor(sqrt(ncol_methyl)),
                                     floor(sqrt(ncol_genexpr)),
                                     floor(sqrt(ncol_proteinexpr))),
                            block.weights = c(ncol_methyl, 
                                              ncol_genexpr,
                                              ncol_proteinexpr) / sum(
                                                c(ncol_methyl, 
                                                  ncol_genexpr,
                                                  ncol_proteinexpr)
                                              ),
                            num.trees = num.trees,
                            probability = TRUE,
                            dependent.variable.name = "disease")
  # We predict
  predictions <- predict(object = bf_trained,
                         data = as.data.frame(x_testing))
  end_time <- Sys.time()  # Record end time
  pred_values <- data.frame(test_ids, predictions)
  names(pred_values) <- c("IDS", "predictions")
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  y <- as.numeric(multi_omics$testing$target$disease == "1")
  # On all patients
  perf_bs <- sapply(X = actual_pred[ , "predictions", drop = FALSE], FUN = function (my_pred) {
    bs <- mean((y[complete.cases(my_pred)] - my_pred[complete.cases(my_pred)])^2)
    # bs2 <- mean((y[complete.cases(my_pred)] - (1 - my_pred[complete.cases(my_pred)]))^2)
    # bs <- min(bs1, bs2)
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
                                    sprintf("%s_bf_%s.rds",
                                            effect, na_action),
                                    collapse = ""))
  saveRDS(object = pl_trained, file = training_file)
  return(perf_bs)
}
