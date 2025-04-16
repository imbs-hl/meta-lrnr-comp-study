source("../init-global.R", chdir = TRUE)

# ============================
# Independent
# ============================
# 01-methyl.
indep_res_methyl_best <- readRDS(file.path(res_indep_methyl,
                                           "indep_res_methyl_best.rds"))
indep_res_methyl_cobra <- readRDS(file.path(res_indep_methyl,
                                            "indep_res_methyl_cobra.rds"))
indep_res_methyl_lasso <- readRDS(file.path(res_indep_methyl,
                                            "indep_res_methyl_lasso.rds"))
indep_res_methyl_lr <- readRDS(file.path(res_indep_methyl,
                                         "indep_res_methyl_lr.rds"))
indep_res_methyl_rf <- readRDS(file.path(res_indep_methyl,
                                         "indep_res_methyl_rf.rds"))
indep_res_methyl_wa <- readRDS(file.path(res_indep_methyl,
                                         "indep_res_methyl_wa.rds"))
indep_methyl <- rbindlist(
  list(
    indep_res_methyl_best,
    indep_res_methyl_cobra,
    indep_res_methyl_lasso,
    indep_res_methyl_lr,
    indep_res_methyl_rf,
    indep_res_methyl_wa
  )
)
indep_methyl[effect == "null" , Effect := "N"]
indep_methyl[effect == "low" , Effect := "W"]
indep_methyl[effect == "moderate" , Effect := "M"]
indep_methyl[effect == "strong" , Effect := "S"]
indep_methyl[ , Effect := factor(x = Effect, levels = c("N", "W",
                                                        "M", "S"))]
indep_me_bs <- data.table::melt(data = indep_methyl[perf_measure == "BS" ,
                                                        c("meta_layer",
                                                          "perf_measure",
                                                          "effect",
                                                          "DE", 
                                                          "Meta_learner",
                                                          "Effect")],
                                    measure.vars = c("effect"),
                                    value.name = "value")
indep_me_auc <- data.table::melt(data = indep_methyl[perf_measure == "AUC" ,
                                                        c("meta_layer",
                                                          "perf_measure",
                                                          "effect",
                                                          "DE", 
                                                          "Meta_learner",
                                                          "Effect")],
                                    measure.vars = c("effect"),
                                    value.name = "value")
# 02-methyl-genexpr
indep_res_mege_best <- readRDS(file.path(res_indep_methyl_genexpr,
                                         "indep_res_mege_best.rds"))
indep_res_mege_cobra <- readRDS(file.path(res_indep_methyl_genexpr,
                                          "indep_res_mege_cobra.rds"))
indep_res_mege_lasso <- readRDS(file.path(res_indep_methyl_genexpr,
                                          "indep_res_mege_lasso.rds"))
indep_res_mege_lr <- readRDS(file.path(res_indep_methyl_genexpr,
                                       "indep_res_mege_lr.rds"))
indep_res_mege_rf <- readRDS(file.path(res_indep_methyl_genexpr,
                                       "indep_res_mege_rf.rds"))
indep_res_mege_wa <- readRDS(file.path(res_indep_methyl_genexpr,
                                       "indep_res_mege_wa.rds"))
indep_mege <- rbindlist(
  list(
    indep_res_mege_best,
    indep_res_mege_cobra,
    indep_res_mege_lasso,
    indep_res_mege_lr,
    indep_res_mege_rf,
    indep_res_mege_wa
  )
)
indep_mege[effect == "low_low" , Effect := "W.W"]
indep_mege[effect == "moderate_low" , Effect := "M.W"]
indep_mege[effect == "moderate_moderate" , Effect := "M.M"]
indep_mege[effect == "strong_low" , Effect := "S.W"]
indep_mege[effect == "strong_moderate" , Effect := "S.M"]
indep_mege[ , Effect := factor(Effect, level = c("W.W",
                                                 "M.W",
                                                 "M.M",
                                                 "S.W",
                                                 "S.M"))]
indep_mege_bs <- data.table::melt(data = indep_mege[perf_measure == "BS" ,
                                                        c("meta_layer",
                                                          "perf_measure",
                                                          "effect",
                                                          "DE", 
                                                          "Meta_learner",
                                                          "Effect")],
                                    measure.vars = c("effect"),
                                    value.name = "value")

