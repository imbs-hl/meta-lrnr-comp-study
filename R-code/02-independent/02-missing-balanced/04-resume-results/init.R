source("../init.R", chdir = TRUE)

# ============================
# Independent
# ============================
# 01-methyl.
res_indep_missbalanced_me_mean_perf_best_na_keep <- readRDS(file.path(res_indep_me,
                                                                     "res_indep_missbalanced_me_mean_perf_best_na_keep.rds"))
res_indep_missbalanced_me_mean_perf_cobra_na_keep <- readRDS(file.path(res_indep_me,
                                                                      "res_indep_missbalanced_me_mean_perf_cobra_na_keep.rds"))
res_indep_missbalanced_me_mean_perf_rf_na_keep <- readRDS(file.path(res_indep_me,
                                                                   "res_indep_missbalanced_me_mean_perf_rf_na_keep.rds"))
res_indep_missbalanced_me_mean_perf_wa_na_keep <- readRDS(file.path(res_indep_me,
                                                                   "res_indep_missbalanced_me_mean_perf_wa_na_keep.rds"))

res_indep_missbalanced_me_mean_perf_best_na_impute <- readRDS(file.path(res_indep_me,
                                                                      "res_indep_missbalanced_me_mean_perf_best_na_impute.rds"))
res_indep_missbalanced_me_mean_perf_cobra_na_impute <- readRDS(file.path(res_indep_me,
                                                                       "res_indep_missbalanced_me_mean_perf_cobra_na_impute.rds"))
res_indep_missbalanced_me_mean_perf_lasso_na_impute <- readRDS(file.path(res_indep_me,
                                                                       "res_indep_missbalanced_me_mean_perf_lasso_na_impute.rds"))
res_indep_missbalanced_me_mean_perf_lr_na_impute <- readRDS(file.path(res_indep_me,
                                                                    "res_indep_missbalanced_me_mean_perf_lr_na_impute.rds"))
res_indep_missbalanced_me_mean_perf_rf_na_impute <- readRDS(file.path(res_indep_me,
                                                                    "res_indep_missbalanced_me_mean_perf_rf_na_impute.rds"))
res_indep_missbalanced_me_mean_perf_wa_na_impute <- readRDS(file.path(res_indep_me,
                                                                    "res_indep_missbalanced_me_mean_perf_wa_na_impute.rds"))
res_indep_missbalance_me <- rbindlist(
  list(
    res_indep_missbalanced_me_mean_perf_best_na_keep,
    res_indep_missbalanced_me_mean_perf_cobra_na_keep,
    res_indep_missbalanced_me_mean_perf_rf_na_keep,
    res_indep_missbalanced_me_mean_perf_wa_na_keep,
    res_indep_missbalanced_me_mean_perf_best_na_impute,
    res_indep_missbalanced_me_mean_perf_cobra_na_impute,
    res_indep_missbalanced_me_mean_perf_lasso_na_impute,
    res_indep_missbalanced_me_mean_perf_lr_na_impute,
    res_indep_missbalanced_me_mean_perf_rf_na_impute,
    res_indep_missbalanced_me_mean_perf_wa_na_impute
  )
)
res_indep_missbalance_me[effect == "null" , Effect := "N"]
res_indep_missbalance_me[effect == "low" , Effect := "W"]
res_indep_missbalance_me[effect == "moderate" , Effect := "M"]
res_indep_missbalance_me[effect == "strong" , Effect := "S"]
res_indep_missbalance_me[ , Effect := factor(x = Effect, levels = c("N", "W",
                                                                   "M", "S"))]
res_indep_missbalance_me_bs <- data.table::melt(data = res_indep_missbalance_me[perf_measure == "BS",
                                                                              c("perf_measure",
                                                                                "mean_perf",
                                                                                "effect",
                                                                                "DE", 
                                                                                "Meta_learner",
                                                                                "Effect",
                                                                                "Na_action")],
                                               measure.vars = c("effect"),
                                               value.name = "value")
