source("../init.R", chdir = TRUE)

# ============================
# Independent
# ============================
# 01-methyl.
res_indep_combalanced_me_mean_perf_best_na_keep <- readRDS(file.path(res_indep_me,
                                                                     "res_indep_combalanced_me_mean_perf_best_na_keep.rds"))
res_indep_combalanced_me_mean_perf_cobra_na_keep <- readRDS(file.path(res_indep_me,
                                                                      "res_indep_combalanced_me_mean_perf_cobra_na_keep.rds"))
res_indep_combalanced_me_mean_perf_lasso_na_keep <- readRDS(file.path(res_indep_me,
                                                                      "res_indep_combalanced_me_mean_perf_lasso_na_keep.rds"))
res_indep_combalanced_me_mean_perf_lr_na_keep <- readRDS(file.path(res_indep_me,
                                                                   "res_indep_combalanced_me_mean_perf_lr_na_keep.rds"))
res_indep_combalanced_me_mean_perf_rf_na_keep <- readRDS(file.path(res_indep_me,
                                                                   "res_indep_combalanced_me_mean_perf_rf_na_keep.rds"))
res_indep_combalanced_me_mean_perf_wa_na_keep <- readRDS(file.path(res_indep_me,
                                                                   "res_indep_combalanced_me_mean_perf_wa_na_keep.rds"))
res_indep_combalance_me <- rbindlist(
  list(
    res_indep_combalanced_me_mean_perf_best_na_keep,
    res_indep_combalanced_me_mean_perf_cobra_na_keep,
    res_indep_combalanced_me_mean_perf_lasso_na_keep,
    res_indep_combalanced_me_mean_perf_lr_na_keep,
    res_indep_combalanced_me_mean_perf_rf_na_keep,
    res_indep_combalanced_me_mean_perf_wa_na_keep
  )
)
res_indep_combalance_me[effect == "null" , Effect := "N"]
res_indep_combalance_me[effect == "low" , Effect := "W"]
res_indep_combalance_me[effect == "moderate" , Effect := "M"]
res_indep_combalance_me[effect == "strong" , Effect := "S"]
res_indep_combalance_me[ , Effect := factor(x = Effect, levels = c("N", "W",
                                                                   "M", "S"))]
res_indep_combalance_me_bs <- data.table::melt(data = res_indep_combalance_me[perf_measure == "BS",
                                                                              c("perf_measure",
                                                                                "mean_perf",
                                                                                "effect",
                                                                                "DE", 
                                                                                "Meta_learner",
                                                                                "Effect",
                                                                                "Na_action")],
                                               measure.vars = c("effect"),
                                               value.name = "value")
res_indep_combalance_me_auc <- data.table::melt(data = res_indep_combalance_me[perf_measure == "AUC" ,
                                                                               c("perf_measure",
                                                                                 "mean_perf",
                                                                                 "effect",
                                                                                 "DE", 
                                                                                 "Meta_learner",
                                                                                 "Effect",
                                                                                 "Na_action")],
                                                measure.vars = c("effect"),
                                                value.name = "value")
# 02-methyl-genexpr
res_indep_combalanced_mege_mean_perf_best_na_keep <- readRDS(file.path(res_indep_mege,
                                                                       "res_indep_combalanced_mege_mean_perf_best_na_keep.rds"))
res_indep_combalanced_mege_mean_perf_cobra_na_keep <- readRDS(file.path(res_indep_mege,
                                                                        "res_indep_combalanced_mege_mean_perf_cobra_na_keep.rds"))
res_indep_combalanced_mege_mean_perf_lasso_na_keep <- readRDS(file.path(res_indep_mege,
                                                                        "res_indep_combalanced_mege_mean_perf_lasso_na_keep.rds"))
res_indep_combalanced_mege_mean_perf_lr_na_keep <- readRDS(file.path(res_indep_mege,
                                                                     "res_indep_combalanced_mege_mean_perf_lr_na_keep.rds"))
res_indep_combalanced_mege_mean_perf_rf_na_keep <- readRDS(file.path(res_indep_mege,
                                                                     "res_indep_combalanced_mege_mean_perf_rf_na_keep.rds"))
res_indep_combalanced_mege_mean_perf_wa_na_keep <- readRDS(file.path(res_indep_mege,
                                                                     "res_indep_combalanced_mege_mean_perf_wa_na_keep.rds"))
