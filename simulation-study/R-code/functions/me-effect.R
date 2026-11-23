# ==============================
# Methylation effects
# ==============================
#
# Also add a null effect setting
me_effect <- function(n = 100L, save_dir = indep_combalanced_me_dir) {
  me_null <- rep(0L, n)
  me_low <- rep(0.30, n)
  me_moderate <- rep(0.48, n)

  effect_df <- data.frame(
    delta.methyl = c(me_null, me_low, me_moderate),
    delta.expr = 0,
    delta.protein = 0,
    effect = rep(c("null_null_null",
                   "low_null_null",
                   "moderate_null_null"),
                 each = n)
  )
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
