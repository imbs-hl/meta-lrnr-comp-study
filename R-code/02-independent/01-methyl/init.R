source("../init.R", chdir = TRUE)

# ==============================
# Methylation effects
# ==============================
#
# Also add a null effect setting
methyl_effect <- function(n = 100L, save_dir = indep_methyl_dir) {
  methyl_null <- rep(0L, n)
  methyl_low <- rnorm(n = n, mean = 0.1, sd = 0.05)
  methyl_moderate <- rnorm(n = n, mean = 0.15, sd = 0.05)
  methyl_strong <- rnorm(n = n, mean = 0.2, sd = 0.05)
  effect_df <- data.frame(
    delta.methyl = c(methyl_null, methyl_low, methyl_moderate, methyl_strong),
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

set.seed(4157)
indep_methy_param_data <- methyl_effect(n = 100L, save_dir = indep_methyl_dir)


# =======================================
# Methylation and gene expression effects
# =======================================
#
methyl_genexpr_effect <- function(n = 100L,
                                  save_dir = indep_methyl_genexpr_dir) {
  methyl_moderate <- rnorm(n = n, mean = 0.15, sd = 0.05)
  genexpr_low <- rnorm(n = n, mean = 60, sd = 10)
  effect_df <- data.frame(
    delta.methyl = methyl_moderate,
    delta.expr = genexpr_low,
    delta.protein = 0,
    effect = rep(c("moderate_low"), each = 100)
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
indep_methy_genexpr_param_data <- methyl_genexpr_effect(
  n = 100L,
  save_dir = indep_methyl_dir
  )

# ==============================
# Strong methylation effects
# ==============================
#