# This file estimates InterSIM required information for simulation of 
# multi-omics data, including modality-specific means and covariances, methyla-
# tion-gene and protein-gene mapping summary information.

# This code requires substantial memory resources. Use used 50g and 5 CPUs.

# We use TCGA from the Breast Invasive Carcinoma study. The corresponding PDC
# study ID is PDC000173. Global proteome and phosphoproteome data have been 
# acquired for 105 TCGA breast cancer samples using iTRAQ (isobaric Tags for 
# Relative and Absolute Quantification) protein quantification methods. Samples 
# were selected from each of the 4 breast tumor subtypes (Luminal A, Luminal B, 
# Basal-like, HER2-enriched) described in the publication.
brca <- curatedTCGAData(
  diseaseCode = "BRCA",
  assays = c("RNASeqGene",
             "RPPAArray",
             "Methylation*"),
  version = "1.1.38",
  dry.run = FALSE
)
brca_assays <- assays(x = brca)
prop.table(table(colData(brca)$gender))

#' This function removes variables with 0 scale values.
#'
#' @param x A data matrix.
#'
#' @return A data matrix without variables with 0 scale values.
rm_zero_scale <- function(x) {
  my_wm <- wt.moments(x)
  my_sc <- sqrt(my_wm$var)
  my_zeros <- (my_sc == 0.0)
  return(x[ , !my_zeros])
}

# Preprocessing
genexprdata <- brca_assays$`BRCA_RNASeqGene-20160128`
# We also keep known gene from gene expression data
gene_ids <- rownames(genexprdata)
gene_ids_clean <- sub("\\..*", "", gene_ids) 
# Map to gene symbols using org.Hs.eg.db
gene_symbols <- mapIds(
  x = org.Hs.eg.db,
  keys = gene_ids_clean,
  column = "SYMBOL",
  keytype = "SYMBOL",
  multiVals = "first"
)
# No gene has been removed.
genexprdata <- genexprdata[rownames(genexprdata) %in% gene_symbols, ]
# Remove this specific gene with 0 value for all individuals except for some 
# small number (1 or 3) of individuals.
genexprdata <- genexprdata[!(rownames(genexprdata) %in% c("SNORD115-32",
                                                          "HBII-52-45")), ]
genexprdata <- rm_zero_scale(x = t(genexprdata))

# Protein expression data.
proexprdata <- fread(file = file.path(data_tcga, "protein.txt"),
                     sep = "\t")

methyldata <- as.matrix(assay(brca_assays$`BRCA_Methylation_methyl450-20160128`))
methyldata <- methyldata[complete.cases(methyldata), ]

# =========================================================================== */
# Preprocessing of protein data                                               */
# =========================================================================== */
#
# protein_gene_map_for_DEP: Prepare data having protein names and mapped gene
# names

# Filter proteins with mapping genes
mapped_pro_gen_index <- which(proexprdata$Gene %in% colnames(genexprdata))
mapped_pro_gen <- data.frame(protein = proexprdata$Gene[mapped_pro_gen_index],
                             gene = proexprdata$Gene[mapped_pro_gen_index])
protein_gene_map_for_DEP <- mapped_pro_gen[!duplicated(mapped_pro_gen), ]
proexprdata_mapped <- as.data.frame(proexprdata[proexprdata$Gene %in% 
                                                  protein_gene_map_for_DEP$protein, -1])
rownames(proexprdata_mapped) <- proexprdata$Gene[proexprdata$Gene %in% 
                                                   protein_gene_map_for_DEP$protein]
mean_protein <-  rowMeans(x = as.matrix(proexprdata_mapped))
cov_protein <- cov.shrink(x = t(proexprdata_mapped))

# mean_expr_with_mapped_protein: Compute the mean of the gene expression values.
# Then prepare a data vector of mean of gene expressions in the same order that 
# map to proteins expression values. Note that some genes can correspond to more
# than one proteins. This data is used to generate protein expression data. 
mean_expr_with_mapped_protein <- colMeans(genexprdata)[protein_gene_map_for_DEP$gene]

# Save protein related data
saveRDS(object = proexprdata_mapped,
        file = file.path(data_tcga, "protein.rds"))
saveRDS(object = mean_protein,
        file = file.path(data_tcga, "mean_protein.rds"))
saveRDS(object = cov_protein,
        file = file.path(data_tcga, "cov_protein.rds"))
saveRDS(object = protein_gene_map_for_DEP,
        file = file.path(data_tcga, "protein_gene_map_for_DEP.rds"))
saveRDS(object = mean_expr_with_mapped_protein,
        file = file.path(data_tcga, "mean_expr_with_mapped_protein.rds"))

