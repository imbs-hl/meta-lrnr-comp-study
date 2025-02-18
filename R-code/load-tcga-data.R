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
  my_zeros <- (my_sc == 0.0)
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
proexprdata <- t(hnsc_assays$`HNSC_RPPAArray-20160128`)
proexprdata <- rm_zero_scale(x = proexprdata)

methyldata <- as.matrix(assay(hnsc_assays$`HNSC_Methylation-20160128`))
methyldata <- methyldata[complete.cases(methyldata), ]

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
# Filter CpG sites located **within** known genes
cpg_in_genes <- as.data.frame(annotated_peaks)
cpg_in_genes <- subset(cpg_in_genes, annotation %in% c("Exon",
                                                       "Intron",
                                                       "TSS",
                                                       "5' UTR",
                                                       "3' UTR"))
# Display relevant columns
cpg_in_genes[, c("seqnames", "start", "end", "geneId", "SYMBOL", "annotation")]
cpg_to_retrieve <- cpg_in_genes[ , c("seqnames", "start")]
colnames(cpg_to_retrieve) <- c("chr", "pos")
cpg_in_known_genes <- merge(x = methylation_anno, 
                            y = cpg_to_retrieve)[names(methylation_anno)]
# Remove unimportant columns
cpg_in_known_genes <- cpg_in_known_genes[ , 2:(ncol(cpg_in_known_genes) - 33)]

print(dim(cpg_in_known_genes))
# [1] 7459  580
# remove zero
cpg_in_known_genes <- rm_zero_scale(x = t(cpg_in_known_genes))

# Estimation of correlation matrix
genexprcor <- cor.shrink(x = genexprdata)
proexprcor <- cor.shrink(x = proexprdata)
methylcor <- cor.shrink(x = cpg_in_known_genes)

# Save empirical data
saveRDS(object = genexprdata, file = file.path(data_tcga, "genexprdata.rds"))
saveRDS(object = proexprdata, file = file.path(data_tcga, "proexprdata.rds"))
saveRDS(object = methyldata, file = file.path(data_tcga, "methyldata.rds"))

# Save correlation matrix
saveRDS(object = genexprcor, file = file.path(data_tcga, "genexprcor.rds"))
saveRDS(object = proexprcor, file = file.path(data_tcga, "proexprcor.rds"))
saveRDS(object = methylcor, file = file.path(data_tcga, "methylcor.rds"))

