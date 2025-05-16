indep_combalanced_bs_all <- rbindlist(list(res_indep_combalance_me_bs,
                                           res_indep_combalance_mege_bs,
                                           res_indep_combalance_megepro_bs))
indep_combalanced_bs_mean <- indep_combalanced_bs_all[, .(BS = mean(mean_perf)),
                                                      by = c("Meta_learner", "Effect", "DE")]
indep_combalanced_bs_mean[ , EXP := sprintf("Indep. & Compl. & %s", DE)]
theme_set(
  theme_light()
)

indep_combalanced_bs_mean[ , EXP := factor(x = EXP, levels = c("Indep. & Compl. & DE: Me",
                                                               "Indep. & Compl. & DE: MeGe",
                                                               "Indep. & Compl. & DE: MeGePro"
))]



# ================================
# Indep plots
# ================================
#
indep_combalanced_me_bs_mean_plot <- ggplot(data = indep_combalanced_bs_mean[EXP == "Indep. & Compl. & DE: Me", ],
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
  scale_y_continuous(limits = c(min(indep_combalanced_bs_mean$BS), max(indep_combalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_combalanced_bs_mean$BS),
                                        max(indep_combalanced_bs_mean$BS), length.out = 4), 2))
print(indep_combalanced_me_bs_mean_plot)



indep_combalanced_mege_bs_mean_plot <- ggplot(data = indep_combalanced_bs_mean[EXP == "Indep. & Compl. & DE: MeGe", ],
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
  scale_y_continuous(limits = c(min(indep_combalanced_bs_mean$BS), max(indep_combalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_combalanced_bs_mean$BS),
                                        max(indep_combalanced_bs_mean$BS), length.out = 4), 2))
print(indep_combalanced_mege_bs_mean_plot)