# =========================================================================== */
# Preprocessing of methylation data                                           */
# =========================================================================== */
#
# We retain CpG site located on known genes, gene-wise low correlated and with 
# higher  (0.95 quantile) variability or located on a gene that maps existing 
# protein.
# Get CpG site annotations.
anno <- getAnnotation(IlluminaHumanMethylation450kanno.ilmn12.hg19)
# Merge CpG coordinates with methylation data
methylation_anno <- merge(as.data.frame(methyldata), anno, by = "row.names")
# Convert to GRanges
cpg_gr <- GRanges(
  seqnames = methylation_anno$chr,
  ranges = IRanges(start = methylation_anno$pos, width = 1),
  strand = "*"
)
# Load gene annotation database
txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene
# Annotate CpG sites with gene information
annotated_peaks <- annotatePeak(cpg_gr, TxDb = txdb, annoDb = "org.Hs.eg.db")
# Filter CpG sites located within known genes
cpg_in_genes <- as.data.frame(annotated_peaks)
# Display relevant columns
cpg_in_genes[, c("seqnames",
                 "start",
                 "end",
                 "geneId",
                 "SYMBOL",
                 "annotation")]
cpg_in_genes$cpg_gr <- methylation_anno$Name
cpg_to_retrieve <- cpg_in_genes[ , c("seqnames", "start", "SYMBOL", "cpg_gr")]
colnames(cpg_to_retrieve) <- c("chr", "pos", "SYMBOL", "cpg_gr")
cpg_in_known_genes <- merge(x = methylation_anno, 
                            y = cpg_to_retrieve)[names(methylation_anno)]
cpg_chr_pos_known <- paste(cpg_in_known_genes$chr,
                           cpg_in_known_genes$pos,
                           sep = ":")
cpg_chr_pos <- paste(cpg_to_retrieve$chr,
                     cpg_to_retrieve$pos,
                     sep = ":")
cpg_gene_symbol <- cpg_in_genes[cpg_chr_pos %in% cpg_chr_pos_known, "SYMBOL"]

# # Alternative 1: Intersection with gene expression.
# inter_methyl_gene <- intersect(colnames(genexprdata), cpg_gene_symbol)
# print(length(inter_methyl_gene))
# # [1] 13198
# # Alternative 2: Methylation with higher variability, known gene and gene mapping
# # a protein.
# methylmoment <- wt.moments(t(methyldata))
# threshold <- quantile(methylmoment$var, 0.95)

# Extract CpG low correlated CpG pro gene.
gene_to_pro <- cpg_in_genes[cpg_in_genes$SYMBOL %in% protein_gene_map_for_DEP$gene, ]
combined_cpg_known_gene_and_pro <- data.frame(
  cpg_gr = c(cpg_in_genes$cpg_gr, gene_to_pro$cpg_gr),
  gene = c(cpg_in_genes$SYMBOL, gene_to_pro$SYMBOL)
)
split_cpg_gene <- split(combined_cpg_known_gene_and_pro$cpg_gr,
                        combined_cpg_known_gene_and_pro$gene)

# We choose low correlated CpG site with high variability.
cpg_filter <- lapply(1:length(split_cpg_gene), function(i, 
                                                        methyl,
                                                        split_cpg_gene,
                                                        cor_thres,
                                                        var_thres) {
  print(sprintf("i = %s...", i))
  # print(unlist(split_cpg_gene[i]))
  cpg_names <- unlist(split_cpg_gene[i])
  print(sprintf("I started with: %s", length(cpg_names)))
  if (length(cpg_names) == 1) {
    return(cpg_names)
  } else {
    tmp_methyl <- methyl[cpg_names, ]
  }
  tmp_methyl <- InterSIM::logit(tmp_methyl)
  # Empirical variance pro gene
  tmp_methylmoment <- wt.moments(t(tmp_methyl))
  # print(tmp_methylmoment$var)
  # Choose methylation with larger variability in each gene.
  large_var <- rownames(tmp_methyl)[tmp_methylmoment$var >= 
                                      quantile(tmp_methylmoment$var, 
                                               var_thres, na.rm = TRUE)]
  # Continue only if more than one variable remains.
  if (length(large_var) > 1) {
    tmp_methyl_reduced <- tmp_methyl[large_var, ]
  } else {
    return(large_var)
  }
  # Choose lower correlated CpG within each gene.
  cor_matrix <- cor.shrink(t(tmp_methyl_reduced))
  diag(cor_matrix) <- NA
  high_cor_pairs <- which(abs(cor_matrix) > cor_thres &
                            lower.tri(cor_matrix),
                          arr.ind = TRUE)
  vars_to_remove <- unique(colnames(tmp_methyl_reduced)[high_cor_pairs[ , 2]])
  print(sprintf("L = %s", length(vars_to_remove)))
  if(!length(vars_to_remove)) {
    to_keep <- setdiff(rownames(tmp_methyl_reduced), vars_to_remove)
    print(sprintf("I end with: %s", length(to_keep)))
    return(to_keep)
  } else {
    print(sprintf("I end with: %s", length(rownames(tmp_methyl_reduced))))
    return(rownames(tmp_methyl_reduced))
  }
}, 
methyl = methyldata,
split_cpg_gene = split_cpg_gene,
cor_thres = 0.75,
var_thres = 0.95)

