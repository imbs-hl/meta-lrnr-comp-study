
# This function runs a single simulation replicate using random forests (na.learn)
single_run_srf_mis <- function (
    data_file,
    seed = 124,
    num.tree.boruta = 25000L,
    num.tree.ranger = 15000L,
    na_action = "na.learn"
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
  
  # Testing dataset
  x_testing <- multi_omics$testing$methylation %>%
    full_join(multi_omics$testing$geneexpr, by = "IDS") %>%
    full_join(multi_omics$testing$proteinexpr, by = "IDS") 
  
  test_ids <- x_testing$IDS
  x_testing$IDS <- NULL
  x_testing <- as.matrix(x_testing)
  
  set.seed(seed)
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
  srf_model <- ranger(x = x_training[ , varsel, drop = FALSE],
                      y = y_training,
                      num.trees = num.tree.ranger,
                      na.action = na_action,
                      probability = TRUE)
  
  # We predict on the test set
  predictions <- predict(object = srf_model,
                         data = x_testing[ , varsel, drop = FALSE])
  end_time <- Sys.time()  # Record end time
  pred_values <- data.frame(test_ids, predictions$predictions[ , 2L])
  names(pred_values) <- c("IDS", "predictions")
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  runtime <- end_time - start_time
  
  
  # Save the Training object
  training_file <- file.path(sub("data$", "train/srf_mis", dirname(data_file)),
                             sub( "_prop_miss", "_srf_prop_miss",
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
