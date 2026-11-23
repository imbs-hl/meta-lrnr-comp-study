###############################################################################
# Train the DIABLO reference model for one TCGA dataset.
# The function processes all cross-validation folds and saves the results.
# Method body from tcga/scripts/04_02_train_ref_diablo.R
###############################################################################

train_ref_diablo <- function(nam, input_file, output_file) {
  data_list <- readRDS(input_file)
  #results_ranger <- data_list
  nams <- names(data_list)
  stopifnot(nam >= 1L, nam <= length(nams), length(data_list[[nam]]) == 10L)
  
  message("Disease: ", nams[nam])
  folds <- data_list[[nam]]
    
    res_list <- lapply(seq_along(folds), function(current_fold){
      # Create reproducible cross-validation folds
      seed <- 1000 + nam*800 + current_fold
      set.seed(seed)
      
      message("Processing fold ", current_fold)
      
      fold <- folds[[current_fold]]
      # Train Data
      train_data <- fold$training$x_training %>% 
        dplyr::select(-ID)
      # Test Data
      test_data <- fold$test$x_test %>% 
        dplyr::select(-ID)
      
      blocks <- fold$blocks_idx

      # Apply the same row filter to target variable
      target <- fold$training$target_df$target
      
      # Build DIABLO input
      diablo_index <- caret::createDataPartition(y = target,
                                                 p = 0.5,
                                                 list = FALSE)
      diablo_index <- as.vector(diablo_index)
      logreg_index <- setdiff(seq_along(target), diablo_index)
      
      X_diablo <- list(rna = as.matrix(train_data[diablo_index, blocks$rna_idx, drop = FALSE]),
                      mirna = as.matrix(train_data[diablo_index, blocks$mirna_idx, drop = FALSE]),
                      rppa = as.matrix(train_data[diablo_index, blocks$rppa_idx, drop = FALSE]))
      
      Y_diablo <- droplevels(target[diablo_index])
      
      X_logreg <- list(rna = as.matrix(train_data[logreg_index, blocks$rna_idx, drop = FALSE]),
                       mirna = as.matrix(train_data[logreg_index, blocks$mirna_idx, drop = FALSE]),
                       rppa = as.matrix(train_data[logreg_index, blocks$rppa_idx, drop = FALSE]))
      
      Y_logreg <- droplevels(target[logreg_index])
      
      X_test <- list(rna = as.matrix(test_data[, blocks$rna_idx]),
                     mirna = as.matrix(test_data[, blocks$mirna_idx]),
                     rppa = as.matrix(test_data[, blocks$rppa_idx]))
  
      # Design Matrix
      design <- matrix(0.1, 
                     ncol = length(X_diablo), 
                     nrow = length(X_diablo),
                     dimnames = list(names(X_diablo), names(X_diablo)))
      diag(design) <- 0
      
      set.seed(seed)
      # Record start time
      start_time <- Sys.time()

      ncomp_max <- 2
      basic_diablo_model <- mixOmics::block.splsda(X = X_diablo,
                                                   Y = Y_diablo,
                                                   ncomp = ncomp_max,
                                                   near.zero.var = TRUE,
                                                   design = design)
      
      # Select the number of components using repeated cross-validation.
      perf_diablo <- mixOmics::perf(basic_diablo_model,
                                    validation = "Mfold",
                                    folds = 10,
                                    nrepeat = 5,
                                    dist = "mahalanobis.dist")
      ncomp <- perf_diablo$choice.ncomp$WeightedVote["Overall.BER", "mahalanobis.dist"]
      ncomp <- as.integer(ncomp)
      message("Optimal number of components: ", ncomp)
      
      # Tune the number of selected variables per block and component.
      list_keepX <- list(rna = c(5, 20, 100),
                         mirna = c(5, 20, 100),
                         rppa = c(5, 20, 100))
      
      message("tune ", current_fold)
      tune_diablo <- mixOmics::tune.block.splsda(X = X_diablo,
                                                 Y = Y_diablo,
                                                 ncomp = ncomp,
                                                 near.zero.var = FALSE,
                                                 test.keepX = list_keepX,
                                                 design = design,
                                                 validation = "Mfold",
                                                 folds = 10,
                                                 nrepeat = 5,
                                                 dist = "mahalanobis.dist",
                                                 progressBar = FALSE,
                                                 seed = seed)
      keepX_opt <- tune_diablo$choice.keepX
      print(keepX_opt)
      
      message("fit ", current_fold)
      # Fit the final model using the selected parameters.
      diablo_model <- mixOmics::block.splsda(X = X_diablo,
                                             Y = Y_diablo,
                                             ncomp = ncomp,
                                             near.zero.var = TRUE,
                                             keepX = keepX_opt,
                                             design = design)
      
      # Calibrate weighted class scores as in single-run-diablo_fin.R.
      positive_class <- "1"
      get_weighted_scores <- function(prediction, positive_class, ncomp) {
        scores <- prediction$WeightedPredict
        
        stopifnot(length(dim(scores)) == 3,
                  positive_class %in% dimnames(scores)[[2]],
                  dim(scores)[3] >= ncomp)
        
        score_matrix <- scores[, positive_class, seq_len(ncomp), drop = FALSE]
        
        score_matrix <- matrix(as.numeric(score_matrix),
                               nrow = dim(scores)[1], ncol = ncomp)
        
        score_df <- as.data.frame(score_matrix)
        colnames(score_df) <- paste0("weighted_comp", seq_len(ncomp))
        return(score_df)
      }
      message("Predict diablo log ", current_fold)
      
      predict_logreg <- predict(diablo_model,
                                newdata = X_logreg,
                                dist = "mahalanobis.dist")
      
      predicted_scores <- get_weighted_scores(prediction = predict_logreg,
                                              positive_class = positive_class,
                                              ncomp = ncomp)
      predicted_scores$target <- as.integer(as.character(Y_logreg) == positive_class)
      
      message("glm ", current_fold)
      glm_model <- glm(target ~ .,
                       data = predicted_scores,
                       family = binomial(link = "logit"))
      
      message("predict diablo new ", current_fold)
      predictions <- predict(diablo_model,
                             newdata = X_test,
                             dist = "mahalanobis.dist")
      
      predicted_scores_test <- get_weighted_scores(predictions,
                                                   positive_class,
                                                   ncomp)
      message("Predict glm ", current_fold)
      prob_class1 <- predict(glm_model,
                             newdata = predicted_scores_test,
                             type = "response")   
      # Measure runtime
      elapsed_time <- difftime(Sys.time(), start_time, units = "secs")
   
     # Combine predictions with ground truth
      pred_truth <- tibble(ID = fold$test$target_df$ID,
                         predictions = prob_class1) %>%
        left_join(fold$test$target_df, by = "ID") %>% 
        mutate(Runtime = elapsed_time)
   
      # Store results
      fold_list <- list(training = fold$training,
                        test = fold$test,
                        pred_truth = pred_truth,
                        model_diablo = diablo_model, 
                        model_glm = glm_model,
                        ncomp = ncomp,
                        keepX = keepX_opt )
       
       return(fold_list)
       })
  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(res_list, output_file)
  output_file
}