indep_mege_auc <- data.table::melt(data = indep_mege[perf_measure == "AUC" ,
                                                         c("meta_layer",
                                                           "perf_measure",
                                                           "effect",
                                                           "DE", 
                                                           "Meta_learner",
                                                           "Effect")],
                                     measure.vars = c("effect"),
                                     value.name = "value")
# 02-methyl-genexpr-proexpr
indep_res_megepro_best <- readRDS(file.path(res_indep_methyl_genexpr_proexpr,
                                            "indep_res_megepro_best.rds"))
indep_res_megepro_cobra <- readRDS(file.path(res_indep_methyl_genexpr_proexpr,
                                             "indep_res_megepro_cobra.rds"))
indep_res_megepro_lasso <- readRDS(file.path(res_indep_methyl_genexpr_proexpr,
                                             "indep_res_megepro_lasso.rds"))
indep_res_megepro_lr <- readRDS(file.path(res_indep_methyl_genexpr_proexpr,
                                          "indep_res_megepro_lr.rds"))
indep_res_megepro_rf <- readRDS(file.path(res_indep_methyl_genexpr_proexpr,
                                          "indep_res_megepro_rf.rds"))
indep_res_megepro_wa <- readRDS(file.path(res_indep_methyl_genexpr_proexpr,
                                          "indep_res_megepro_wa.rds"))
indep_megepro <- rbindlist(
  list(
    indep_res_megepro_best,
    indep_res_megepro_cobra,
    indep_res_megepro_lasso,
    indep_res_megepro_lr,
    indep_res_megepro_rf,
    indep_res_megepro_wa
  )
)
indep_megepro[effect == "low_low_low" , Effect := "W.W.W"]
indep_megepro[effect == "moderate_low_low" , Effect := "M.W.W"]
indep_megepro[effect == "moderate_moderate_low" , Effect := "M.M.W"]
indep_megepro[effect == "moderate_moderate_moderate" , Effect := "M.M.M"]
indep_megepro[effect == "strong_moderate_low" , Effect := "S.M.W"]
indep_megepro[effect == "strong_strong_moderate" , Effect := "S.S.M"]
indep_megepro[ , Effect := factor(x = Effect, levels = c("W.W.W",
                                                         "M.W.W",
                                                         "M.M.W",
                                                         "M.M.M",
                                                         "S.M.W",
                                                         "S.S.M"))]
indep_megepro_bs <- data.table::melt(data = indep_megepro[perf_measure == "BS" ,
                                                    c("meta_layer",
                                                      "perf_measure",
                                                      "effect",
                                                      "DE", 
                                                      "Meta_learner",
                                                      "Effect")],
                                  measure.vars = c("effect"),
                                  value.name = "value")
indep_megepro_auc <- data.table::melt(data = indep_megepro[perf_measure == "AUC" ,
                                                     c("meta_layer",
                                                       "perf_measure",
                                                       "effect",
                                                       "DE", 
                                                       "Meta_learner",
                                                       "Effect")],
                                   measure.vars = c("effect"),
                                   value.name = "value")

# ============================
# Dependent
# ============================
# 02-methyl-genexpr
dep_res_mege_best <- readRDS(file.path(res_dep_methyl_genexpr,
                                         "dep_res_mege_best.rds"))
dep_res_mege_cobra <- readRDS(file.path(res_dep_methyl_genexpr,
                                          "dep_res_mege_cobra.rds"))
dep_res_mege_lasso <- readRDS(file.path(res_dep_methyl_genexpr,
                                          "dep_res_mege_lasso.rds"))
dep_res_mege_lr <- readRDS(file.path(res_dep_methyl_genexpr,
                                       "dep_res_mege_lr.rds"))
dep_res_mege_rf <- readRDS(file.path(res_dep_methyl_genexpr,
                                       "dep_res_mege_rf.rds"))
dep_res_mege_wa <- readRDS(file.path(res_dep_methyl_genexpr,
                                       "dep_res_mege_wa.rds"))
