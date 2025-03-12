# This file will run a single replication and estimate prediction performances.
# The code is similar to the code provided in the vignette of fuseMLR.
# TODO: Include ranger hyperparameter as arguments of single_replicate.
single_run_best <- function (
    data_file = file.path(data_simulation, "multi_omics.rds"),
    seed = 124,
    delta.methyl = param_df$delta.methyl,
    delta.expr = param_df$delta.expr,
    delta.protein = param_df$delta.protein,
    effect = "effect",
    num.tree.boruta.methyl = 25000L,
    num.tree.ranger.methyl = 5000L,
    num.tree.boruta.genexpr = 10000L,
    num.tree.ranger.genexpr = 2000L,
    num.tree.boruta.proexpr = 5000L,
    num.tree.ranger.proexpr = 1000L
) {
  multi_omics <- readRDS(data_file)
  # Set up a training object
  training <- createTraining(id = "training",
                             ind_col = "IDS",
                             target = "disease",
                             target_df = multi_omics$training$target,
                             verbose = FALSE)
  # Create methylation layer
  createTrainLayer(training = training,
                   train_layer_id = "methylation",
                   train_data = multi_omics$training$methylation,
                   varsel_package = "Boruta",
                   varsel_fct = "Boruta",
                   varsel_param = list(num.trees = num.tree.boruta.methyl,
                                       # mtry = 3L,
                                       probability = TRUE),
                   lrner_package = "ranger",
                   lrn_fct = "ranger",
                   param_train_list = list(num.trees = num.tree.ranger.methyl,
                                           probability = TRUE),
                   param_pred_list = list(),
                   na_action = "na.keep")
  # Create gene expression layer.
  createTrainLayer(training = training,
                   train_layer_id = "geneexpr",
                   train_data = multi_omics$training$geneexpr,
                   varsel_package = "Boruta",
                   varsel_fct = "Boruta",
                   varsel_param = list(num.trees = num.tree.boruta.genexpr,
                                       # mtry = 3L,
                                       probability = TRUE),
                   lrner_package = "ranger",
                   lrn_fct = "ranger",
                   param_train_list = list(num.trees = num.tree.ranger.genexpr,
                                           probability = TRUE),
                   param_pred_list = list(),
                   na_action = "na.keep")
  
  # Create gene protein abundance layer
  createTrainLayer(training = training,
                   train_layer_id = "proteinexpr",
                   train_data = multi_omics$training$proteinexpr,
                   varsel_package = "Boruta",
                   varsel_fct = "Boruta",
                   varsel_param = list(num.trees = num.tree.boruta.proexpr,
                                       # mtry = 3L,
                                       probability = TRUE),
                   lrner_package = "ranger",
                   lrn_fct = "ranger",
                   param_train_list = list(num.trees = num.tree.ranger.proexpr,
                                           probability = TRUE),
                   param_pred_list = list(type = "response"),
                   na_action = "na.keep")
  
  # Create meta layer with imputation of missing values.
  createTrainMetaLayer(training = training,
                       meta_layer_id = "meta_layer",
                       lrner_package = NULL,
                       lrn_fct = "bestLayerLearner",
                       param_train_list = list(),
                       param_pred_list = list(na_rm = TRUE),
                       na_action = "na.rm")
  # Variable selection
  set.seed(seed)
  var_sel_res <- varSelection(training = training)
  start_time <- Sys.time()  # Record start time
  fusemlr(training = training,
          use_var_sel = TRUE)
  # Create testing for predictions
  testing <- createTesting(id = "testing",
                           ind_col = "IDS")
  # Create methylation layer
  createTestLayer(testing = testing,
                  test_layer_id = "methylation",
                  test_data = multi_omics$testing$methylation)
  # Create gene expression layer
  createTestLayer(testing = testing,
                  test_layer_id = "geneexpr",
                  test_data = multi_omics$testing$geneexpr)
  # Create gene protein abundance layer
  createTestLayer(testing = testing,
                  test_layer_id = "proteinexpr",
                  test_data = multi_omics$testing$proteinexpr)
  predictions <- predict(object = training, testing = testing)
  end_time <- Sys.time()  # Record end time
  pred_values <- predictions$predicted_values
  actual_pred <- merge(x = pred_values,
                       y = multi_omics$testing$target,
                       by = "IDS",
                       all.y = TRUE)
  y <- as.numeric(actual_pred$disease == "1")
  # On all patients
  perf_bs <- sapply(X = actual_pred[ , 2L:5L], FUN = function (my_pred) {
    bs <- mean((y[complete.cases(my_pred)] - my_pred[complete.cases(my_pred)])^2)
    # bs2 <- mean((y[complete.cases(my_pred)] - (1 - my_pred[complete.cases(my_pred)]))^2)
    # bs <- min(bs1, bs2)
    roc_obj <- pROC::roc(y[complete.cases(my_pred)], my_pred[complete.cases(my_pred)])
    auc <- pROC::auc(roc_obj)
    performances = rbind(bs, auc)
    return(performances)
  })
  rownames(perf_bs) <- c("BS", "AUC")
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
                                            sprintf("%s_meta.rds", effect),
                                            collapse = ""))
  saveRDS(object = training, file = training_file)
  return(perf_bs)
}

# tmp <- single_replicate_best(data_file = file.path(data_simulation, "multi_omics_null.rds"))
if (FALSE)
tmp <- single_run_best(
  data_file = param_df_proexpr$save_path[3],
  seed = param_df_proexpr$seed[3],
  delta.methyl = param_df_proexpr$delta.methyl[3],
  delta.expr = param_df_proexpr$delta.expr[3],
  delta.protein = param_df_proexpr$delta.protein[3]
  )
