source(file.path(code_dir, "myInterSIM.R"))

set.seed(3252)
prop <- c(0.5, 0.5)
effect <- 0.5
multi_omics <- simOmicsData(n.sample = 100,
                            cluster.sample.prop = prop,
                            delta.methyl = effect,
                            delta.expr = effect,
                            delta.protein = 0L,
                            p.DMP = 0.2,
                            p.DEG = NULL,
                            p.DEP = NULL,
                            sigma.methyl = NULL,
                            sigma.expr = genexprcor,
                            sigma.protein = proexprcor,
                            cor.methyl.expr = methylcor,
                            cor.expr.protein = NULL,
                            do.plot = FALSE,
                            sample.cluster = TRUE,
                            feature.cluster = FALSE,
                            training_prop = 0.8,
                            prop_missing_train = 0,
                            prop_missing_test = 0)

save(multi_omics, file = file.path(dirname(dirname(this.path::this.path())), "data/multi_omics.rda"))
# Compress this large dataset.
tools::resaveRdaFiles(paths = file.path(dirname(dirname(this.path::this.path())), "data/multi_omics.rda"))

