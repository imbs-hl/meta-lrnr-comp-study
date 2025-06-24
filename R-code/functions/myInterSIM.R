#' myInterSIM is an extended version of `InterSIM` to simulate
#' two-class-problems. We do not provide parameter description here as 
#' parameters precisely the same as in `InterSIM,` to which we refer for 
#' description.
#'
#' @param n.sample 
#' @param cluster.sample.prop 
#' @param delta.methyl 
#' @param delta.expr 
#' @param delta.protein 
#' @param p.DMP 
#' @param p.DEG 
#' @param p.DEP 
#' @param sigma.methyl 
#' @param sigma.expr 
#' @param sigma.protein 
#' @param cor.methyl.expr 
#' @param cor.expr.protein 
#' @param do.plot 
#' @param sample.cluster 
#' @param feature.cluster 
#'
#' @return
#' @export
#'
#' @examples
myInterSIM <- function(n.sample=500,cluster.sample.prop=c(0.30,0.30,0.40),
                       delta.methyl=2.0,delta.expr=2.0,delta.protein=2.0,
                       p.DMP=0.2,p.DEG=NULL,p.DEP=NULL,
                       sigma.methyl=NULL,sigma.expr=NULL,sigma.protein=NULL,
                       cor.methyl.expr=NULL,cor.expr.protein=NULL,
                       do.plot=FALSE, sample.cluster=TRUE, feature.cluster=TRUE)
{
  #---------------------------------------------------------------------------------------------------------------
  # n.sample = Number of samples to simulate
  # cluster.sample.prop = Proportion of samples in the clusters. The number of proportions entered is
  #                       used to determine the number of clusters in the simulated data. e.g. if (0.3,0.4,0.3) is
  #						entered then the number of clusters will be 3.
  # delta.methyl = Cluster mean shift for methylation data
  # delta.expr = Cluster mean shift for expression data
  # delta.protein = Cluster mean shift for protein data
  # p.DMP = proportion of DE CpGs (DE = Differentially Expressed)
  # p.DEG = proportion of DE mRNA, if NULL (default) mRNAs mapped by DE CpGs will be selected
  # p.DEP = proportion of DE protein, if NULL (default) proteins mapped by DE mRNAs will be selected
  # do.plot = TRUE to generate heatmap, default is FALSE
  # sample.cluster = TRUE, if clustering should be done on samples
  # feature.cluster = TRUE, if clustering should be done on genomic features
  # sigma.methyl = Covariance structure methylation data, if NULL precomputed values will be used
  # sigma.expr = Covariance structure mRNA data, if NULL precomputed values will be used
  # sigma.protein = Covariance structure Protein data, if NULL precomputed values will be used
  # --sigma.methyl,sigma.expr and sigma.protein="indep" gives covariance structure with diagonal elements only (Independent features)
  # cor.methyl.expr = Correlation between methylation and mRNA, if NULL precomputed values will be used
  # cor.expr.protein = Correlation between mRNA and protein, if NULL precomputed values will be used
  # -------------------------------------------------------------------------------------------------------------
  # Notes:
  # 1. Precomputed default values: The following values have been precalculated in the InterSIM package using Methylation, Gene expression
  #        and Protein expression data from the TCGA Ovarian Cancer study. These values are used in the simulation
  #        function by default.
  # 2. Flexibility :
  #        (i) If user wishes to apply his/her own data from other cancer types, he/she can precompute such data and name
  #        them as mentioned below (to replace such existing data) before using InterSIM algorithm.
  #        (ii) Moreover, if user wishes to apply his/her own custom correlations between the data types and correlation
  #        structure within each data type (not derived from any cancer type), he/she can precumpute such data and name
  #        them as mentioned below (to replace such existing data) before using InterSIM algorithm
  # ---------------------------------------------------------------------------------------------------------------
  # Default values in the function:
  # rho.methyl.expr = Correlation between gene level summary of methylation data (logit transformed) and gene expression
  # rho.expr.protein = Correlation between protein and corrresponding mapped protein expression
  # mean.M = Mean of the methylation data (logit transformed) by probe
  # mean.expr = Mean of the expresion data
  # mean.protein = mean of the protein data
  # cov.M = Covariance structure of methylation data (logit transformed)
  # cov.expr = Covariance structure of Gene expression data
  # cov.protein = Covariance structure of Protein data
  # methyl.gene.level.mean = mean of the methylation data summarized at gene level
  # mean.expr.with.mapped.protein = mean of the gene expression that maps to each protein
  # CpG.gene.map.for.DEG = CpG - gene mapping information
  # protein.gene.map.for.DEP = Protein - gene mapping information
  #---------------------------------------------------------------------------------------------------------------
  
  if (sum(cluster.sample.prop)!=1) stop("The proportions must sum up to 1")
  if (!length(cluster.sample.prop)>1) stop("Number of proportions must be larger than 1")
  if (p.DMP<0 | p.DMP>1) stop("p.DMP must be between 0 to 1")
  if (!is.null(p.DEG) && (p.DEG<0 | p.DEG>1)) stop("p.DEG must be between 0 and 1")
  if (!is.null(p.DEP) && (p.DEP<0 | p.DEP>1)) stop("p.DEP must be between 0 and 1")
  
  n.cluster <- length(cluster.sample.prop) 			# Number of clusters
  n.sample.in.cluster <- c(round(cluster.sample.prop[-n.cluster]*n.sample),
                           n.sample - sum(round(cluster.sample.prop[-n.cluster]*n.sample)))	# Number of samples in clusters
  cluster.id <- do.call(c,lapply(1:n.cluster, function(x) rep(x,n.sample.in.cluster[x])))
  
  #-----------------
  # Methylation
  #-----------------
  n.CpG <- ncol(cov.M) 								# Number of CpG probes  in the data
  # Covariance structure
  if (!is.null(sigma.methyl)){
    if (!is.matrix(sigma.methyl)){
      if (sigma.methyl=="indep") cov.str <- diag(diag(cov.M))  # Independent features
    } else cov.str <- sigma.methyl                             # User defined covariance structure
  } else cov.str <- cov.M   							    	 # Dependent features based on the original data
  # Differenatially methylated CpGs (DMP)
  DMP <- sapply(1:n.cluster,function(x) rbinom(n.CpG, 1, prob = p.DMP))
  rownames(DMP) <- names(mean.M)
  if (delta.methyl == 0) {
    effect <- mean.M 
    # sim.methyl <- mvrnorm(n=n.sample, mu=effect, Sigma=cov.str)
    sim.methyl <- rmvn(n=n.sample, mu=effect, V=cov.str)
  } else {
    d <- lapply(1:n.cluster,function(i) {
      effect <- mean.M + DMP[,i]*delta.methyl
      # mvrnorm(n=n.sample.in.cluster[i], mu=effect, Sigma=cov.str)
      rmvn(n=n.sample.in.cluster[i], mu=effect, V=cov.str)
      })
    sim.methyl <- do.call(rbind,d)
    sim.methyl <- InterSIM::rev.logit(sim.methyl) 						 # Transform back to beta values between (0,1)
  }
  
  #-------------------
  # Gene expression
  #-------------------
  n.gene <- ncol(cov.expr) 									 # Number of genes in the data
  # Covariance structure
  if (!is.null(sigma.expr)){
    if (!(is.matrix(sigma.expr))) {
      if (sigma.expr=="indep") cov.str <- diag(diag(cov.expr)) # Independent features
    } else cov.str <- sigma.expr                               # User defined covariance structure
  } else cov.str <- cov.expr   							   	 # Dependent features based on the original data
  # Correlation between methylation and gene expression
  if (!is.null(cor.methyl.expr)){
    rho.m.e <- cor.methyl.expr 								 # User defined correlation, single value or vector
  } else rho.m.e <- rho.methyl.expr                            # Real corrrelation between methyl and mRNA
  # Differenatially expressed genes (DEG)
  if (!is.null(p.DEG)){
    DEG <- sapply(1:n.cluster,function(x) rbinom(n.gene, 1, prob = p.DEG))
    rownames(DEG) <- names(mean.expr)
  } else { DEG <- sapply(1:n.cluster,function(x){
    cg.name <- rownames(subset(DMP,DMP[,x]==1))
    gene.name <- as.character(CpG.gene.map.for.DEG[cg.name,]$tmp.gene)
    as.numeric(names(mean.expr) %in% gene.name)})
  rownames(DEG) <- names(mean.expr)}
  if(delta.expr==0){
    rho.m.e <- 0
    effect <- mean.expr
    # sim.expr <- mvrnorm(n=n.sample, mu=effect, Sigma=cov.str)
    sim.expr <- rmvn(n=n.sample, mu=effect, V=cov.str)
  } else {
    d <- lapply(1:n.cluster,function(i) {
      effect <- (rho.m.e*methyl.gene.level.mean+sqrt(1-rho.m.e^2)*mean.expr) + DEG[,i]*delta.expr
      # mvrnorm(n=n.sample.in.cluster[i], mu=effect, Sigma=cov.str)
      rmvn(n=n.sample.in.cluster[i], mu=effect, V=cov.str)
      })
    sim.expr <- do.call(rbind,d)
  }
  
  #---------------------
  # Protein Expression
  #---------------------
  n.protein <- ncol(cov.protein) 							       # Number of genes in the data
  # Covariance structure
  if (!is.null(sigma.protein)){
    if (!(is.matrix(sigma.protein))) {
      if ((sigma.protein=="indep")) cov.str <- diag(diag(cov.protein))# Independent features 
    } else cov.str <- sigma.protein                                 # User defined covariance structure
  } else cov.str <- cov.protein   							      # Dependent features based on the original data
  # Correlation between gene expression and protein expression
  if (!is.null(cor.expr.protein)){
    rho.e.p <- cor.expr.protein 							   # User defined correlation, single value or vector
  } else rho.e.p <- rho.expr.protein                             # Real correlation between mRNA and protein
  # Differenatially expressed proteins (DEP)
  if (!is.null(p.DEP)){
    DEP <- sapply(1:n.cluster,function(x) rbinom(n.protein, 1, prob = p.DEP))
    rownames(DEP) <- names(mean.protein)
  } else { DEP <- sapply(1:n.cluster,function(x){
    gene.name <- rownames(subset(DEG,DEG[,x]==1))
    protein.name <- rownames(protein.gene.map.for.DEP[protein.gene.map.for.DEP$gene %in% gene.name,])
    as.numeric(names(mean.protein) %in% protein.name)})
  rownames(DEP) <- names(mean.protein)}
  if(delta.protein==0) {
    rho.e.p <- 0
    effect <- mean.protein
    # sim.protein <- mvrnorm(n=n.sample, mu=effect, Sigma=cov.str)
    sim.protein <- rmvn(n=n.sample, mu=effect, V=cov.str)
  } else {
    d <- lapply(1:n.cluster,function(i) {
      effect <- (rho.e.p*mean.expr.with.mapped.protein+sqrt(1-rho.e.p^2)*mean.protein) + DEP[,i]*delta.protein
      print(head(effect))
      # mvrnorm(n=n.sample.in.cluster[i], mu=effect, Sigma=cov.str)
      rmvn(n=n.sample.in.cluster[i], mu=effect, V=cov.str)
      })
    sim.protein <- do.call(rbind,d)
  }
  
  # Randomly order the samples in the data
  indices <- sample(1:n.sample)
  cluster.id <- cluster.id[indices]
  sim.methyl <- sim.methyl[indices,]
  sim.expr <- sim.expr[indices,]
  sim.protein <- sim.protein[indices,]
  rownames(sim.methyl) <- paste("subject",1:nrow(sim.methyl),sep="")
  rownames(sim.expr) <- paste("subject",1:nrow(sim.expr),sep="")
  rownames(sim.protein) <- paste("subject",1:nrow(sim.protein),sep="")
  d.cluster <- data.frame(rownames(sim.methyl),cluster.id)
  colnames(d.cluster)[1] <- "subjects"
  # Heatmaps
  if(do.plot){
    hmcol <- colorRampPalette(c("blue","deepskyblue","white","orangered","red3"))(100)
    if (dev.interactive()) dev.off()
    if(sample.cluster && feature.cluster) {
      dev.new(width=15, height=5)
      par(mfrow=c(1,3))
      aheatmap(t(sim.methyl),color=hmcol,Rowv=FALSE, Colv=FALSE, labRow=NA, labCol=NA,annLegend=T,main="Methylation",fontsize=10,breaks=0.5)
      aheatmap(t(sim.expr),color=hmcol,Rowv=FALSE, Colv=FALSE, labRow=NA, labCol=NA,annLegend=T,main="Gene expression",fontsize=10,breaks=0.5)
      aheatmap(t(sim.protein),color=hmcol,Rowv=FALSE, Colv=FALSE, labRow=NA, labCol=NA,annLegend=T,main="Protein expression",fontsize=10,breaks=0.5)}
    else if(sample.cluster) {
      dev.new(width=15, height=5)
      par(mfrow=c(1,3))
      aheatmap(t(sim.methyl),color=hmcol,Rowv=NA, Colv=FALSE, labRow=NA, labCol=NA,annLegend=T,main="Methylation",fontsize=8,breaks=0.5)
      aheatmap(t(sim.expr),color=hmcol,Rowv=NA, Colv=FALSE, labRow=NA, labCol=NA,annLegend=T,main="Gene expression",fontsize=8,breaks=0.5)
      aheatmap(t(sim.protein),color=hmcol,Rowv=NA, Colv=FALSE, labRow=NA, labCol=NA,annLegend=T,main="Protein expression",fontsize=8,breaks=0.5)}
    else if(feature.cluster){
      dev.new(width=15, height=5)
      par(mfrow=c(1,3))
      aheatmap(t(sim.methyl),color=hmcol,Rowv=FALSE, Colv=NA, labRow=NA, labCol=NA,annLegend=T,main="Methylation",fontsize=8,breaks=0.5)
      aheatmap(t(sim.expr),color=hmcol,Rowv=FALSE, Colv=NA, labRow=NA, labCol=NA,annLegend=T,main="Gene expression",fontsize=8,breaks=0.5)
      aheatmap(t(sim.protein),color=hmcol,Rowv=FALSE, Colv=NA, labRow=NA, labCol=NA,annLegend=T,main="Protein expression",fontsize=8,breaks=0.5)}
    else {
      dev.new(width=15, height=5)
      par(mfrow=c(1,3))
      aheatmap(t(sim.methyl),color=hmcol,Rowv=NA, Colv=NA, labRow=NA, labCol=NA,annLegend=T,main="Methylation",fontsize=8,breaks=0.5)
      aheatmap(t(sim.expr),color=hmcol,Rowv=NA, Colv=NA, labRow=NA, labCol=NA,annLegend=T,main="Gene expression",fontsize=8,breaks=0.5)
      aheatmap(t(sim.protein),color=hmcol,Rowv=NA, Colv=NA, labRow=NA, labCol=NA,annLegend=T,main="Protein expression",fontsize=8,breaks=0.5)}
  }
  return(list(dat.methyl = sim.methyl, 
              dat.expr = sim.expr, 
              dat.protein = sim.protein, 
              clustering.assignment = d.cluster))
}

