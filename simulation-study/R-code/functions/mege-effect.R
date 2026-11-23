# =======================================
# Methylation and gene expression effects
# =======================================
#
mege_effect <- function(n = 100L,
                                  save_dir = indep_missbalanced_mege_dir) {
  me_low <- rep(0.30, n) 
  me_moderate <- rep(0.48, n)
  
  ge_low <- rep(142, n) 
  ge_moderate <-  rep(231, n) 
  
  effect_df <- data.frame(
    delta.methyl = c(me_low,
                     me_low,
                     me_moderate
    ),
    delta.expr = c(ge_low,
                   ge_moderate,
                   ge_moderate
    ),
    delta.protein = 0,
    effect = rep(c("low_low_null",
                   "low_moderate_null",
                   "moderate_moderate_null"),
                 each = n))
  random_integers <- sample(1:15000, nrow(effect_df), replace = FALSE)
  effect_df$seed <- random_integers
  effect_df$save_path <- file.path(save_dir,
                                   paste(
                                         paste(
                                           paste(effect_df$effect, 
                                                 effect_df$seed, sep = "_"),
                                           "rds",
                                           sep = "."),
                                         sep = "/"))
  return(effect_df)
}