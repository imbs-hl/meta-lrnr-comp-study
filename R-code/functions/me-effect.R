# ==============================
# Methylation effects
# ==============================
#
# Also add a null effect setting
me_effect <- function(n = 100L, save_dir = indep_combalanced_me_dir) {
  me_null <- rep(0L, n)
  me_low <- rnorm(n = n, mean = 0.1, sd = 0.05)
  me_moderate <- rnorm(n = n, mean = 0.15, sd = 0.05)
  me_strong <- rnorm(n = n, mean = 0.2, sd = 0.05)
  effect_df <- data.frame(
    delta.methyl = c(me_null, me_low, me_moderate, me_strong),
    delta.expr = 0,
    delta.protein = 0,
    effect = rep(c("null", "low", "moderate", "strong"), each = 100)
  )
  random_integers <- sample(1:15000, nrow(effect_df), replace = FALSE)
  effect_df$seed <- random_integers
  effect_df$save_path <- file.path(save_dir,
                                   paste("data",
                                         paste(
                                           paste(effect_df$effect, 
                                                 effect_df$seed, sep = "_"),
                                           "rds",
                                           sep = "."),
                                         sep = "/"))
  return(effect_df)
}