final_methyl_names <- do.call("c", cpg_filter)
# Number of retained CpG sites
# length(final_methyl_names)
# [1] 40059
# Number of mapping known genes
print(
  length(
    unique(
      combined_cpg_known_gene_and_pro[
        combined_cpg_known_gene_and_pro$cpg_gr %in% 
          final_methyl_names, "gene"])))
# [1] 22988

high_methyl_var <- methyldata[final_methyl_names, ]
print(dim(high_methyl_var))
# [1] 40059   885
# CpG_gene_map_for_DEG: Prepare data having CpG probe names and mapped gene 
# names  
cpg_in_genes_expr <- cpg_in_genes[cpg_in_genes$SYMBOL %in% colnames(genexprdata), ]
cpg_in_genes_expr <- cpg_in_genes_expr[cpg_in_genes_expr$cpg_gr %in% 
                                         rownames(high_methyl_var), ]
CpG_gene_map_for_DEG <- data.frame(tmp.cg = cpg_in_genes_expr$cpg_gr, 
                                   tmp.gene = cpg_in_genes_expr$SYMBOL)
rownames(CpG_gene_map_for_DEG) <- cpg_in_genes_expr$cpg_gr
high_methyl_var <- high_methyl_var[cpg_in_genes_expr$cpg_gr, ]
# Logit tranformed methylation data
high_methyl_transf <- apply(X = t(high_methyl_var), 
                            MARGIN = 2,
                            FUN = function(x) {
                              InterSIM::logit(x)
                            })
colnames(high_methyl_transf) <- rownames(high_methyl_var)
rownames(high_methyl_transf) <- colnames(high_methyl_var)

# mean_M: logit transform the methylation data and calculate the mean of the 
# features
mean_M <-  colMeans(x = high_methyl_transf)
# cov_M:  covariance matrix of the logit transformed methylation data
cov_M <- cov.shrink(x = high_methyl_transf)

# methyl_gene_level_mean: Compute the gene level summary of the methylation data
# by the following way: For each tumor sample, group the CpG probes that map to
# unique genes together and compute the median values of each group. Then logit
# transform the data matrix and calculate mean for each gene level summary of
# the methylation data. In this way the number of mean values thus calculated
# matches the number of genes. This data is used to generate gene expression
# data. 
cpg_to_split <- cpg_in_genes[cpg_in_genes$cpg_gr %in% 
                               rownames(high_methyl_var),
                             c("cpg_gr", "SYMBOL")]
split_dfs <- split(cpg_to_split, cpg_to_split$SYMBOL)

methyl_gene_level <- lapply(1:length(split_dfs), function(i, 
                                                          df = df,
                                                          methyl = methyl){
  cpg_group <- df[[i]]$cpg_gr
  # Median for the cpg block.
  tmp_methyl <- apply(methyl[cpg_group, , drop = FALSE], 2L, median)
  # Logit transformation
  tmp_methyl <- InterSIM::logit(tmp_methyl)
  return(tmp_methyl)
}, df = split_dfs, methyl = high_methyl_var)

methyl_gene_level <- as.matrix(do.call(what = "rbind", methyl_gene_level))
rownames(methyl_gene_level) <- unique(cpg_to_split$SYMBOL)
methyl_gene_level_mean <- rowMeans(methyl_gene_level)

# Save methylation related data
saveRDS(object = high_methyl_transf,
        file = file.path(data_tcga, "methyldata.rds"))
saveRDS(object = mean_M,
        file = file.path(data_tcga, "mean_M.rds"))
saveRDS(object = cov_M,
        file = file.path(data_tcga, "cov_M.rds"))
saveRDS(object = CpG_gene_map_for_DEG,
        file = file.path(data_tcga, "CpG_gene_map_for_DEG.rds"))
saveRDS(object = methyl_gene_level,
        file = file.path(data_tcga, "methyl_gene_level.rds"))
