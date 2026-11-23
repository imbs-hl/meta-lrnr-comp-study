
# This function runs a single simulation replicate using PriorityLasso.

single_run_priolasso <- function (
    data_file,
    seed = 124,
    family = "binomial",
    type.measure = "auc",
    standardize = TRUE, 
    nfolds = 10,
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
  x_training <- as.matrix(x_training)
  
  ncol_methyl <- ncol(multi_omics$training$methylation) - 1 # IDS column removed
  ncol_genexpr <- ncol(multi_omics$training$geneexpr) - 1
  ncol_proteinexpr <- ncol(multi_omics$training$proteinexpr) - 1
  
  block_methyl <- 1:(ncol_methyl)
  block_genexpr <- (ncol_methyl + 1):(ncol_methyl + ncol_genexpr)
  block_proteinexpr <- (ncol_methyl + ncol_genexpr + 1):(ncol_methyl + ncol_genexpr + ncol_proteinexpr)
  
  # Testing dataset
  x_testing <- multi_omics$testing$methylation %>%
    full_join(multi_omics$testing$geneexpr, by = "IDS") %>%
    full_join(multi_omics$testing$proteinexpr, by = "IDS")
  

  test_ids <- x_testing$IDS
  x_testing$IDS <- NULL
  x_testing <- as.matrix(x_testing)
  
  # Missing-data handling
  if (na_action == "na.keep") {
    # Missing values are kept as they are.
    # prioritylasso does NOT perform any missing-data handling.
    mcontrol <- missing.control(
      handle.missingdata = "none")
    
    handle_missingtestdata <- "none"
    # At the moment, a crossvalidated offset is only supported for complete data sets
    cv_offset = TRUE
    
    } else if (na_action == "na.impute") {
    
    mcontrol <- missing.control(
      handle.missingdata = "impute.offset",
      offset.firstblock = "zero",
      impute.offset.cases = "available.cases",
      nfolds.imputation = 10,
      lambda.imputation = "lambda.1se",
      perc.comp.cases.warning = 0.3,
      threshold.available.cases = 30,
      select.available.cases = "maximise.blocks")
    
    handle_missingtestdata <- "impute.block"
    # At the moment, a crossvalidated offset is only supported for complete data sets
    cv_offset = FALSE
    
  } else {
    stop("na_action must be either 'na.keep' or 'na.impute'.")
    }
  
  # Define all posible block priorities

  blocks_list <- list(
    # 1. Methylation -> Gene expression -> Protein
    list(methylation = block_methyl,
         geneexpr = block_genexpr,
         proteinexpr = block_proteinexpr),
    # 2. Methylation -> Protein -> Gene expression
    list(methylation = block_methyl,
         proteinexpr = block_proteinexpr,
         geneexpr = block_genexpr),
    # 3. Gene expression -> Methylation -> Protein
    list(geneexpr = block_genexpr,
         methylation = block_methyl,
         proteinexpr = block_proteinexpr),
    # 4. Gene expression -> Protein -> Methylation
    list(geneexpr = block_genexpr,
         proteinexpr = block_proteinexpr,
         methylation = block_methyl),
    # 5. Protein -> Methylation -> Gene expression
    list(proteinexpr = block_proteinexpr,
         methylation = block_methyl,
         geneexpr = block_genexpr),
    # 6. Protein -> Gene expression -> Methylation
    list(proteinexpr = block_proteinexpr,
         geneexpr = block_genexpr,
         methylation = block_methyl))
  priority_names <- c("methylation_geneexpr_proteinexpr",
                      "methylation_proteinexpr_geneexpr",
                      "geneexpr_methylation_proteinexpr",
                      "geneexpr_proteinexpr_methylation",
                      "proteinexpr_methylation_geneexpr",
                      "proteinexpr_geneexpr_methylation")
  set.seed(seed)
  start_time <- Sys.time()  # Record start time
  message("Selecting optimal PriorityLasso block order...\n")
  # Compare all six possible priority structures
  cv_priority <- cvm_prioritylasso(X = x_training,
                                   Y = as.numeric(y_training == "1"),
                                   family = family,
                                   type.measure = type.measure,
                                   blocks.list = blocks_list,
                                   block1.penalization = TRUE,
                                   lambda.type = "lambda.1se",
                                   standardize = standardize,
                                   nfolds = nfolds,
                                   # At the moment, a crossvalidated offset is only supported for complete data sets
                                   cvoffset = cv_offset,
                                   mcontrol = mcontrol,
                                   nlambda = 100)
  # Extract best model
  best_blocks <- cv_priority$best.blocks
  message("Selected block priority: ", best_blocks,"\n")

  message("Predicting on independent test data...\n")

  model_pl <- cv_priority$best.model
 # We predict
 predictions <- predict(object = model_pl,
                         newdata = x_testing,
                         handle.missingtestdata = handle_missingtestdata,
                         include.allintercepts = TRUE,
                         type = "response")
  
  end_time <- Sys.time()  # Record end time
  pred_values <- data.frame(test_ids, predictions)
  names(pred_values) <- c("IDS", "predictions")
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  
  runtime <- end_time - start_time
  # Save the Training object
  training_file <- file.path(sub("data$", "train/priolasso", dirname(data_file)),
                             sub( "_prop_miss", "_priolasso_prop_miss",
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
    dim_test = dim(x_testing),
    best_blocks = best_blocks),
    file = training_file)
  
  
  return(list(
    actual_pred = actual_pred,
    runtime = runtime,
    dim_train = dim(x_training),
    dim_test = dim(x_testing),
    best_blocks = best_blocks))
}
