# Function: calculate performance

calculate_performance <- function(
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
  # Convert true labels into numeric format (0/1)
  y <- as.numeric(actual_pred$disease == "1")
  # Calculate performance measures for each prediction column
  perf <- sapply(
    X = actual_pred[, c("methylation", "geneexpr", "proteinexpr", "meta_layer")],
    FUN = function(my_pred) {
      complete <- complete.cases(my_pred)
      # Brier Score
      bs <- mean((y[complete] - my_pred[complete])^2)
      # AUC
      roc_obj <- pROC::roc(y[complete],
                           my_pred[complete],
                           levels = c(0, 1), direction = "<")
      auc <- pROC::auc(roc_obj)
      # F1
      f1 <- MLmetrics::F1_Score(
        y_true = y[complete],
        y_pred = as.numeric(my_pred[complete] > 0.5),
        positive = 1)
      
      c(BS = bs,
        AUC = auc,
        F1 = f1)
      })
  
  rownames(perf) <- c("BS", "AUC", "F1")
  
  # Convert results to data.frame
  perf <- as.data.frame(perf)
  perf$perf_measure <- rownames(perf)
  
  perf$delta.methyl <- delta.methyl
  perf$delta.expr <- delta.expr
  perf$delta.protein <- delta.protein
  
  perf$seed <- seed
  perf$effect <- effect
  
  perf$runtime <- runtime
  runtime_basemodel <- result$runtime_basemodel
  if (is.null(runtime_basemodel)) {
    runtime_basemodel <- as.difftime(NA_real_, units = "secs")
  }
  perf$runtime_basemodel <- runtime_basemodel
  perf$runtime_fuse <- runtime + runtime_basemodel
  
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



plot_prediction_distribution <- function(
    input_file,
    szenarien,
    result_dir,
    name) {
  
  extract_scenario <- function(x) {
    stringr::str_extract(
      x,
      "(null|low|moderate)_(null|low|moderate)_(null|low|moderate)"
    )
  }
  
  # ---------------------------------------------------------
  # Read all files and combine predictions
  # ---------------------------------------------------------
  plot_data <- lapply(input_file, function(file) {
    
    result <- readRDS(file)
    
    actual_pred <- result$actual_pred
    
    data.frame(
      scenario = extract_scenario(file),
      disease = factor(
        actual_pred$disease,
        levels = c(0, 1)
      ),
      predictions = actual_pred$predictions
    )
    
  }) %>% 
    dplyr::bind_rows()
  
  # Remove missing values
  plot_data <- plot_data[
    complete.cases(plot_data),
  ]
  
  # ---------------------------------------------------------
  # Set scenario order
  # ---------------------------------------------------------
  plot_data$scenario <- factor(
    plot_data$scenario,
    levels = szenarien
  )
  
  # ---------------------------------------------------------
  # Create plot
  # ---------------------------------------------------------
  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = scenario,
      y = predictions,
      fill = disease
    )
  ) +
    
    ggplot2::geom_boxplot(
      position = ggplot2::position_dodge(width = 0.8),
      width = 0.6,
      outlier.shape = NA
    ) +
    
    ggplot2::geom_jitter(
      ggplot2::aes(
        group = disease
      ),
      position = ggplot2::position_jitterdodge(
        jitter.width = 0.08,
        dodge.width = 0.8
      ),
      alpha = 0.4,
      size = 1.5
    ) +
    
    ggplot2::geom_hline(
      yintercept = 0.5,
      linetype = "dashed"
    ) +
    
    ggplot2::labs(
      x = "Scenario",
      y = "Prediction",
      fill = "Actual disease class",
      title = "Distribution of predictions by scenario and actual class"
    ) +
    
    ggplot2::theme_classic()
  
  # ---------------------------------------------------------
  # Save plot
  # ---------------------------------------------------------
  
  output_file <- file.path(
    result_dir,
    name
  )
  
  output_dir <- dirname(output_file)
  
  if (!dir.exists(output_dir)) {
    dir.create(
      output_dir,
      recursive = TRUE
    )
  }
  
  ggplot2::ggsave(
    filename = output_file,
    plot = p,
    width = 10,
    height = 6,
    dpi = 300
  )
}
