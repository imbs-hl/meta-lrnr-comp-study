# =======================================
# Methylation and gene expression effects
# =======================================
#
mege_effect <- function(n = 100L,
                                  save_dir = indep_missbalanced_mege_dir) {
  me_strong <- rnorm(n = n, mean = 0.2, sd = 0.05)
  me_moderate <- rnorm(n = n, mean = 0.15, sd = 0.05)
  me_low <- rnorm(n = n, mean = 0.1, sd = 0.05)
  ge_moderate <- rnorm(n = n, mean = 80, sd = 10)
  ge_low <- rnorm(n = n, mean = 60, sd = 10)
  effect_df <- data.frame(
    delta.methyl = c(me_strong,
                     me_strong,
                     me_moderate,
                     me_moderate,
                     me_low),
    delta.expr = c(ge_moderate,
                   ge_low,
                   ge_moderate,
                   ge_low,
                   ge_low),
    delta.protein = 0,
    effect = rep(c("strong_moderate",
                   "strong_low",
                   "moderate_moderate",
                   "moderate_low",
                   "low_low"), each = n)
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