#' simOmicsData uses `myInterSIM` simulate a two-class-problem with possible
#' modality-specific missing values in training and testing data. 
#'
#' @param training_prop proportion of training data.
#' @param prop_missing_train Proportion of modality-specific missingness in 
#' training data.
#' @param prop_missing_test Proportion of modality-specific missingness in 
#' testing data. 
#' @param ... Further parameters to be passed to myInterSIM
simOmicsData <- function (training_prop = 0.8,
                          prop_missing_train = 0,
                          prop_missing_test = 0,
                          ...) {
  train_sim_data <- myInterSIM(...)
  # Convert classes into binary.
  disease <- factor(
    as.integer(
      as.integer(train_sim_data$clustering.assignment$cluster.id)  == 2
    )
  )
  # Target data.frame
  target_df <- train_sim_data$clustering.assignment
  target_df$cluster.id <- as.integer(target_df$cluster.id == 2)
  names(target_df) <- c("IDS", "disease")
  target_df$IDS <- gsub(pattern = "subject",
                        replacement = "participant",
                        x = target_df$IDS)
  index_split <- caret::createDataPartition(y = disease, p = training_prop)
  index_split$Fold1 <- index_split$Resample1
  index_split$Fold2 <- setdiff(1L:length(disease), index_split$Fold1)
  train_disease <- disease[index_split$Fold1]
  
  target_df_train <- target_df[index_split$Fold1, ]
  target_df_test <- target_df[index_split$Fold2, ]
  
  # Training sample
  n_not_missing_train <- length(index_split$Fold1) - length(index_split$Fold1) * prop_missing_train
  not_missing1 <- sample(x = 1L:length(index_split$Fold1),
                         size = floor(n_not_missing_train),
                         replace = FALSE)
  missing1 <- setdiff(1L:length(index_split$Fold1), not_missing1)
  subject_ids <- rownames(train_sim_data$dat.methyl[index_split$Fold1, ])
  methylation_train_data <- as.data.frame(train_sim_data$dat.methyl[index_split$Fold1[not_missing1], ])
  methylation_train_data$IDS <- subject_ids[not_missing1]
  methylation_train_data$IDS <- gsub(pattern = "subject",
                                  replacement = "participant",
                                  x = methylation_train_data$IDS)
  # geneexpr_train_data$disease <- train_disease[not_missing1]
  methylation_train_data$disease <- NULL
  
  # Sample not missing
  not_missing2 <- sample(x = 1L:length(index_split$Fold1),
                         size = floor(n_not_missing_train),
                         replace = FALSE)
  missing2 <- setdiff(1L:length(index_split$Fold1), not_missing2)
  proteinexpr_train_data <- as.data.frame(train_sim_data$dat.protein[index_split$Fold1[not_missing2], ])
  proteinexpr_train_data$IDS <- subject_ids[not_missing2]
  proteinexpr_train_data$IDS <- gsub(pattern = "subject",
                                     replacement = "participant",
                                     x = proteinexpr_train_data$IDS)
  proteinexpr_train_data$disease <- train_disease[not_missing2]
  proteinexpr_train_data$disease <- NULL
  
  not_missing3 <- sample(x = 1L:length(index_split$Fold1),
                         size = floor(n_not_missing_train),
                         replace = FALSE)
  missing12 <- intersect(missing1, missing2)
  not_missing3 <- c(not_missing3, missing12)
  methylation_train_data <- as.data.frame(train_sim_data$dat.expr[index_split$Fold1[not_missing3], ])
  # We force at least the gene expression modality to be none-missing, if 
  # methylation and protein expr. are missing.
  geneexpr_train_data$IDS <- subject_ids[not_missing3]
  geneexpr_train_data$IDS <- gsub(pattern = "subject",
                                     replacement = "participant",
                                     x = geneexpr_train_data$IDS)
  geneexpr_train_data$disease <- train_disease[not_missing3]
  geneexpr_train_data$disease <- NULL
  
  train_entities <- list("geneexpr" = geneexpr_train_data,
                         "proteinexpr" = proteinexpr_train_data,
                         "methylation" = methylation_train_data,
                         "target" = target_df_train)
  
  # Test disease
  test_disease <- disease[index_split$Fold2]
  n_not_missing_test <- length(index_split$Fold2) - length(index_split$Fold2) * prop_missing_test
  test_not_missing1 <- sample(x = 1L:length(index_split$Fold2),
                              size = n_not_missing_test,
                              replace = FALSE)
  test_missing1 <- setdiff(1L:length(index_split$Fold2), test_not_missing1)
  subject_ids <- rownames(train_sim_data$dat.methyl[index_split$Fold2, ])
  methylation_test_data <- as.data.frame(train_sim_data$dat.methyl[index_split$Fold2[test_not_missing1], ])
  methylation_test_data$IDS <- subject_ids[test_not_missing1]
  methylation_test_data$IDS <- gsub(pattern = "subject",
                                 replacement = "participant",
                                 x = methylation_test_data$IDS)
  # geneexpr_test_data$disease <- test_disease[test_not_missing1]
  geneexpr_test_data$disease <- NULL
  
  test_not_missing2 <- sample(x = 1L:length(index_split$Fold2),
                              size = n_not_missing_test,
                              replace = FALSE)
  test_missing2 <- setdiff(1L:length(index_split$Fold2), test_not_missing2)
  proteinexpr_test_data <- as.data.frame(train_sim_data$dat.protein[index_split$Fold2[test_not_missing2], ])
  proteinexpr_test_data$IDS <- subject_ids[test_not_missing2]
  proteinexpr_test_data$IDS <- gsub(pattern = "subject",
                                    replacement = "participant",
                                    x = proteinexpr_test_data$IDS)
  # proteinexpr_test_data$disease <- test_disease[test_not_missing2]
  proteinexpr_test_data$disease <- NULL
  
  test_not_missing3 <- sample(x = 1L:length(index_split$Fold2),
                              size = n_not_missing_test,
                              replace = FALSE)
  test_missing12 <- intersect(test_missing1, test_missing2)
  test_not_missing3 <- c(test_not_missing3, test_missing12)
  geneexpr_test_data <- as.data.frame(train_sim_data$dat.expr[index_split$Fold2[test_not_missing3], ])
  geneexpr_test_data$IDS <- subject_ids[test_not_missing3]
  geneexpr_test_data$IDS <- gsub(pattern = "subject",
                                    replacement = "participant",
                                    x = geneexpr_test_data$IDS)
  # geneexpr_test_data$disease <- test_disease[test_not_missing3]
  geneexpr_test_data$disease <- NULL
  
  test_entities <- list("geneexpr" = geneexpr_test_data,
                        "proteinexpr" = proteinexpr_test_data,
                        "methylation" = methylation_test_data,
                        "target" = target_df_test)
  train_entities$target$disease <- factor(train_entities$target$disease)
  test_entities$target$disease <- factor(test_entities$target$disease)
  entities = list(training = train_entities, testing = test_entities)
  multi_omics <- entities
  return(multi_omics)
}