indep_combalanced_megepro_bs_mean_plot <- ggplot(data = indep_combalanced_bs_mean[EXP == "Indep. & Compl. & DE: MeGePro", ],
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
  scale_y_continuous(limits = c(min(indep_combalanced_bs_mean$BS), max(indep_combalanced_bs_mean$BS)),
                     breaks = round(seq(min(indep_combalanced_bs_mean$BS),
                                        max(indep_combalanced_bs_mean$BS), length.out = 4), 2))
print(indep_combalanced_megepro_bs_mean_plot)


extract_legend <- function(plot) {
  g <- ggplotGrob(plot)
  legend <- g$grobs[[which(sapply(g$grobs, function(x) x$name) == "guide-box")]]
  return(legend)
}
legend <- extract_legend(indep_combalanced_megepro_bs_mean_plot)
indep_combalanced_megepro_bs_mean_plot <- indep_combalanced_megepro_bs_mean_plot + theme(legend.position = "none")

bottom <- textGrob(
  expression(atop("Effect", 
                  paste("Null (N), Weak (W), Moderate (M) and Strong (S); W.W = weak effect in Me and weak effect in Ge; etc"))), 
  gp = gpar(fontsize = 13))


indep_combalanced_bs_plot <- grid.arrange(indep_combalanced_me_bs_mean_plot, 
                                          indep_combalanced_mege_bs_mean_plot,
                                          indep_combalanced_megepro_bs_mean_plot,
                                          legend,
                                          widths = c(4, 4.0),
                                          heights = c(5, 5),
                                          ncol = 2,
                                          bottom = bottom)

ggsave(plot = indep_combalanced_bs_plot,
       filename = file.path(result_dir, "indep_combalanced_combalanced_bs_plot.pdf"),
       width = 9, height = 7)







# ============================
# Dependent
# ============================
#
# 
# dep_bs_all <- rbindlist(list(dep_mege_bs, dep_megepro_bs))
# dep_bs_mean <- dep_bs_all[, .(BS = mean(meta_layer)),
#                           by = c("Meta_learner", "Effect", "DE")]
# dep_bs_mean[ , EXP := sprintf("Dep. & %s", DE)]
# all_bs <- rbindlist(list(indep_bs_mean, dep_bs_mean))
# all_bs[ , EXP := factor(x = EXP, levels = c("Indep. & DE: MeGePro",
#                                             "Indep. & DE: MeGe",
#                                             "Indep. & DE: Me",
#                                             "Dep. & DE: MeGePro",
#                                             "Dep. & DE: MeGe"
# ))]
# all_bs[Meta_learner == "BM", Meta_learner := "Best modality-spec. learner"]
# all_bs[Meta_learner == "LogReg", Meta_learner := "Logistic regression"]
# all_bs[Meta_learner == "RF", Meta_learner := "Random forests"]
# all_bs[Meta_learner == "WA", Meta_learner := "Weighted average"]
# all_bs[ , Meta_learner := factor(x = Meta_learner,
#                                  levels = c("Best modality-spec. learner",
#                                             "Weighted average",
#                                             "Logistic regression",
#                                             "Lasso",
#                                             "Random forests",
#                                             "COBRA"))]
# # ================================
# # Indep plots
# # ================================
# #
# indep_me_bs_mean_plot <- ggplot(data = all_bs[EXP == "Indep. & DE: Me", ],
#                                 aes(x = Effect, 
#                                     y = BS,
#                                     color = Meta_learner,
#                                     group = Meta_learner)) +
#   geom_point(aes(shape = Meta_learner)) + geom_line() + 
#   facet_wrap(~EXP, scale = "free", ncol = 3) + 
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
#         legend.position = "none",
#         strip.background = element_rect(fill = "white", color = "black"),
#         strip.text = element_text(color = "black", size = 12, face = "plain"),
#         plot.margin = margin(5, 0, 30, 2),
#         axis.title.y = element_text(size = 14, color = "black")
#   ) +
#   guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
#   ylab("Brier score") +
#   xlab("") + labs(color = "Meta learner", shape = "Meta learner") +
#   # ylim(min(all_bs$BS), max(all_bs$BS))
#   scale_y_continuous(limits = c(min(all_bs$BS), max(all_bs$BS)),
#                      breaks = round(seq(min(all_bs$BS),
#                                         max(all_bs$BS), length.out = 4), 2))
# print(indep_me_bs_mean_plot)
# 
# 
# indep_mege_bs_mean_plot <- ggplot(data = all_bs[EXP == "Indep. & DE: MeGe", ],
#                                   aes(x = Effect, 
#                                       y = BS,
#                                       color = Meta_learner,
#                                       group = Meta_learner)) +
#   geom_point(aes(shape = Meta_learner)) + geom_line() + 
#   facet_wrap(~EXP, scale = "free", ncol = 3) + 
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
#         legend.position = "none",
#         axis.ticks.y = element_line(color = "white", linewidth = 1.2),
#         axis.text.y = element_text(color = "white", size = 12, face = "bold"),
#         strip.background = element_rect(fill = "white", color = "black"),
#         strip.text = element_text(color = "black", size = 12, face = "plain"),
#         plot.margin = margin(5, 0, 20, 0)
#   ) +
#   guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
#   xlab("") + ylab("") + labs(color = "Meta learner", shape = "Meta learner") +
#   # ylim(min(all_bs$BS), max(all_bs$BS))
#   scale_y_continuous(limits = c(min(all_bs$BS), max(all_bs$BS)),
#                      breaks = round(seq(min(all_bs$BS),
#                                         max(all_bs$BS), length.out = 4), 2))
# print(indep_mege_bs_mean_plot)
# 
# indep_megepro_bs_mean_plot <- ggplot(data = all_bs[EXP == "Indep. & DE: MeGePro", ],
#                                      aes(x = Effect, 
#                                          y = BS,
#                                          color = Meta_learner,
#                                          group = Meta_learner)) +
#   geom_point(aes(shape = Meta_learner)) + geom_line() + 
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
#         legend.position = "none",
#         axis.ticks.y = element_line(color = "white", linewidth = 1.2),
#         axis.text.y = element_text(color = "white", size = 12, face = "bold"),
#         strip.background = element_rect(fill = "white", color = "black"),
#         strip.text = element_text(color = "black", size = 12, face = "plain"),
#         plot.margin = margin(5, 5, 10, 0)
#   ) +
#   facet_wrap(~EXP, scale = "free", ncol = 3) + 
#   guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
#   ylab("") + 
#   xlab("") + labs(color = "Meta learner", shape = "Meta learner") +
#   # ylim(min(all_bs$BS), max(all_bs$BS))
#   scale_y_continuous(limits = c(min(all_bs$BS), max(all_bs$BS)),
#                      breaks = round(seq(min(all_bs$BS),
#                                         max(all_bs$BS), length.out = 4), 2))
# print(indep_megepro_bs_mean_plot)
# 
# 
# # ================================
# # Dep. plots
# # ================================
# #
# 
# dep_mege_bs_mean_plot <- ggplot(data = all_bs[EXP == "Dep. & DE: MeGe", ],
#                                 aes(x = Effect, 
#                                     y = BS,
#                                     color = Meta_learner,
#                                     group = Meta_learner)) +
#   geom_point(aes(shape = Meta_learner)) + geom_line() + 
#   facet_wrap(~EXP, scale = "free", ncol = 3) + 
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
#         legend.position = "none",
#         strip.background = element_rect(fill = "white", color = "black"),
#         strip.text = element_text(color = "black", size = 12, face = "plain"),
#         axis.title.y = element_text(size = 14, color = "black"),
#         plot.margin = margin(5, 0, 20, 0)
#   ) +
#   guides(group = guide_legend(nrow = 3), color = guide_legend(nrow = 3)) +
#   ylab("Brier score") + 
#   xlab("") + labs(color = "Meta learner", shape = "Meta learner") +
#   # ylim(min(all_bs$BS), max(all_bs$BS))
#   scale_y_continuous(limits = c(min(all_bs$BS), max(all_bs$BS)),
#                      breaks = round(seq(min(all_bs$BS),
#                                         max(all_bs$BS), length.out = 4), 2))
# print(dep_mege_bs_mean_plot)
# 
# dep_megepro_bs_mean_plot <- ggplot(data = all_bs[EXP == "Dep. & DE: MeGePro", ],
#                                    aes(x = Effect, 
#                                        y = BS,
#                                        color = Meta_learner,
#                                        group = Meta_learner)) +
#   geom_point(aes(shape = Meta_learner)) + geom_line() + 
#   facet_wrap(~EXP, scale = "free", ncol = 1) + 
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
#         axis.ticks.y = element_line(color = "white", linewidth = 1.2),
#         axis.text.y = element_text(color = "white", size = 12, face = "bold"),
#         strip.background = element_rect(fill = "white", color = "black"),
#         strip.text = element_text(color = "black", size = 12, face = "plain"),
#         legend.text = element_text(size = 12.5),
#         legend.title = element_text(size = 14),
#         margin(5, 5, 10, 0)
#   ) +
#   guides(group = guide_legend(nrow = 1), color = guide_legend(nrow = 1)) +
#   xlab("") + ylab("") + 
#   # ylim(min(all_bs$BS), max(all_bs$BS))
#   scale_y_continuous(limits = c(min(all_bs$BS), max(all_bs$BS)),
#                      breaks = round(seq(min(all_bs$BS),
#                                         max(all_bs$BS), length.out = 4), 2)) +
#   labs(color = "Meta-learner", shape = "Meta-learner") 
# dep_megepro_bs_mean_plot <- dep_megepro_bs_mean_plot + 
#   guides(color = guide_legend(ncol = 1)) 
# print(dep_megepro_bs_mean_plot)
# 
# 
# extract_legend <- function(plot) {
#   g <- ggplotGrob(plot)
#   legend <- g$grobs[[which(sapply(g$grobs, function(x) x$name) == "guide-box")]]
#   return(legend)
# }
# legend <- extract_legend(dep_megepro_bs_mean_plot)
# dep_megepro_bs_mean_plot <- dep_megepro_bs_mean_plot + theme(legend.position = "none")
# 
# bottom <- textGrob(
#   expression(atop("Effect", 
#                   paste("Null (N), Weak (W), Moderate (M) and Strong (S); W.W = weak effect in Me and weak effect in Ge; etc"))), 
#   gp = gpar(fontsize = 13))
# 
# 
# my_griy_plot <- grid.arrange(indep_me_bs_mean_plot, 
#                              indep_mege_bs_mean_plot,
#                              indep_megepro_bs_mean_plot,
#                              legend,
#                              dep_mege_bs_mean_plot,
#                              dep_megepro_bs_mean_plot,
#                              widths = c(4, 4.0, 4.0),
#                              heights = c(5, 5),
#                              ncol = 3,
#                              bottom = bottom)
# 
# ggsave(plot = my_griy_plot,
#        filename = file.path(result_dir, "brierscore.pdf"),
#        width = 9, height = 7)
