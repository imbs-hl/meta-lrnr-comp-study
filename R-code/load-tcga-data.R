# This code requires substantial memory resources, ideally at least 10 GB of RAM.

# Extract codes of diseases available with subtypes via curratedTCGA.
data('diseaseCodes', package = "TCGAutils")
dis_codes <- diseaseCodes[(diseaseCodes$Available == "Yes") & 
                            (diseaseCodes$SubtypeData == "Yes"), 
]$Study.Abbreviation
# Remove not downlaodable data.
dis_codes <- dis_codes[!(dis_codes %in% c("GBM", "EH2202"))]
# Resume number of assays, samples and complete samples per disease.
assay_sample_complete <- sapply(X = dis_codes,
                                FUN = function (code) {
                                  # Load data.
                                  my_data <- curatedTCGAData(
                                    diseaseCode = code,
                                    assays = c("RNASeqGene", 
                                               "RPPAArray", 
                                               "Methylation*" 
                                               ),
                                    version = "1.1.38",
                                    dry.run = FALSE
                                  )
                                  # Retain primary tumor only.
                                  my_data <- TCGAprimaryTumors(
                                    multiassayexperiment = my_data
                                  )
                                  # At least three assays required for the experiment.
                                  if (length(my_data) < 3) {
                                    return(NULL)
                                  } else {
                                    # Merge possible replicates
                                    my_data <- mergeReplicates(
                                      intersectColumns(my_data)
                                    )
                                    # Keep only sample with existing colData 
                                    # information.
                                    my_data <- intersectColumns(
                                      x = my_data
                                    )
                                    # Calculate number of overlapping
                                   my_sum_res <- c(
                                     c_case = sum(complete.cases(my_data)),
                                     i_case = nrow(colData(my_data))
                                     )
                                    return(my_sum_res)
                                  }
                                })

# The HNSC data experiment is selected for having passed all filters and the
# larger overlapping samples with available colData.
hnsc <- curatedTCGAData(
  diseaseCode = "HNSC",
  assays = c("RNASeqGene",
             "RPPAArray",
             "Methylation*"),
  version = "1.1.38",
  dry.run = FALSE
)
hnsc_assays <- assays(x = hnsc)
prop.table(table(colData(hnsc)$gender))

#' This function removes variables with 0 scale values.
#'
#' @param x A data matrix.
#'
#' @return A data matrix without variables with 0 scale values.
rm_zero_scale <- function(x) {
  my_wm <- wt.moments(x)
  my_sc <- sqrt(my_wm$var)
  # my_zeros <- (my_sc == 0.0)
  return(x[ , !my_zeros])
}

# Preprocessing
genexprdata <- hnsc_assays$`HNSC_RNASeqGene-20160128`
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
genexprdata <- rm_zero_scale(x = t(genexprdata))

# Protein expression data.
proexprdata <- hnsc_assays$`HNSC_RPPAArray-20160128`
proexprdata <- rm_zero_scale(x = t(proexprdata))

methyldata <- as.matrix(assay(hnsc_assays$`HNSC_Methylation-20160128`))
methyldata <- methyldata[complete.cases(methyldata), ]

# =========================================================================== */
# Preprocessing of methylation data                                           */
# =========================================================================== */
#
# We retain CpG site located on known genes.
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
# cpg_in_genes <- subset(cpg_in_genes, annotation %in% c("Exon",
#                                                        "Intron",
#                                                        "TSS",
#                                                        "5' UTR",
#                                                        "3' UTR"))
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

# Alternative 1: Intersection with gene expression.
inter_methyl_gene <- intersect(colnames(genexprdata), cpg_gene_symbol)
print(length(inter_methyl_gene))
# [1] 13198
# Alternative 2: Methylation with higher variability.
methylmoment <- wt.moments(t(methyldata))
threshold <- quantile(methylmoment$var, 0.95)
high_methyl_var <- methyldata[(methylmoment$var >= threshold) & 
                              rownames(methyldata) %in% cpg_in_genes$cpg_gr, ]
print(dim(high_methyl_var))
# [1] 18688   580
# CpG_gene_map_for_DEG: Prepare data having CpG probe names and mapped gene 
# names  
cpg_in_genes_expr <- cpg_in_genes[cpg_in_genes$SYMBOL %in% colnames(genexprdata), ]
cpg_in_genes_expr <- cpg_in_genes_expr[cpg_in_genes_expr$cpg_gr %in% 
                                         rownames(high_methyl_var) , ]
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
# Save methylation related data
saveRDS(object = high_methyl_transf,
        file = file.path(data_tcga, "methyldata.rds"))