saveRDS(object = methyl_gene_level_mean,
        file = file.path(data_tcga, "methyl_gene_level_mean.rds"))

# =========================================================================== */
# Preproccessing of gene data.                                                */
# =========================================================================== */
# 
# mean_expr: calculate the mean of the features in gene expression data
mean_expr <-  colMeans(x = genexprdata[, unique(CpG_gene_map_for_DEG$tmp.gene)])

# cov_expr:  covariance matrix of the gene expression data
cov_expr <- cov.shrink(x = genexprdata[, unique(CpG_gene_map_for_DEG$tmp.gene)])
# Save gene expression related data
genexprdata <- genexprdata[, unique(CpG_gene_map_for_DEG$tmp.gene)]
saveRDS(object = genexprdata[, unique(CpG_gene_map_for_DEG$tmp.gene)],
        file = file.path(data_tcga, "genexprdata.rds"))
saveRDS(object = mean_expr,
        file = file.path(data_tcga, "mean_expr.rds"))
saveRDS(object = cov_expr,
        file = file.path(data_tcga, "cov_expr.rds"))


# rho_methyl_expr: the Pearson correlation coefficient between the gene level
# summary of methylation data (logit transformed) and gene expression values.
# This correlation is used to generate gene expression data.
#
# Intersection between gene and methylation individual IDs.
gene_methyl_ids_prefix <- intersect(substr(rownames(genexprdata), 1, 12), 
                                    substr(colnames(methyl_gene_level), 1, 12))
ids_in_gene <- grep(pattern = paste0(gene_methyl_ids_prefix, 
                                     collapse = "|"),
                    x = rownames(genexprdata),
                    value = TRUE)
ids_in_gene_short <- substr(ids_in_gene, 1, 12)
names(ids_in_gene_short) <- ids_in_gene
ids_in_gene_short <- sort(ids_in_gene_short[!duplicated(ids_in_gene_short)])
genexprdata_sorted <- genexprdata[names(ids_in_gene_short), ]
ids_in_methyl <- grep(pattern = paste0(gene_methyl_ids_prefix, 
                                       collapse = "|"),
                      x = rownames(high_methyl_transf),
                      value = TRUE)
ids_in_methyl_short <- substr(ids_in_methyl, 1, 12)
names(ids_in_methyl_short) <- ids_in_methyl
ids_in_methyl_short <- sort(ids_in_methyl_short[!duplicated(ids_in_methyl_short)])
# Log ratio transformation already done
methyl_gene_level_sorted <- t(methyl_gene_level[ , names(ids_in_methyl_short)])

# Estimate pearson correlation
rho_methyl_expr <- diag(cor(methyl_gene_level_sorted,
                            genexprdata_sorted,
                            method = "pearson"))
print(summary(abs(rho_methyl_expr)))
saveRDS(object = rho_methyl_expr,
        file = file.path(data_tcga, "rho_methyl_expr.rds"))

# rho_expr_protein: the Pearson correlation coefficient between the protein and 
# mapped gene expression. This correlation is used to generate protein 
# expression data.
# Intersection between gene and methylation individual IDs.
gene_pro_ids_prefix <- intersect(substr(rownames(genexprdata), 1, 12), 
                                 substr(colnames(proexprdata_mapped), 1, 12))
ids_in_gene2 <- grep(pattern = paste0(gene_pro_ids_prefix, 
                                      collapse = "|"),
                     x = rownames(genexprdata),
                     value = TRUE)
ids_in_gene_short2 <- substr(ids_in_gene2, 1, 12)
names(ids_in_gene_short2) <- ids_in_gene2
ids_in_gene_short2 <- sort(ids_in_gene_short2[!duplicated(ids_in_gene_short2)])
genexprdata_sorted2 <- genexprdata[names(ids_in_gene_short2), 
                                   rownames(proexprdata_mapped)]

ids_in_pro <- grep(pattern = paste0(gene_pro_ids_prefix, 
                                    collapse = "|"),
                   x = colnames(proexprdata_mapped),
                   value = TRUE)
ids_in_pro_short <- substr(ids_in_pro, 1, 12)
names(ids_in_pro_short) <- ids_in_pro
ids_in_pro_short <- sort(ids_in_pro_short[!duplicated(ids_in_pro_short)])
proexprdata_mapped <- proexprdata_mapped[ , names(ids_in_pro_short)]
# Estimate pearson correlation
rho_expr_protein <- diag(cor(t(proexprdata_mapped),
                         genexprdata_sorted2,
                         method = "pearson"))
print(summary(abs(rho_expr_protein)))
saveRDS(object = rho_expr_protein,
        file = file.path(data_tcga, "rho_expr_protein.rds"))
