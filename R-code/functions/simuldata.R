simuldata <- function(seed,
                      intersim_path,
                      save_path,
                      empirical_param_prefix,
                      n.sample = 500,
                      cluster.sample.prop = c(0.5, 0.5),
                      delta.methyl,
                      delta.expr,
                      delta.protein,
                      p.DMP = 0.2,
                      p.DEG = NULL,
                      p.DEP = NULL,
                      do.plot = FALSE,
                      sample.cluster = TRUE,
                      feature.cluster = FALSE,
                      training_prop = 0.8,
                      prop_missing_train = 0,
                      prop_missing_test = 0,
                      function_dir) {
  if (file.exists(save_path)) {
    unlist(save_path)    
  }
  source(file.path(function_dir, "myInterSIM.R"))
  # Load global InterSIM's global variables
  # Protein parameters
  mean.protein <<- readRDS(file = file.path(empirical_param_prefix,
                                           "mean_protein.rds"))
  cov.protein <<- readRDS(file = file.path(empirical_param_prefix,
                                          "cov_protein.rds"))
  protein.gene.map.for.DEP <<- readRDS(
    file = file.path(empirical_param_prefix, "protein_gene_map_for_DEP.rds"))
  mean.expr.with.mapped.protein <<- readRDS(
    file = file.path(empirical_param_prefix,
                     "mean_expr_with_mapped_protein.rds"))
  # Methylation parameters
  mean.M <<- readRDS(file = file.path(empirical_param_prefix, "mean_M.rds"))
  cov.M <<- readRDS(file = file.path(empirical_param_prefix, "cov_M.rds"))
  CpG.gene.map.for.DEG <<- readRDS(
    file = file.path(empirical_param_prefix, "CpG_gene_map_for_DEG.rds"))
  methyl.gene.level.mean <<- readRDS(
    file = file.path(empirical_param_prefix, "methyl_gene_level_mean.rds"))
  # Gene expression parameters
  mean.expr <<- readRDS(file = file.path(empirical_param_prefix,
                                        "mean_expr.rds"))
  cov.expr <<- readRDS(file = file.path(empirical_param_prefix,
                                       "cov_expr.rds"))
  # Methylation-gene and protein-gene correlation estimates
  rho.methyl.expr <<- readRDS(file = file.path(empirical_param_prefix,
                                              "rho_methyl_expr.rds"))
  rho.expr.protein <<- readRDS(file = file.path(empirical_param_prefix,
                                               "rho_expr_protein.rds"))
  # Start simulation
  set.seed(seed)
  multi_omics <- simOmicsData(n.sample = n.sample,
                              cluster.sample.prop = cluster.sample.prop,
                              delta.methyl = delta.methyl,
                              delta.expr = delta.expr,
                              delta.protein = delta.protein,
                              p.DMP = p.DMP,
                              p.DEG = p.DEG,
                              p.DEP = p.DEP,
                              sigma.methyl = cov.M,
                              sigma.expr = cov.expr,
                              sigma.protein = cov.protein,
                              cor.methyl.expr = rho.methyl.expr,
                              cor.expr.protein = rho.expr.protein,
                              do.plot = do.plot,
                              sample.cluster = sample.cluster,
                              feature.cluster = feature.cluster,
                              training_prop = training_prop,
                              prop_missing_train = prop_missing_train,
                              prop_missing_test = prop_missing_test)
  # Save the data
  if (prop_missing_train == 0) {
    save_path <- save_path
  } else {
    save_path <- sub("\\.rds$",
                     sprintf("_missingness%s.rds", prop_missing_train * 100L),
                     save_path)
  }
  dir.create(dirname(save_path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(object = multi_omics, file = save_path)
  return(save_path)
}