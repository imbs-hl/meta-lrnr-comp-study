# =======================================
# Methylation and gene expression effects
# =======================================
#
megepro_effect <- function(n = 100L,
                                          save_dir = indep_missbalanced_megepro_dir) {

  me_low <- rep(0.30, n) 
  me_moderate <- rep(0.48, n)
  ge_low <- rep(142, n)
  ge_moderate <-  rep(231, n)
  pro_low <-  rep(0.17, n) 
  pro_moderate <-   rep(0.29, n) 
  
  
  effect_df <- data.frame(
    delta.methyl = c(me_moderate,
                     me_low,
                     me_low,
                     me_low),
    delta.expr = c(ge_moderate,
                   ge_moderate,
                   ge_low,
                   ge_low),
    delta.protein = c(pro_moderate,
                      pro_moderate,
                      pro_moderate,
                      pro_low),
    effect = rep(c("moderate_moderate_moderate",
                   "low_moderate_moderate",
                   "low_low_moderate",
                   "low_low_low"), each = n))
  
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