res_indep_missbalance_me_auc <- data.table::melt(data = res_indep_missbalance_me[perf_measure == "AUC" ,
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
res_indep_missbalanced_mege_mean_perf_best_na_keep <- readRDS(file.path(res_indep_mege,
                                                                       "res_indep_missbalanced_mege_mean_perf_best_na_keep.rds"))
res_indep_missbalanced_mege_mean_perf_cobra_na_keep <- readRDS(file.path(res_indep_mege,
                                                                        "res_indep_missbalanced_mege_mean_perf_cobra_na_keep.rds"))
res_indep_missbalanced_mege_mean_perf_rf_na_keep <- readRDS(file.path(res_indep_mege,
                                                                     "res_indep_missbalanced_mege_mean_perf_rf_na_keep.rds"))
res_indep_missbalanced_mege_mean_perf_wa_na_keep <- readRDS(file.path(res_indep_mege,
                                                                     "res_indep_missbalanced_mege_mean_perf_wa_na_keep.rds"))

res_indep_missbalanced_mege_mean_perf_best_na_impute <- readRDS(file.path(res_indep_mege,
                                                                        "res_indep_missbalanced_mege_mean_perf_best_na_impute.rds"))
res_indep_missbalanced_mege_mean_perf_cobra_na_impute <- readRDS(file.path(res_indep_mege,
                                                                         "res_indep_missbalanced_mege_mean_perf_cobra_na_impute.rds"))
res_indep_missbalanced_mege_mean_perf_lasso_na_impute <- readRDS(file.path(res_indep_mege,
                                                                         "res_indep_missbalanced_mege_mean_perf_lasso_na_impute.rds"))
res_indep_missbalanced_mege_mean_perf_lr_na_impute <- readRDS(file.path(res_indep_mege,
                                                                      "res_indep_missbalanced_mege_mean_perf_lr_na_impute.rds"))
res_indep_missbalanced_mege_mean_perf_rf_na_impute <- readRDS(file.path(res_indep_mege,
                                                                      "res_indep_missbalanced_mege_mean_perf_rf_na_impute.rds"))
res_indep_missbalanced_mege_mean_perf_wa_na_impute <- readRDS(file.path(res_indep_mege,
                                                                      "res_indep_missbalanced_mege_mean_perf_wa_na_impute.rds"))

res_indep_missbalance_mege <- rbindlist(
  list(
    res_indep_missbalanced_mege_mean_perf_best_na_keep,
    res_indep_missbalanced_mege_mean_perf_cobra_na_keep,
    res_indep_missbalanced_mege_mean_perf_rf_na_keep,
    res_indep_missbalanced_mege_mean_perf_wa_na_keep,
    res_indep_missbalanced_mege_mean_perf_best_na_impute,
    res_indep_missbalanced_mege_mean_perf_cobra_na_impute,
    res_indep_missbalanced_mege_mean_perf_lasso_na_impute,
    res_indep_missbalanced_mege_mean_perf_lr_na_impute,
    res_indep_missbalanced_mege_mean_perf_rf_na_impute,
    res_indep_missbalanced_mege_mean_perf_wa_na_impute
  )
)
res_indep_missbalance_mege[effect == "low_low" , Effect := "W.W"]
res_indep_missbalance_mege[effect == "moderate_low" , Effect := "M.W"]
res_indep_missbalance_mege[effect == "moderate_moderate" , Effect := "M.M"]
res_indep_missbalance_mege[effect == "strong_low" , Effect := "S.W"]
res_indep_missbalance_mege[effect == "strong_moderate" , Effect := "S.M"]
res_indep_missbalance_mege[ , Effect := factor(Effect, level = c("W.W",
                                                                "M.W",
                                                                "M.M",
                                                                "S.W",
                                                                "S.M"))]
res_indep_missbalance_mege_bs <- data.table::melt(data = res_indep_missbalance_mege[perf_measure == "BS" ,
                                                                                  c("perf_measure",
                                                                                    "mean_perf",
                                                                                    "effect",
                                                                                    "DE", 
                                                                                    "Meta_learner",
                                                                                    "Effect",
                                                                                    "Na_action")],
                                                 measure.vars = c("effect"),
                                                 value.name = "value")

res_indep_missbalance_mege_auc <- data.table::melt(data = res_indep_missbalance_mege[perf_measure == "AUC" ,
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
res_indep_missbalanced_megepro_mean_perf_best_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                          "res_indep_missbalanced_megepro_mean_perf_best_na_keep.rds"))
res_indep_missbalanced_megepro_mean_perf_cobra_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                           "res_indep_missbalanced_megepro_mean_perf_cobra_na_keep.rds"))
res_indep_missbalanced_megepro_mean_perf_rf_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_missbalanced_megepro_mean_perf_rf_na_keep.rds"))
res_indep_missbalanced_megepro_mean_perf_wa_na_keep <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_missbalanced_megepro_mean_perf_wa_na_keep.rds"))