saveRDS(object = mean_M,
        file = file.path(data_tcga, "mean_M.rds"))
saveRDS(object = cov_M,
        file = file.path(data_tcga, "cov_M.rds"))
saveRDS(object = CpG_gene_map_for_DEG,
        file = file.path(data_tcga, "CpG_gene_map_for_DEG.rds"))


# =========================================================================== */
# Preprocessing of protein data                                               */
# =========================================================================== */
#
pro_names <- colnames(proexprdata)
clean_protein_names <- function(protein_vector) {
  cleaned_names <- gsub("_p[A-Z0-9]+", "", protein_vector)  # Remove _pS473, _pY1068, etc.
  return(cleaned_names)
}
# Apply function to RPPA row names
pro_gene_symbols <- clean_protein_names(pro_names)
# We now map protein to gene expression
pro_names <- colnames(proexprdata)
# Function to clean protein names (remove phosphorylation sites)
clean_protein_names <- function(protein_vector) {
  cleaned_names <- gsub("_p[A-Z0-9]+", "", protein_vector)  # Remove _pS473, _pY1068, etc.
  return(cleaned_names)
}
pro_gene_symbols <- clean_protein_names(pro_names)

# Fix some remaining protein names
pro_gene_symbols[pro_gene_symbols == "Chromogranin-A-N-term"] <- "Chromogranin-A"
pro_gene_symbols[pro_gene_symbols == "GSK3-alpha-beta"] <- "GSK3A"
pro_gene_symbols[pro_gene_symbols == "GSK3-alpha-beta_S9"] <- "GSK3A"
pro_gene_symbols[pro_gene_symbols == "LCN2a"] <- "LCN2"
pro_gene_symbols[pro_gene_symbols == "MAPK_Y204"] <- "MAPK1"
pro_gene_symbols[pro_gene_symbols == "NF-κB p65"] <- "RELA"
pro_gene_symbols[pro_gene_symbols == "NF-κB p65"] <- "RELA"
pro_gene_symbols[pro_gene_symbols == "PARP-Ab-3"] <- "PARP1"
pro_gene_symbols[pro_gene_symbols == "PI3K-p110-alpha"] <- "PIK3CA"
pro_gene_symbols[pro_gene_symbols == "PI3K-p85"] <- "PIK3R1"
pro_gene_symbols[pro_gene_symbols == "PKC-delta"] <- "PRKCD"
pro_gene_symbols[pro_gene_symbols == "PKC-delta"] <- "PRKCD"
pro_gene_symbols[pro_gene_symbols == "Rb_S811"] <- "RB1"
pro_gene_symbols[pro_gene_symbols == "S6_S236"] <- "RPS6"
pro_gene_symbols[pro_gene_symbols == "Rb_S811"] <- "RPS6"
pro_gene_symbols[pro_gene_symbols == "STAT5-alpha"] <- "STAT5A"
pro_gene_symbols[pro_gene_symbols == "Rb_S811"] <- "RPS6"
pro_gene_symbols[pro_gene_symbols == "Thymidylate Synthase"] <- "TYMS"
pro_gene_symbols[pro_gene_symbols == "p16_INK4a"] <- "CDKN2A"
pro_gene_symbols[pro_gene_symbols == "p38_Y182"] <- "MAPK14"
pro_gene_symbols[pro_gene_symbols == "p70S6K"] <- "RPS6KB1"
pro_gene_symbols[pro_gene_symbols == "p90RSK_S363"] <- "RPS6KA3"

pro_names_df <- data.frame(pro_name = pro_names,
                           pro_name_clean = pro_gene_symbols)

data.table::fwrite(x = data.frame(x = pro_gene_symbols),
                   file = file.path(data_tcga, "pro_names_clean.txt"),
                   sep = "\t")
mapped_pro_gen <- data.table::fread("/imbs/projects/p23048/meta-lrnr-comp-study/data/tcga/string_mapping.tsv")
mapped_pro_gen <- mapped_pro_gen[ , c("queryItem", "preferredName")]
names(mapped_pro_gen) <- c("pro_name_clean", "gene")
mapped_pro_gen <- mapped_pro_gen[mapped_pro_gen$gene %in% colnames(genexprdata), ]
# protein_gene_map_for_DEP: Prepare data having protein names and mapped gene names 
protein_gene_map_for_DEP <- merge(x = mapped_pro_gen,
                                  y = pro_names_df,
                                  by = "pro_name_clean")
