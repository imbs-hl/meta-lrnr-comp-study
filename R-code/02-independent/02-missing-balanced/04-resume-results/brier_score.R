indep_missbalanced_bs_all <- rbindlist(list(res_indep_missbalance_me_bs,
                                            res_indep_missbalance_mege_bs,
                                            res_indep_missbalance_megepro_bs))
indep_missbalanced_bs_mean <- indep_missbalanced_bs_all[, .(BS = mean(mean_perf)),
                                                        by = c("Meta_learner",
                                                               "Effect",
                                                               "DE",
                                                               "Na_action")]
indep_missbalanced_bs_mean[ , EXP := sprintf("Indep. & %s & %s", Na_action, DE)]
theme_set(
  theme_light()
)

indep_missbalanced_bs_mean[ , EXP := factor(x = EXP, levels = c("Indep. & na.keep & DE: Me",
                                                                "Indep. & na.keep & DE: MeGe",
                                                                "Indep. & na.keep & DE: MeGePro",
                                                                "Indep. & na.impute & DE: Me",
                                                                "Indep. & na.impute & DE: MeGe",
                                                                "Indep. & na.impute & DE: MeGePro"
))]



# ******************************************************************************
# All results for na_action = na.impute
# ******************************************************************************
#

# ================================
# Indep plots
# ================================
#
indep_missbalanced_me_bs_mean_na_impute_plot <- ggplot(data = indep_missbalanced_bs_mean[(EXP == "Indep. & na.impute & DE: Me") & 
                                                                                 (Na_action == "na.impute"), ],
                                             aes(x = Effect, 
                                                 y = BS,
                                                 color = Meta_learner,
                                                 group = Meta_learner)) +
  geom_point(aes(shape = Meta_learner)) + geom_line() + 
  facet_wrap(~EXP, scale = "free", ncol = 2) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        legend.position = "none",
        strip.background = element_rect(fill = "white", color = "black"),
        strip.text = element_text(color = "black", size = 12, face = "plain"),
        plot.margin = margin(5, 0, 30, 2),
        axis.title.y = element_text(size = 14, color = "black")
  ) +
  guides(group = guide_legend(nrow = 4), color = guide_legend(nrow = 3)) +
  ylab("Brier score") +
  xlab("") + labs(color = "Meta learner", shape = "Meta learner") +
  # ylim(min(all_bs$BS), max(all_bs$BS))
  scale_y_continuous(limits = c(min(indep_missbalanced_bs_mean$BS), max(indep_missbalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_missbalanced_bs_mean$BS),
                                        max(indep_missbalanced_bs_mean$BS), length.out = 4), 2))
print(indep_missbalanced_me_bs_mean_na_impute_plot)



indep_missbalanced_mege_bs_mean_na_impute_plot <- ggplot(data = indep_missbalanced_bs_mean[(EXP == "Indep. & na.impute & DE: MeGe") & 
                                                                                   (Na_action == "na.impute"), ],
                                               aes(x = Effect, 
                                                   y = BS,
                                                   color = Meta_learner,
                                                   group = Meta_learner)) +
  geom_point(aes(shape = Meta_learner)) + geom_line() + 
  facet_wrap(~EXP, scale = "free", ncol = 3) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        legend.position = "none",
        axis.ticks.y = element_line(color = "white", linewidth = 1.2),
        axis.text.y = element_text(color = "white", size = 12, face = "bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        strip.text = element_text(color = "black", size = 12, face = "plain"),
        plot.margin = margin(5, 1, 20, 0)
  ) +
  guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
  xlab("") + ylab("") + labs(color = "Meta learner", shape = "Meta learner") +
  # ylim(min(all_bs$BS), max(all_bs$BS))
  scale_y_continuous(limits = c(min(indep_missbalanced_bs_mean$BS), max(indep_missbalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_missbalanced_bs_mean$BS),
                                        max(indep_missbalanced_bs_mean$BS), length.out = 4), 2))
print(indep_missbalanced_mege_bs_mean_na_impute_plot)



