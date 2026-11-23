#########################################################
# TCGA: Calculate prediction performance
# Calculate Brier score, AUC, F1 score, and runtime
# for each method, dataset, and cross-validation fold.
# Run from: tcga-use-case-study/scripts
#########################################################

# Load project paths, functions, and packages.
source("../init.R", chdir = TRUE)

# Create Brier score 
brier_fun <- function(pred, truth) {
  valid <- complete.cases(pred, truth)
  mean((pred[valid] - truth[valid])^2)
}


models <- c("best", "wa", "lr", "lasso", "cobra", "ranger",
            "ref_diablo", "ref_bf", "priolasso", "priolasso_miss" ,
            "ref_srf_25_8" , "ref_srf_miss_25_8")


for (model in models) {
  
  model_path <- file.path(results_path, model)
  file_path  <- file.path(model_path, "prediction_results_2026.rds")
  
  if (!file.exists(file_path)) next
  
  # read RDS for one model
  results_list <- readRDS(file_path)
  
  # disease
  # names(results_list)
  # [1] "LGG_TERT.promoter.status"   "LGG_TERT.expression.status"
  # [3] "PRAD_ERG_status"            "STAD_Copy.Number.Cluster"
  for (nam in names(results_list)) {
    
    # all 10 folds for one desiase
    folds <- results_list[[nam]]
    
    # Folds
    for (i in seq_along(folds)) {
      
      # one fold pred_truth
      df <- folds[[i]]$pred_truth
      
      layer_names <- c("rna", "mirna", "rppa", "meta_layer")
      if (all(layer_names %in% names(df))) {

        for (layer_name in layer_names) {
          
            pred  <- as.numeric(as.character(df[[layer_name]]))
            truth <- as.numeric(as.character(df[["target"]]))
            
            valid <- complete.cases(pred, truth)
            
            pred_v  <- pred[valid]
            truth_v <- truth[valid]
            
            # Brier score
            bs <- brier_fun(pred_v, truth_v)
            
            #  AUC 
            auc_val <- tryCatch({
              as.numeric(pROC::auc(pROC::roc(truth_v, pred_v, quiet = TRUE)))
            }, error = function(e) NA_real_)
            
            # F1 
            f1_val <- MLmetrics::F1_Score(
              y_true = truth_v,
              y_pred = as.numeric(pred_v > 0.5),
              positive = 1)
      
          
          df[[paste0(layer_name, "_brier")]] <- bs
          df[[paste0(layer_name, "_auc")]]   <- auc_val
          df[[paste0(layer_name, "_f1")]]    <- f1_val
        
        }
        df$Runtime_fuse = as.numeric(df$Runtime, units = "secs") +
          as.numeric(df$Runtime_basemodel, units = "secs")
        
      } else{
         
        pred  <- as.numeric(as.character(df[["predictions"]]))
        truth <- as.numeric(as.character(df[["target"]]))
        
        valid <- complete.cases(pred, truth)
        pred_v  <- pred[valid]
        truth_v <- truth[valid]
            
        # Brier score
        bs <- brier_fun(pred_v, truth_v)
            
        # AUC 
        auc_val <- tryCatch({
          as.numeric(pROC::auc(pROC::roc(truth_v, pred_v, quiet = TRUE)))
          }, error = function(e) NA_real_)
            
        # F1
        f1_val <- MLmetrics::F1_Score(
          y_true = truth_v,
          y_pred = as.numeric(pred_v > 0.5),
          positive = 1)
        
        df$brier_score <- bs
        df$auc_score   <- auc_val
        df$f1_score    <- f1_val
        df$Runtime_fuse = as.numeric(df$Runtime, units = "secs")
        
      }
      
      folds[[i]] <- list(pred_truth = df)
    }
    
    results_list[[nam]] <- folds
  }
  
  saveRDS(results_list,
    file = file.path(model_path, "prediction_results_perf_2026.rds"))
}

