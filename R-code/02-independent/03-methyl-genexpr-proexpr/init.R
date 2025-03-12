source("../init.R", chdir = TRUE)

# =======================================
# Methylation and gene expression effects
# =======================================
#
methyl_genexpr_proexpr_effect <- function(n = 100L,
                                  save_dir = indep_methyl_genexpr_dir) {
  methyl_strong <- rnorm(n = n, mean = 0.2, sd = 0.05)
  methyl_moderate <- rnorm(n = n, mean = 0.15, sd = 0.05)
  genexpr_strong <- rnorm(n = n, mean = 120, sd = 20)
  genexpr_moderate <- rnorm(n = n, mean = 80, sd = 10)
  genexpr_low <- rnorm(n = n, mean = 60, sd = 10)
  proexpr_moderate <- rnorm(n = n, mean = 0.08, sd = 0.02)
  proexpr_low <- rnorm(n = n, mean = 0.05, sd = 0.03)
  effect_df <- data.frame(
    delta.methyl = c(methyl_strong, methyl_strong, methyl_moderate),
    delta.expr = c(genexpr_strong, genexpr_moderate, genexpr_low),
    delta.protein = c(proexpr_moderate, proexpr_low, proexpr_low),
    effect = rep(c("strong_strong_moderate",
                   "strong_moderate_low",
                   "moderate_low_low"), each = n)
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

set.seed(4157)
indep_methyl_genexpr_proexpr_param_data <- methyl_genexpr_proexpr_effect(
  n = 100L,
  save_dir = indep_methyl_genexpr_proexpr_dir
)