res_indep_combalance_mege <- rbindlist(
  list(
    res_indep_combalanced_mege_mean_perf_best_na_keep,
    res_indep_combalanced_mege_mean_perf_cobra_na_keep,
    res_indep_combalanced_mege_mean_perf_lasso_na_keep,
    res_indep_combalanced_mege_mean_perf_lr_na_keep,
    res_indep_combalanced_mege_mean_perf_rf_na_keep,
    res_indep_combalanced_mege_mean_perf_wa_na_keep
  )
)
res_indep_combalance_mege[effect == "low_low" , Effect := "W.W"]
res_indep_combalance_mege[effect == "moderate_low" , Effect := "M.W"]
res_indep_combalance_mege[effect == "moderate_moderate" , Effect := "M.M"]
res_indep_combalance_mege[effect == "strong_low" , Effect := "S.W"]
res_indep_combalance_mege[effect == "strong_moderate" , Effect := "S.M"]
res_indep_combalance_mege[ , Effect := factor(Effect, level = c("W.W",
                                                                "M.W",
                                                                "M.M",
                                                                "S.W",
                                                                "S.M"))]
res_indep_combalance_mege_bs <- data.table::melt(data = res_indep_combalance_mege[perf_measure == "BS" ,
                                                                                  c("perf_measure",
                                                                                    "mean_perf",
                                                                                    "effect",
                                                                                    "DE", 
                                                                                    "Meta_learner",
                                                                                    "Effect",
                                                                                    "Na_action")],
                                                 measure.vars = c("effect"),
                                                 value.name = "value")

res_indep_combalance_mege_auc <- data.table::melt(data = res_indep_combalance_mege[perf_measure == "AUC" ,
                                                                                   c("perf_measure",
                                                                                     "mean_perf",
                                                                                     "effect",
                                                                                     "DE", 
                                                                                     "Meta_learner",
                                                                                     "Effect",
                                                                                     "Na_action")],
                                                  measure.vars = c("effect"),
                                                  value.name = "value")
# 02-methyl-genexpr-proexpr
res_indep_combalanced_megepro_mean_perf_best_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                          "res_indep_combalanced_megepro_mean_perf_best_na_keep.rds"))
res_indep_combalanced_megepro_mean_perf_cobra_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                           "res_indep_combalanced_megepro_mean_perf_cobra_na_keep.rds"))
res_indep_combalanced_megepro_mean_perf_lasso_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                           "res_indep_combalanced_megepro_mean_perf_lasso_na_keep.rds"))
res_indep_combalanced_megepro_mean_perf_lr_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_combalanced_megepro_mean_perf_lr_na_keep.rds"))
res_indep_combalanced_megepro_mean_perf_rf_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_combalanced_megepro_mean_perf_rf_na_keep.rds"))
res_indep_combalanced_megepro_mean_perf_wa_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_combalanced_megepro_mean_perf_wa_na_keep.rds"))
res_indep_combalance_megepro <- rbindlist(
  list(
    res_indep_combalanced_megepro_mean_perf_best_na_keep,
    res_indep_combalanced_megepro_mean_perf_cobra_na_keep,
    res_indep_combalanced_megepro_mean_perf_lasso_na_keep,
    res_indep_combalanced_megepro_mean_perf_lr_na_keep,
    res_indep_combalanced_megepro_mean_perf_rf_na_keep,
    res_indep_combalanced_megepro_mean_perf_wa_na_keep
  )
)
res_indep_combalance_megepro[effect == "low_low_low" , Effect := "W.W.W"]
res_indep_combalance_megepro[effect == "moderate_low_low" , Effect := "M.W.W"]
res_indep_combalance_megepro[effect == "moderate_moderate_low" , Effect := "M.M.W"]
res_indep_combalance_megepro[effect == "moderate_moderate_moderate" , Effect := "M.M.M"]
res_indep_combalance_megepro[effect == "strong_moderate_low" , Effect := "S.M.W"]
res_indep_combalance_megepro[effect == "strong_strong_moderate" , Effect := "S.S.M"]
res_indep_combalance_megepro[ , Effect := factor(x = Effect, levels = c("W.W.W",
                                                                        "M.W.W",
                                                                        "M.M.W",
                                                                        "M.M.M",
                                                                        "S.M.W",
                                                                        "S.S.M"))]
res_indep_combalance_megepro_bs <- data.table::melt(data = res_indep_combalance_megepro[perf_measure == "BS" ,
                                                                                     c("perf_measure",
                                                                                       "mean_perf",
                                                                                       "effect",
                                                                                       "DE", 
                                                                                       "Meta_learner",
                                                                                       "Effect",
                                                                                       "Na_action")],
                                                 measure.vars = c("effect"),
                                                 value.name = "value")
res_indep_combalance_megepro_auc <- data.table::melt(data = res_indep_combalance_megepro[perf_measure == "AUC" ,
                                                                                         c("perf_measure",
                                                                                           "mean_perf",
                                                                                           "effect",
                                                                                           "DE", 
                                                                                           "Meta_learner",
                                                                                           "Effect",
                                                                                           "Na_action")],
                                                     measure.vars = c("effect"),
                                                     value.name = "value")