protein_gene_map_for_DEP <- protein_gene_map_for_DEP[!duplicated(protein_gene_map_for_DEP), ]
protein_gene_map_for_DEP <- protein_gene_map_for_DEP[ , c("pro_name", "gene")]
colnames(protein_gene_map_for_DEP) <- c("protein", "gene")
rownames(protein_gene_map_for_DEP) <- protein_gene_map_for_DEP$protein
# Check again that all protreins map a gene in the gene expression data
print(all(protein_gene_map_for_DEP$gene %in% colnames(genexprdata)))
# Should return TRUE
proexprdata_mapped <- proexprdata[ , protein_gene_map_for_DEP$protein]
mean_protein <-  colMeans(x = as.matrix(proexprdata_mapped))
cov_protein <- cov.shrink(x = proexprdata_mapped)
# Save protein related data
saveRDS(object = proexprdata_mapped,
        file = file.path(data_tcga, "protein.rds"))
saveRDS(object = mean_protein,
        file = file.path(data_tcga, "mean_protein.rds"))
saveRDS(object = cov_protein,
        file = file.path(data_tcga, "cov_protein.rds"))
saveRDS(object = protein_gene_map_for_DEP,
        file = file.path(data_tcga, "protein_gene_map_for_DEP.rds"))

# =========================================================================== */
# Preprocessing of gene data.                                                 */
# =========================================================================== */
#
# mean_expr: calculate the mean of the features in gene expression data
mean_expr <-  colMeans(x = genexprdata)
# cov_expr:  covariance matrix of the gene expression data
cov_expr <- cov.shrink(x = genexprdata)
# Save gene expression related data
saveRDS(object = genexprdata,
        file = file.path(data_tcga, "genexprdata.rds"))
saveRDS(object = mean_expr,
        file = file.path(data_tcga, "mean_expr.rds"))
saveRDS(object = cov_expr,
        file = file.path(data_tcga, "cov_expr.rds"))



pro_gene_symbols <- toupper(gsub("[._-]", "", pro_gene_symbols))
# TODO: Use this information to prepare protein mapped gene data
sum(toupper(gsub("[._-]", "", colnames(genexprdata))) %in% pro_gene_symbols)

# mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
# 
# gene_symbols <- mapIds(org.Hs.eg.db,
#                        keys = pro_names,
#                        column = "SYMBOL",
#                        keytype = "UNIPROT",
#                        multiVals = "first")

mart <- useMart(biomart = "ENSEMBL_MART_ENSEMBL",
                dataset = "hsapiens_gene_ensembl",
                host = 'www.ensembl.org')
pdata <- getBM(mart = mart, 
               # attributes = c("external_gene_name",
               #                "protein_id"), 
               attributes = c("hgnc_symbol",
                              "uniprot_gn_symbol",
                              "hgnc_trans_name"),
               filters = c("biotype"), 
               values = list("protein_coding"), 
               useCache = FALSE)

genes <- biomaRt::getBM(
  attributes = c("external_gene_name",
                 "chromosome_name", 
                 "transcript_biotype"),
  filters = c("transcript_biotype",
              "chromosome_name"), 
  values = list("protein_coding", c(1:22)),
  mart = mart)

mapping <- getBM(
  attributes = c("hgnc_symbol", "uniprot_gn_symbol"),
  filters = "hgnc_symbol",
  values = "p70S6K",  # Gene symbol for p70S6K
  mart = mart
)

# Remove unimportant columns

print(dim(cpg_in_known_genes))
# [1] 7459  580
# remove zero
cpg_in_known_genes <- rm_zero_scale(x = t(cpg_in_known_genes))

# Now map gene expression with methylation data
inter_methyl_gene <- intersect(colnames(genexprdata), cpg_in_genes$SYMBOL)
genexprdata_mapped <- genexprdata[ , methyl_expr_maping_gene]
methyldata_mapped <- cpg_in_known_genes[ , inter_methyl_gene]

# Estimation of correlation matrix
genexprcor <- cor.shrink(x = genexprdata)
proexprcor <- cor.shrink(x = proexprdata)
methylcor <- cor.shrink(x = cpg_in_known_genes)

# Save empirical data
saveRDS(object = genexprdata, file = file.path(data_tcga, "genexprdata.rds"))
saveRDS(object = proexprdata, file = file.path(data_tcga, "proexprdata.rds"))
saveRDS(object = cpg_in_known_genes, file = file.path(data_tcga, "methyldata.rds"))

# Save correlation matrix
saveRDS(object = genexprcor, file = file.path(data_tcga, "genexprcor.rds"))
saveRDS(object = proexprcor, file = file.path(data_tcga, "proexprcor.rds"))
saveRDS(object = methylcor, file = file.path(data_tcga, "methylcor.rds"))