indep_missbalanced_megepro_bs_mean_na_impute_plot <- ggplot(data = indep_missbalanced_bs_mean[(EXP == "Indep. & na.impute & DE: MeGePro") & 
                                                                                      (Na_action == "na.impute"), ],
                                                  aes(x = Effect, 
                                                      y = BS,
                                                      color = Meta_learner,
                                                      group = Meta_learner)) +
  geom_point(aes(shape = Meta_learner)) + geom_line() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        # legend.position = "none",
        axis.ticks.y = element_line(color = "white", linewidth = 1.2),
        # axis.text.y = element_text(color = "white", size = 12, face = "bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        strip.text = element_text(color = "black", size = 12, face = "plain"),
        axis.title.y = element_text(size = 14, color = "black"),
        plot.margin = margin(5, 0, 10, 2)
  ) +
  facet_wrap(~EXP, scale = "free", ncol = 3) + 
  guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
  ylab("Brier score") + 
  xlab("") + labs(color = "Meta learner", shape = "Meta learner") +
  # ylim(min(all_bs$BS), max(all_bs$BS))
  scale_y_continuous(limits = c(min(indep_missbalanced_bs_mean$BS), max(indep_missbalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_missbalanced_bs_mean$BS),
                                        max(indep_missbalanced_bs_mean$BS), length.out = 4), 2))
print(indep_missbalanced_megepro_bs_mean_na_impute_plot)


extract_legend <- function(plot) {
  g <- ggplotGrob(plot)
  legend <- g$grobs[[which(sapply(g$grobs, function(x) x$name) == "guide-box")]]
  return(legend)
}
legend <- extract_legend(indep_missbalanced_megepro_bs_mean_na_impute_plot)
indep_missbalanced_megepro_bs_mean_na_impute_plot <- indep_missbalanced_megepro_bs_mean_na_impute_plot + theme(legend.position = "none")

bottom <- textGrob(
  expression(atop("Effect", 
                  paste("Null (N), Weak (W), Moderate (M) and Strong (S); W.W = weak effect in Me and weak effect in Ge; etc"))), 
  gp = gpar(fontsize = 13))


indep_missbalanced_na_impute_bs_plot <- grid.arrange(indep_missbalanced_me_bs_mean_na_impute_plot, 
                                           indep_missbalanced_mege_bs_mean_na_impute_plot,
                                           indep_missbalanced_megepro_bs_mean_na_impute_plot,
                                           legend,
                                           widths = c(4, 4.0),
                                           heights = c(5, 5),
                                           ncol = 2,
                                           bottom = bottom)

ggsave(plot = indep_missbalanced_na_impute_bs_plot,
       filename = file.path(result_dir, "indep_missbalanced_na_impute_bs_plot.pdf"),
       width = 9, height = 7)







# ******************************************************************************
# All results for na_action = na.keep
# ******************************************************************************
#

# ================================
# Indep plots
# ================================
#
indep_missbalanced_me_bs_mean_na_keep_plot <- ggplot(data = indep_missbalanced_bs_mean[(EXP == "Indep. & na.keep & DE: Me") & 
                                                                                           (Na_action == "na.keep"), ],
                                                       aes(x = Effect, 
                                                           y = BS,
                                                           color = Meta_learner,
                                                           group = Meta_learner)) +
  geom_point(aes(shape = Meta_learner)) + geom_line() + 
  facet_wrap(~EXP, scale = "free", ncol = 2) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        legend.position = "none",
        strip.background = element_rect(fill = "white", color = "black"),
        strip.text = element_text(color = "black", size = 12, face = "plain"),
        plot.margin = margin(5, 0, 30, 2),
        axis.title.y = element_text(size = 14, color = "black")
  ) +
  guides(group = guide_legend(nrow = 4), color = guide_legend(nrow = 3)) +
  ylab("Brier score") +
  xlab("") + labs(color = "Meta learner", shape = "Meta learner") +
  # ylim(min(all_bs$BS), max(all_bs$BS))
  scale_y_continuous(limits = c(min(indep_missbalanced_bs_mean$BS), max(indep_missbalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_missbalanced_bs_mean$BS),
                                        max(indep_missbalanced_bs_mean$BS), length.out = 4), 2))
print(indep_missbalanced_me_bs_mean_na_keep_plot)



