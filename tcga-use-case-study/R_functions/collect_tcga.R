###############################################################################
# Collect the completed TCGA training results.
#
# This function combines the results from the four disease-specific
# batchtools jobs into a single list and saves it as an RDS file.
###############################################################################

collect_tcga <- function(method) {
  params <- tcga_param_data[[method]]
  if (is.null(params)) stop("Unknown method: ", method)
  
  reg <- batchtools::loadRegistry(file.path(registry_path,
                                            method),
                                  writeable = FALSE)
  if (nrow(batchtools::findDone(reg = reg)) != 4L ||
      nrow(batchtools::findNotDone(reg = reg)) != 0L) {
    stop("All four disease jobs must finish successfully before collection: ",
         method)
  }

  
  input_method <- names(Filter(function(spec) {
    identical(spec$output, tcga_methods[[method]]$input)
  }, tcga_methods))
  
  if (length(input_method) == 1L) {
    names_file <- tcga_param_data[[input_method]]$input_file[1L]
  } else {
    names_file <- params$input_file[1L]
  }
  
  diseases <- names(readRDS(names_file))
  
  stopifnot(length(diseases) == 4L, !anyNA(diseases),
            all(nzchar(diseases)), !anyDuplicated(diseases))
  
  results_list <- lapply(params$output_file, readRDS)
  
  stopifnot(all(lengths(results_list) == 10L))
  
  names(results_list) <- diseases

  output_file <- file.path(
    results_path,
    tcga_methods[[method]]$output,
    "prediction_results_2026.rds"
  )
  saveRDS(results_list, output_file)
  invisible(output_file)
}
