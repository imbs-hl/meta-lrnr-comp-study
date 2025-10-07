# This file will run a single replication and estimate prediction performance 
# for DIABLO
single_run_diablo <- function (
    data_file = file.path(data_simulation, "multi_omics.rds"),
    seed = 124,
    delta.methyl = param_df$delta.methyl,
    delta.expr = param_df$delta.expr,
    delta.protein = param_df$delta.protein,
    na_action = "na.keep",
    effect = "effect",
    ncomp = 2L
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
  Y <- x_training$disease
  # Split the training set into training and validation set
  diablo_index <- caret::createDataPartition(y = Y, 
                                             p = 0.5, 
                                             list = FALSE)
  # Logreg index
  logreg_index <- setdiff(1:length(Y), diablo_index)
  X_diablo <- list(
    methyl = as.matrix(sapply(x_training[diablo_index, block_methyl], as.numeric)),
    genexpr = as.matrix(sapply(x_training[diablo_index, block_genexpr], as.numeric)),
    proteinexpr = as.matrix(sapply(x_training[diablo_index, block_proteinexpr], as.numeric))
  )
  Y_diablo <- Y[diablo_index]
  X_logreg <- list(
    methyl = as.matrix(sapply(x_training[logreg_index, block_methyl], as.numeric)),
    genexpr = as.matrix(sapply(x_training[logreg_index, block_genexpr], as.numeric)),
    proteinexpr = as.matrix(sapply(x_training[logreg_index, block_proteinexpr], as.numeric))
  )
  Y_logreg <- Y[logreg_index]
  # Build the design matrix
  design <- matrix(0.1, ncol = length(X), nrow = length(X), 
                   dimnames = list(names(X), names(X)))
  diag(design) <- 0
  
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
  x_testing <- list(
    methyl = as.matrix(sapply(x_testing[ , block_methyl], as.numeric)),
    genexpr = as.matrix(sapply(x_testing[ , block_genexpr], as.numeric)),
    proteinexpr = as.matrix(sapply(x_testing[ , block_proteinexpr], as.numeric))
  )
  y_testing <- multi_omics$testing$target[ , "disease"]
  start_time <- Sys.time()  # Record start time
  # We train BF model
  message("Training of DIABLO model started...\n")
  # Note: KeepX is the number of variables to select per component and per dataset
  # This parameter should be tuned in a real data analysis. We tune the number of
  # components and keepX with cross-validation.
  basic_diablo_model <- block.splsda(X = X_diablo,
                                     Y = Y_diablo,
                                     ncomp = 15,
                                     design = design)
  # run component number tuning with repeated CV
  perf_diablo <- perf(basic_diablo_model,
                      validation = 'Mfold',
                      folds = 10, nrepeat = 5)
  # set the optimal ncomp value
  ncomp <- perf_diablo$choice.ncomp$WeightedVote["Overall.BER", "mahalanobis.dist"] 
  
  # Now tune keepX
  list_keepX <- list(
    methyl = seq(5, floor(ncol_methyl * 0.5), by = 2500),
    genexpr = seq(5, floor(ncol_genexpr * 0.5), by = 2500),
    proteinexpr = seq(5, floor(ncol_proteinexpr * 0.5), by = 1000)
  )
  tune_diablo <- tune.block.splsda(X = X_diablo,
                                   Y = Y_diablo,
                                   ncomp = ncomp,
                                   test.keepX = list_keepX,
                                   design = design,
                                   validation = 'Mfold',
                                   folds = 10,
                                   nrepeat = 5,
                                   dist = "mahalanobis.dist",
                                   progressBar = TRUE,
                                   PPARAM = SnowParam(workers = 8))
  diablo_model <- block.splsda(X = X_diablo, 
                               Y = Y_diablo,
                               ncomp = ncomp, 
                               keepX = tune_diablo$choice.keepX,
                               design = design)
  # We predict the logreg set with diablo
  predict_logreg <- predict(object = diablo_model,
                            newdata = X_logreg,
                            dist = "mahalanobis.dist")
  predicted_scores <- predict_logreg$WeightedPredict[, , ncomp][ , 1]
  # Fit a logistic regression on the predicted scores
  logreg_fit <- glm(Y_logreg ~ predicted_scores, 
                    family = binomial(link = "logit"))
  # Predict the testing set with diablo
  predictions <- predict(object = diablo_model,
                         newdata = x_testing,
                         dist = "mahalanobis.dist")
  # Predict the testing set with logreg
  predicted_scores_test <- predictions$WeightedPredict[, , ncomp][ , 1]
  pred_test <- predict(logreg_fit,
                       newdata = data.frame(predicted_scores = predicted_scores_test),
                       type = "response")
  end_time <- Sys.time()  # Record end time
  pred_values <- data.frame(test_ids, 
                            pred_test)
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
    # bs <- NA
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
  saveRDS(object = bf_trained, file = training_file)
  return(perf_bs)
}