indep_missbalanced_mege_bs_mean_na_keep_plot <- ggplot(data = indep_missbalanced_bs_mean[(EXP == "Indep. & na.keep & DE: MeGe") & 
                                                                                             (Na_action == "na.keep"), ],
                                                         aes(x = Effect, 
                                                             y = BS,
                                                             color = Meta_learner,
                                                             group = Meta_learner)) +
  geom_point(aes(shape = Meta_learner)) + geom_line() + 
  facet_wrap(~EXP, scale = "free", ncol = 3) + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        legend.position = "none",
        axis.ticks.y = element_line(color = "white", linewidth = 1.2),
        axis.text.y = element_text(color = "white", size = 12, face = "bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        strip.text = element_text(color = "black", size = 12, face = "plain"),
        plot.margin = margin(5, 1, 20, 0)
  ) +
  guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
  xlab("") + ylab("") + labs(color = "Meta learner", shape = "Meta learner") +
  # ylim(min(all_bs$BS), max(all_bs$BS))
  scale_y_continuous(limits = c(min(indep_missbalanced_bs_mean$BS), max(indep_missbalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_missbalanced_bs_mean$BS),
                                        max(indep_missbalanced_bs_mean$BS), length.out = 4), 2))
print(indep_missbalanced_mege_bs_mean_na_keep_plot)



indep_missbalanced_megepro_bs_mean_na_keep_plot <- ggplot(data = indep_missbalanced_bs_mean[(EXP == "Indep. & na.keep & DE: MeGePro") & 
                                                                                                (Na_action == "na.keep"), ],
                                                            aes(x = Effect, 
                                                                y = BS,
                                                                color = Meta_learner,
                                                                group = Meta_learner)) +
  geom_point(aes(shape = Meta_learner)) + geom_line() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        # legend.position = "none",
        axis.ticks.y = element_line(color = "white", linewidth = 1.2),
        # axis.text.y = element_text(color = "white", size = 12, face = "bold"),
        strip.background = element_rect(fill = "white", color = "black"),
        strip.text = element_text(color = "black", size = 12, face = "plain"),
        axis.title.y = element_text(size = 14, color = "black"),
        plot.margin = margin(5, 0, 10, 2)
  ) +
  facet_wrap(~EXP, scale = "free", ncol = 3) + 
  guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
  ylab("Brier score") + 
  xlab("") + labs(color = "Meta learner", shape = "Meta learner") +
  # ylim(min(all_bs$BS), max(all_bs$BS))
  scale_y_continuous(limits = c(min(indep_missbalanced_bs_mean$BS), max(indep_missbalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_missbalanced_bs_mean$BS),
                                        max(indep_missbalanced_bs_mean$BS), length.out = 4), 2))
print(indep_missbalanced_megepro_bs_mean_na_keep_plot)


extract_legend <- function(plot) {
  g <- ggplotGrob(plot)
  legend <- g$grobs[[which(sapply(g$grobs, function(x) x$name) == "guide-box")]]
  return(legend)
}
legend <- extract_legend(indep_missbalanced_megepro_bs_mean_na_keep_plot)
indep_missbalanced_megepro_bs_mean_na_keep_plot <- indep_missbalanced_megepro_bs_mean_na_keep_plot + theme(legend.position = "none")

bottom <- textGrob(
  expression(atop("Effect", 
                  paste("Null (N), Weak (W), Moderate (M) and Strong (S); W.W = weak effect in Me and weak effect in Ge; etc"))), 
  gp = gpar(fontsize = 13))


indep_missbalanced_na_keep_bs_plot <- grid.arrange(indep_missbalanced_me_bs_mean_na_keep_plot, 
                                                     indep_missbalanced_mege_bs_mean_na_keep_plot,
                                                     indep_missbalanced_megepro_bs_mean_na_keep_plot,
                                                     legend,
                                                     widths = c(4, 4.0),
                                                     heights = c(5, 5),
                                                     ncol = 2,
                                                     bottom = bottom)

ggsave(plot = indep_missbalanced_na_keep_bs_plot,
       filename = file.path(result_dir, "indep_missbalanced_na_keep_bs_plot.pdf"),
       width = 9, height = 7)