res_indep_missbalanced_megepro_mean_perf_best_na_impute <- readRDS(file.path(res_indep_megepro,
                                                                          "res_indep_missbalanced_megepro_mean_perf_best_na_impute.rds"))
res_indep_missbalanced_megepro_mean_perf_cobra_na_impute <- readRDS(file.path(res_indep_megepro,
                                                                           "res_indep_missbalanced_megepro_mean_perf_cobra_na_impute.rds"))
res_indep_missbalanced_megepro_mean_perf_lasso_na_impute <- readRDS(file.path(res_indep_megepro,
                                                                           "res_indep_missbalanced_megepro_mean_perf_lasso_na_impute.rds"))
res_indep_missbalanced_megepro_mean_perf_lr_na_impute <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_missbalanced_megepro_mean_perf_lr_na_impute.rds"))
res_indep_missbalanced_megepro_mean_perf_rf_na_impute <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_missbalanced_megepro_mean_perf_rf_na_impute.rds"))
res_indep_missbalanced_megepro_mean_perf_wa_na_impute <- readRDS(file.path(res_indep_megepro,
                                                                        "res_indep_missbalanced_megepro_mean_perf_wa_na_impute.rds"))

res_indep_missbalance_megepro <- rbindlist(
  list(
    res_indep_missbalanced_megepro_mean_perf_best_na_keep,
    res_indep_missbalanced_megepro_mean_perf_cobra_na_keep,
    res_indep_missbalanced_megepro_mean_perf_rf_na_keep,
    res_indep_missbalanced_megepro_mean_perf_wa_na_keep,
    res_indep_missbalanced_megepro_mean_perf_best_na_impute,
    res_indep_missbalanced_megepro_mean_perf_cobra_na_impute,
    res_indep_missbalanced_megepro_mean_perf_lasso_na_impute,
    res_indep_missbalanced_megepro_mean_perf_lr_na_impute,
    res_indep_missbalanced_megepro_mean_perf_rf_na_impute,
    res_indep_missbalanced_megepro_mean_perf_wa_na_impute
  )
)
res_indep_missbalance_megepro[effect == "low_low_low" , Effect := "W.W.W"]
res_indep_missbalance_megepro[effect == "moderate_low_low" , Effect := "M.W.W"]
res_indep_missbalance_megepro[effect == "moderate_moderate_low" , Effect := "M.M.W"]
res_indep_missbalance_megepro[effect == "moderate_moderate_moderate" , Effect := "M.M.M"]
res_indep_missbalance_megepro[effect == "strong_moderate_low" , Effect := "S.M.W"]
res_indep_missbalance_megepro[effect == "strong_strong_moderate" , Effect := "S.S.M"]
res_indep_missbalance_megepro[ , Effect := factor(x = Effect, levels = c("W.W.W",
                                                                        "M.W.W",
                                                                        "M.M.W",
                                                                        "M.M.M",
                                                                        "S.M.W",
                                                                        "S.S.M"))]
res_indep_missbalance_megepro_bs <- data.table::melt(data = res_indep_missbalance_megepro[perf_measure == "BS" ,
                                                                                     c("perf_measure",
                                                                                       "mean_perf",
                                                                                       "effect",
                                                                                       "DE", 
                                                                                       "Meta_learner",
                                                                                       "Effect",
                                                                                       "Na_action")],
                                                 measure.vars = c("effect"),
                                                 value.name = "value")
res_indep_missbalance_megepro_auc <- data.table::melt(data = res_indep_missbalance_megepro[perf_measure == "AUC" ,
                                                                                         c("perf_measure",
                                                                                           "mean_perf",
                                                                                           "effect",
                                                                                           "DE", 
                                                                                           "Meta_learner",
                                                                                           "Effect",
                                                                                           "Na_action")],
                                                     measure.vars = c("effect"),
                                                     value.name = "value")

