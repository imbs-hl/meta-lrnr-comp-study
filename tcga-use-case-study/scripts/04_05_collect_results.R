#########################################################
# TCGA: Collect training results
# Collect completed results for each method after the
# batchtools jobs have finished.
# Run from: tcga-use-case-study/scripts
#########################################################

source("../init.R", chdir = TRUE)

# fuseMLR and reference methods.
methods <- c(
  "train_rf", "train_best", "train_wa",
  "train_cobra", "train_lasso", "train_lr",
  "train_ref_bf", "train_ref_diablo",
   "train_ref_priolasso_miss",
  "train_ref_srf", "train_ref_srf_miss"
)

collection_status <- data.frame(
  method = methods,
  success = FALSE,
  message = NA_character_
)

for (i in seq_along(methods)) {
  method <- methods[i]
  message("Collect: ", method)

  tryCatch({
    output_file <- collect_tcga(method)
    collection_status$success[i] <- TRUE
    collection_status$message[i] <- output_file
    message("Saved: ", output_file)
  }, error = function(e) {
    collection_status$message[i] <<- conditionMessage(e)
    message("Not saved: ", method, ": ", conditionMessage(e))
  })
}

# Summary: incomplete/missing registries and other errors do not stop the loop.
print(collection_status, row.names = FALSE)
