
# This function runs a single simulation replicate using DIABLO

single_run_diablo_miss <- function (
    data_file,
    seed = 124,
    na_action = "na.keep"
) {
  multi_omics <- readRDS(data_file)
  
  # Training dataset
  x_training <- multi_omics$training$methylation %>%
    full_join(multi_omics$training$geneexpr, by = "IDS") %>%
    full_join(multi_omics$training$proteinexpr, by = "IDS") %>% 
    left_join(multi_omics$training$target, by = "IDS")
  
  y_training <- x_training$disease
  x_training$IDS <- NULL
  x_training$disease <- NULL
  

  ncol_methyl <- ncol(multi_omics$training$methylation) - 1 # IDS column removed
  ncol_genexpr <- ncol(multi_omics$training$geneexpr) - 1
  ncol_proteinexpr <- ncol(multi_omics$training$proteinexpr) - 1
  
  block_methyl <- 1:(ncol_methyl)
  block_genexpr <- (ncol_methyl + 1):(ncol_methyl + ncol_genexpr)
  block_proteinexpr <- (ncol_methyl + ncol_genexpr + 1):(ncol_methyl + ncol_genexpr + ncol_proteinexpr)
  
  set.seed(seed)
  
  diablo_index <- caret::createDataPartition(y = y_training,
                                             p = 0.5,
                                             list = FALSE)
  diablo_index <- as.vector(diablo_index)
  
  logreg_index <- setdiff(seq_along(y_training),
                          diablo_index)
  
  # Create list of Omics blocks (ALL training data)
  X_diablo <- list(methyl = as.matrix(x_training[diablo_index, block_methyl, drop = FALSE]),
                   genexpr = as.matrix(x_training[diablo_index, block_genexpr, drop = FALSE]),
                   proteinexpr = as.matrix(x_training[diablo_index, block_proteinexpr, drop = FALSE]))
  Y_diablo <- droplevels(y_training[diablo_index])
  # Logistic regression dataset
  X_logreg <- list(methyl = as.matrix(x_training[logreg_index, block_methyl, drop = FALSE]),
                   genexpr = as.matrix(x_training[logreg_index, block_genexpr, drop = FALSE]),
                   proteinexpr = as.matrix(x_training[logreg_index, block_proteinexpr, drop = FALSE]))
  Y_logreg <- droplevels(y_training[logreg_index])
  
  # Build the design matrix C
  design_mat <- matrix(0.1,
                       ncol = length(X_diablo),
                       nrow = length(X_diablo), 
                       dimnames = list(names(X_diablo),
                                       names(X_diablo)))
  diag(design_mat) <- 0
  
  ncomp_max <- 2
  # Testing dataset
  x_testing <- multi_omics$testing$methylation %>%
    full_join(multi_omics$testing$geneexpr, by = "IDS") %>%
    full_join(multi_omics$testing$proteinexpr, by = "IDS")
  
  test_ids <- x_testing$IDS
  x_testing$IDS <- NULL
  x_test <- list(methyl = as.matrix(x_testing[, block_methyl, drop = FALSE]),
                 genexpr = as.matrix(x_testing[, block_genexpr, drop = FALSE]),
                 proteinexpr = as.matrix(x_testing[, block_proteinexpr, drop = FALSE]))
  
  set.seed(seed)
  start_time <- Sys.time()  # Record start time
  # We train BF model
  message("Training of DIABLO model started...\n")
  # Note: KeepX is the number of variables to select per component and per dataset
  # This parameter should be tuned in a real data analysis. We tune the number of
  # components and keepX with cross-validation.
  basic_diablo_model <- mixOmics::block.splsda(X = X_diablo,
                                               Y = Y_diablo,
                                               ncomp = ncomp_max,
                                               design = design_mat)
  # tuning the number of components  with repeated CV
  perf_diablo <- mixOmics::perf(basic_diablo_model,
                                validation = 'Mfold',
                                folds = 10,
                                nrepeat = 5,
                                dist = "mahalanobis.dist")
  # set the optimal ncomp value(numer of components)
  ncomp <- perf_diablo$choice.ncomp$WeightedVote["Overall.BER", "mahalanobis.dist"]
  ncomp <- as.integer(ncomp)
  message("Optimal number of components: ", ncomp,"\n")
  
  # Number of variables for block and for components 
  list_keepX <- list(methyl = c(5,  20,  100),
                     genexpr = c(5,  20,  100),
                     proteinexpr = c(5,  20,  100))

  tune_diablo <- mixOmics::tune.block.splsda(X = X_diablo,
                                             Y = Y_diablo,
                                             ncomp = ncomp,
                                             test.keepX = list_keepX,
                                             design = design_mat,
                                             validation = 'Mfold',
                                             folds = 10,
                                             nrepeat = 5,
                                             dist = "mahalanobis.dist",
                                             progressBar = FALSE, 
                                             seed = seed)
  
  keepX_opt <- tune_diablo$choice.keepX
  print(keepX_opt)
  
  #tune_diablo$choice.keepX
  #tune_diablo$choise.ncomp
  diablo_model <- mixOmics::block.splsda(X = X_diablo, 
                                         Y = Y_diablo,
                                         ncomp = ncomp, 
                                         keepX = keepX_opt,
                                         design = design_mat)
  
  # We use all selected components for class 1.
  
  positive_class <- "1"
  
  get_weighted_scores <- function(prediction,
                                  positive_class,
                                  ncomp) {
    
    scores <- prediction$WeightedPredict
    
    stopifnot(length(dim(scores)) == 3,
              positive_class %in% dimnames(scores)[[2]],
              dim(scores)[3] >= ncomp)
    
    # Extract scores for the positive class
    # across all selected components
    score_matrix <- scores[, positive_class, seq_len(ncomp), drop = FALSE]
    
    score_matrix <- matrix(as.numeric(score_matrix),
                           nrow = dim(scores)[1],
                           ncol = ncomp)
    
    score_df <- as.data.frame(score_matrix)
    colnames(score_df) <- paste0("weighted_comp", seq_len(ncomp))
    return(score_df)
  }
  
  predict_logreg <- predict(object = diablo_model,
                            newdata = X_logreg,
                            dist = "mahalanobis.dist")
  # Weighted scores for calibration samples
  predicted_scores <- get_weighted_scores(prediction = predict_logreg,
                                          positive_class = positive_class,
                                          ncomp = ncomp)
  
  # Add binary target
  predicted_scores$target <- as.integer(as.character(Y_logreg) == positive_class)
  
  # Train logistic regression on diablo scores
  glm_model <- glm(target ~ .,
                   data = predicted_scores,
                   family = binomial(link = "logit"))
  
  #diablo_model$design
  #diablo_model$variates
  # Predict independent TEST dataset with DIABLO
  #
  predictions <- predict(object = diablo_model,
                         newdata = x_test,
                         dist = "mahalanobis.dist")
  
  # Weighted scores for test samples
  predicted_scores_test <- get_weighted_scores(prediction = predictions,
                                               positive_class = positive_class,
                                               ncomp = ncomp)
  
  # 
  # Predict probability of class 1
  prob_class1 <- predict(glm_model,
                         newdata = predicted_scores_test,
                         type = "response")
  
  
  
  end_time <- Sys.time()  # Record end time
  
  pred_values <- data.frame(test_ids, prob_class1)
  names(pred_values) <- c("IDS", "predictions")
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  
  runtime <- end_time - start_time
  
  # Save the Training object
  training_file <- file.path(sub("data$", "train/diablo_miss_fin", dirname(data_file)),
                             sub( "_prop_miss", "_diablo_prop_miss",
                                  sub("\\.rds$", paste0("_", na_action, ".rds"),
                                      basename(data_file))))
  
  training_dir <- dirname(training_file)
  if (!dir.exists(training_dir)) {
    dir.create(training_dir, recursive = TRUE)
  }
  
  saveRDS(object = list(
    actual_pred = actual_pred,
    runtime = runtime,
    dim_train = dim(x_training),
    dim_test = dim(x_testing)),
    file = training_file)
  
  
  return(list(
    actual_pred = actual_pred,
    runtime = runtime,
    dim_train = dim(x_training),
    dim_test = dim(x_testing)))
}
