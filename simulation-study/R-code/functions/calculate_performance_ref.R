# Function: calculate performance for reference methods

calculate_performance_ref <- function(
    input_file,
    delta.methyl = NULL,
    delta.expr = NULL,
    delta.protein = NULL,
    effect = NULL,
    seed = NULL,
    result_dir,
    folder 
) {
  # Load saved training results
  result <- readRDS(input_file)
  # Extract predictions and runtime
  actual_pred <- result$actual_pred
  runtime <- result$runtime
  dim_train <- result$dim_train
  dim_test <- result$dim_test

  # Convert true labels into numeric format (0/1)
  y <- as.numeric(actual_pred$disease == "1")
  # Calculate performance measures for each prediction column
  my_pred <- actual_pred[, "predictions"]
  complete <- complete.cases(my_pred)
  
  # Brier Score
  bs <- mean((y[complete] - my_pred[complete])^2)
  
  # AUC
  roc_obj <- pROC::roc(y[complete], my_pred[complete])
  auc <- pROC::auc(roc_obj)
  
  # F1
  f1 <- MLmetrics::F1_Score(
    y_true = y[complete],
    y_pred = as.numeric(my_pred[complete] > 0.5),
    positive = 1)
  
  perf <- c(BS = bs, AUC = auc, F1 = f1)
  
  # Convert results to data.frame
  perf <- as.data.frame(perf)
  perf$perf_measure <- rownames(perf)
  
  perf$delta.methyl <- delta.methyl
  perf$delta.expr <- delta.expr
  perf$delta.protein <- delta.protein
  
  perf$seed <- seed
  perf$effect <- effect
  
  perf$runtime <- runtime
  
  perf$dim_train <- paste(dim_train[1], dim_train[2], sep = " x ")
  perf$dim_test <- paste(dim_test[1], dim_test[2], sep = " x ")
  
  if(folder == "priolasso"){
    perf$best_blocks <- paste(result$best_blocks)
    }
  # Save performance results
  output_file <- file.path(result_dir, folder, basename(input_file))
  
  output_dir <- dirname(output_file)
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  saveRDS(object = perf,
          file = output_file)
  return(perf)
  
}

