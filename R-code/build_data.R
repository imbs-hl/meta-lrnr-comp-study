source(file.path(code_dir, "myInterSIM.R"))

# Load global InterSIM's global variables

# Protein parameters
mean.protein <- readRDS(file = file.path(data_tcga, "mean_protein.rds"))
cov.protein <- readRDS(file = file.path(data_tcga, "cov_protein.rds"))
protein.gene.map.for.DEP <- readRDS(
  file = file.path(data_tcga, "protein_gene_map_for_DEP.rds"))
mean.expr.with.mapped.protein <- readRDS(
  file = file.path(data_tcga, "mean_expr_with_mapped_protein.rds"))

# Methylation parameters
mean.M <- readRDS(file = file.path(data_tcga, "mean_M.rds"))
cov.M <- readRDS(file = file.path(data_tcga, "cov_M.rds"))
CpG.gene.map.for_DEG <- readRDS(
  file = file.path(data_tcga, "CpG_gene_map_for_DEG.rds"))
methyl.gene.level.mean <- readRDS(
  file = file.path(data_tcga, "methyl_gene_level_mean.rds"))

# Gene expression parameters
mean.expr <- readRDS(file = file.path(data_tcga, "mean_expr.rds"))
cov.expr <- readRDS(file = file.path(data_tcga, "cov_expr.rds"))

# Methylation-gene and protein-gene correlation estimates
rho.methyl.expr <- readRDS(file = file.path(data_tcga, "rho_methyl_expr.rds"))
rho.expr.protein <- readRDS(file = file.path(data_tcga, "rho_expr_protein.rds"))

set.seed(3252)
prop <- c(0.5, 0.5)
effect <- 0.5
start_time <- Sys.time()
multi_omics <- simOmicsData(n.sample = 100,
                            cluster.sample.prop = prop,
                            delta.methyl = effect,
                            delta.expr = effect,
                            delta.protein = 0L,
                            p.DMP = 0.2,
                            p.DEG = NULL,
                            p.DEP = NULL,
                            sigma.methyl = cov.M,
                            sigma.expr = cov.expr,
                            sigma.protein = cov.protein,
                            cor.methyl.expr = rho.methyl.expr,
                            cor.expr.protein = rho.expr.protein,
                            do.plot = FALSE,
                            sample.cluster = TRUE,
                            feature.cluster = FALSE,
                            training_prop = 0.8,
                            prop_missing_train = 0,
                            prop_missing_test = 0)
end_time <- Sys.time()
runtime <- end_time - start_time
print(runtime)

# Save this as test data
saveRDS(object = multi_omics,
        file = file.path(data_simulation, "multi_omics.rds"))
multi_omics <- readRDS(file.path(data_simulation, "multi_omics.rds"))
