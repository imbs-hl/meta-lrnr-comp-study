
# This function runs a single simulation replicate using BlockForest.

single_run_bf <- function (
    data_file,
    seed = 124,
    na_action = "na.keep",
    num.trees = 25000L
) {
  multi_omics <- readRDS(data_file)
  
  # Training dataset
  x_training <- multi_omics$training$methylation %>%
    full_join(multi_omics$training$geneexpr, by = "IDS") %>%
    full_join(multi_omics$training$proteinexpr, by = "IDS")
    
  
  # Filter out rows with NA 
  complete_case_training <- complete.cases(x_training)
  x_training <- x_training[complete_case_training, ]
  
  # IDs of patients actually used for training
  training_ids <- x_training$IDS
  
  # Blocks
  ncol_methyl <- ncol(multi_omics$training$methylation) - 1 # IDS column removed
  ncol_genexpr <- ncol(multi_omics$training$geneexpr) - 1
  ncol_proteinexpr <- ncol(multi_omics$training$proteinexpr) - 1

  block_methyl <- 1:(ncol_methyl)
  block_genexpr <- (ncol_methyl + 1):(ncol_methyl + ncol_genexpr)
  block_proteinexpr <- (ncol_methyl + ncol_genexpr + 1):(ncol_methyl + ncol_genexpr + ncol_proteinexpr)
  
  blocks = list(methyl = block_methyl, 
                genexpr = block_genexpr, 
                proexpr = block_proteinexpr)
 
  x_training <- x_training %>%
     left_join(multi_omics$training$target, by = "IDS")
   
  
  # Testing dataset
  x_testing <- multi_omics$testing$methylation %>%
    full_join(multi_omics$testing$geneexpr, by = "IDS") %>%
    full_join(multi_omics$testing$proteinexpr, by = "IDS")
  
  complete_case_testing <- which(complete.cases(x_testing))
  x_testing <- x_testing[complete_case_testing, ]
  test_ids <- x_testing$IDS
  x_testing$IDS <- NULL
  
  set.seed(seed)
  start_time <- Sys.time()  # Record start time
  # We train BF model
  message("Training of BF model started...\n")
  bf_trained <- blockfor(X = x_training[, setdiff(names(x_training),
                                                  c("IDS", "disease")),
                                         drop = FALSE],
                          y = x_training[, "disease"],
                          blocks = blocks,
                          block.method = "BlockForest",
                          num.trees = num.trees,
                          probability = TRUE)
  
  # # We predict
  predictions <- predict(object = bf_trained$forest,
                         data = as.data.frame(x_testing),
                         block.method = "BlockForest")


  end_time <- Sys.time()  # Record end time
  pred_values <- data.frame(test_ids, predictions$predictions[ , 2])
  
  names(pred_values) <- c("IDS", "predictions")
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  
  runtime <- end_time - start_time
  # Save the Training object
  training_file <- file.path(sub("data$", "train/bf", dirname(data_file)),
                             sub( "_prop_miss", "_bf_prop_miss",
                                  sub("\\.rds$", paste0("_", na_action, ".rds"),
                                      basename(data_file))))
  
  training_dir <- dirname(training_file)
  if (!dir.exists(training_dir)) {
    dir.create(training_dir, recursive = TRUE)
  }
  
  saveRDS(object = list(actual_pred = actual_pred,
                        runtime = runtime,
                        dim_train = dim(x_training),
                        dim_test = dim(x_testing)),
          file = training_file)
  
  
  return(list(actual_pred = actual_pred,
              runtime = runtime,
              dim_train = dim(x_training),
              dim_test = dim(x_testing)))
}