dep_mege <- rbindlist(
  list(
    dep_res_mege_best,
    dep_res_mege_cobra,
    dep_res_mege_lasso,
    dep_res_mege_lr,
    dep_res_mege_rf,
    dep_res_mege_wa
  )
)
dep_mege[effect == "low_low" , Effect := "W.W"]
dep_mege[effect == "moderate_low" , Effect := "M.W"]
dep_mege[effect == "moderate_moderate" , Effect := "M.M"]
dep_mege[effect == "strong_low" , Effect := "S.W"]
dep_mege[effect == "strong_moderate" , Effect := "S.M"]
dep_mege[ , Effect := factor(Effect, level = c("W.W",
                                                 "M.W",
                                                 "M.M",
                                                 "S.W",
                                                 "S.M"))]
dep_mege_bs <- data.table::melt(data = dep_mege[perf_measure == "BS" ,
                                                    c("meta_layer",
                                                      "perf_measure",
                                                      "effect",
                                                      "DE", 
                                                      "Meta_learner",
                                                      "Effect")],
                                  measure.vars = c("effect"),
                                  value.name = "value")

dep_mege_auc <- data.table::melt(data = dep_mege[perf_measure == "AUC" ,
                                                     c("meta_layer",
                                                       "perf_measure",
                                                       "effect",
                                                       "DE", 
                                                       "Meta_learner",
                                                       "Effect")],
                                   measure.vars = c("effect"),
                                   value.name = "value")
# 02-methyl-genexpr-proexpr
dep_res_megepro_best <- readRDS(file.path(res_dep_methyl_genexpr_proexpr,
                                            "dep_res_megepro_best.rds"))
dep_res_megepro_cobra <- readRDS(file.path(res_dep_methyl_genexpr_proexpr,
                                             "dep_res_megepro_cobra.rds"))
dep_res_megepro_lasso <- readRDS(file.path(res_dep_methyl_genexpr_proexpr,
                                             "dep_res_megepro_lasso.rds"))
dep_res_megepro_lr <- readRDS(file.path(res_dep_methyl_genexpr_proexpr,
                                          "dep_res_megepro_lr.rds"))
dep_res_megepro_rf <- readRDS(file.path(res_dep_methyl_genexpr_proexpr,
                                          "dep_res_megepro_rf.rds"))
dep_res_megepro_wa <- readRDS(file.path(res_dep_methyl_genexpr_proexpr,
                                          "dep_res_megepro_wa.rds"))
dep_megepro <- rbindlist(
  list(
    dep_res_megepro_best,
    dep_res_megepro_cobra,
    dep_res_megepro_lasso,
    dep_res_megepro_lr,
    dep_res_megepro_rf,
    dep_res_megepro_wa
  )
)
dep_megepro[effect == "low_low_low" , Effect := "W.W.W"]
dep_megepro[effect == "moderate_low_low" , Effect := "M.W.W"]
dep_megepro[effect == "moderate_moderate_low" , Effect := "M.M.W"]
dep_megepro[effect == "moderate_moderate_moderate" , Effect := "M.M.M"]
dep_megepro[effect == "strong_moderate_low" , Effect := "S.M.W"]
dep_megepro[effect == "strong_strong_moderate" , Effect := "S.S.M"]
dep_megepro[ , Effect := factor(x = Effect, levels = c("W.W.W",
                                                         "M.W.W",
                                                         "M.M.W",
                                                         "M.M.M",
                                                         "S.M.W",
                                                         "S.S.M"))]
dep_megepro_bs <- data.table::melt(data = dep_megepro[perf_measure == "BS" ,
                                                          c("meta_layer",
                                                            "perf_measure",
                                                            "effect",
                                                            "DE", 
                                                            "Meta_learner",
                                                            "Effect")],
                                     measure.vars = c("effect"),
                                     value.name = "value")
dep_megepro_auc <- data.table::melt(data = dep_megepro[perf_measure == "AUC" ,
                                                           c("meta_layer",
                                                             "perf_measure",
                                                             "effect",
                                                             "DE", 
                                                             "Meta_learner",
                                                             "Effect")],
                                      measure.vars = c("effect"),
                                      value.name = "value")

