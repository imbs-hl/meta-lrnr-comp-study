#########################################################
# TCGA: Create performance plots
# Create figures for the Brier score, AUC,
# F1 score, and runtime across the four TCGA datasets.
# Run after 05_01_create_performance.R.
#########################################################

if (!exists("results_path")) results_path <- "/imbs/projects/p23048/interconnect_use_case/tcga/results"
if (!exists("results_img_path")) results_img_path <- "/imbs/projects/p23048/interconnect_use_case/tcga/images"
dir.create(results_img_path, recursive = TRUE, showWarnings = FALSE)

# Define the labels for the four TCGA datasets.
dataset_labels <- c(
  LGG_TERT.promoter.status = "A  LGG: TERT promoter status",
  LGG_TERT.expression.status = "B  LGG: TERT expression status",
  PRAD_ERG_status = "C  PRAD: ERG status",
  STAD_Copy.Number.Cluster = "D  STAD: Copy number cluster")

# Define the method labels
method_labels  <- c(best = "Best",
                    wa = "WA",
                    lr = "LR",
                    lasso = "LASSO",
                    cobra = "COBRA",
                    ranger = "LRF",
                    ref_diablo = "DIABLO",
                    ref_bf = "BlockForest",
                    priolasso_miss = "PriorityLasso",
                    ref_srf_25_8 = "SRF",
                    ref_srf_miss_25_8 = "SRF-mis")


colors <- c("RF RNA" =   "#A6A6A6",
            "RF miRNA" = "#C2C2C2",
            "RF RPPA" =  "#DEDEDE",
            Best =       "#8C3F5D",  
            WA =         "#2A9D8F",  
            LR =         "#75608D",
            LASSO =      "#527DB5",  
            COBRA =      "#E76F51", 
            LRF =        "#E9B44C",  
            DIABLO =     "#38B6D9",  
            BlockForest ="#667A3E",  
            PriorityLasso ="#C65D7B",  
            SRF =         "#8C510A",  
            "SRF-mis" =   "#332288" )

# The first six methods use the fuseMLR prediction structure.
late_models <- names(method_labels)[seq_len(6L)]
rf_method <- "ranger"

# Each fold contributes one value per metric, not one value per patient.
rows <- list()
baseline_seen <- character()

# Load RF first so that shared baseline predictions are taken from RF results.
for (method in c(rf_method, setdiff(names(method_labels), rf_method))) {
  file <- file.path(results_path, method, "prediction_results_perf_2026.rds")

    if (!file.exists(file)) {
      warning("Missing performance file:",  file)
      next
    }
    results <- readRDS(file)
    
    for (dataset in names(dataset_labels)) {
      folds <- results[[dataset]]
      
      for (fold in seq_along(folds)) {
        df <- folds[[fold]]$pred_truth
        
        if (is.null(df) || !nrow(df)) next
        
        add <- function(model, metric, column) {
          if (!column %in% names(df)) return(NULL)
          values <- df[[column]]
          if (inherits(values, "difftime")) values <- as.numeric(values, units = "secs")
          values <- unique(as.numeric(values))
          if (length(values) != 1) stop("Expected one fold-level value: ", column)
          data.frame(dataset = dataset, fold = fold, model = model,
                     metric = metric, value = values)
        }
        
        columns <- if (method %in% late_models) {
          c(BS = "meta_layer_brier",
            AUC = "meta_layer_auc",
            F1 = "meta_layer_f1")
        } else 
          c(BS = "brier_score",
            AUC = "auc_score",
            F1 = "f1_score")
        
        for (metric in names(columns)) {
          rows[[length(rows) + 1]] <- add(model = method_labels[[method]],
                                          metric = metric,
                                          column = columns[[metric]])
        }
        
        rows[[length(rows) + 1]] <- add(model = method_labels[[method]], 
                                        metric = "TIME_FUSE",
                                        column = "Runtime_fuse")
        
        # Shared baseline metrics are included once per dataset/fold/modality.
        if (method %in% late_models) {
          for (layer in c("rna", "mirna", "rppa")) {
            
            key <- paste(dataset, fold, layer)
            
            if (key %in% baseline_seen) next
            
            baseline_seen <- c(baseline_seen, key)
            
            label <- c(rna = "RF RNA",
                       mirna = "RF miRNA",
                       rppa = "RF RPPA")[[layer]]
            
            for (metric in c("BS", "AUC", "F1")) {
              suffix <- c(BS = "brier",
                          AUC = "auc",
                          F1 = "f1")[[metric]]
              
              rows[[length(rows) + 1]] <- add(label, metric, paste0(layer, "_", suffix))
            }
          }
        }
      }
    }
  }
  
  if (!length(rows)) {
    stop("No performance files found.")

  }
  plot_data <- do.call(rbind, rows)
  
  plot_data$dataset <- factor(plot_data$dataset,
                              levels = names(dataset_labels),
                              labels = dataset_labels)
  
  plot_data$model <- factor(plot_data$model,
                            levels = names(colors))

  write.csv(plot_data, 
            file.path(results_img_path,
                      "tcga_metric_plot_data.csv"),
            row.names = FALSE)


all_plot_data <- plot_data

# Models remain on the x-axis, as in the original individual figures.
# Four metric rows share the same four disease columns.
metric_labels <- c(
  BS = "Brier score",
  AUC = "AUC",
  F1 = "F1 score",
  TIME_FUSE = "Runtime (sec, log scale)"
)

panel_labels <- c(
  BS = "A",
  AUC = "B",
  F1 = "C",
  TIME_FUSE = "D"
)

compact_dataset_labels <- c(
  "A  LGG: TERT promoter status" = "LGG\nTERT promoter status",
  "B  LGG: TERT expression status" = "LGG\nTERT expression status",
  "C  PRAD: ERG status" = "PRAD\nERG status",
  "D  STAD: Copy number cluster" = "STAD\nCopy number cluster"
)

make_metric_row <- function(plot_data,
                            metric,
                            show_diseases = FALSE) {
  data <- plot_data[plot_data$metric == metric, , drop = FALSE]
  bad <- !is.finite(data$value)
  if (any(bad)) warning(sum(bad), " unavailable values omitted for ", metric)
 
   data <- data[!bad, , drop = FALSE]
  if (!nrow(data)) stop("No finite results for ", metric, "; cannot make the complete figure.")
  
  shared_values <- all_plot_data$value[
    all_plot_data$metric == metric & is.finite(all_plot_data$value)]
  if (metric == "TIME_FUSE" && any(shared_values <= 0)) {
    stop("Log runtime requires positive times.")
  }
  
 
  model_order <- names(colors)
  
  if (metric == "TIME_FUSE") {
    model_order <- setdiff(model_order, c("RF RNA", "RF miRNA", "RF RPPA"))
  }
  
  data$model <- factor(as.character(data$model),
                       levels = model_order)
  
  p <- ggplot2::ggplot(data,
                       ggplot2::aes(x = model, 
                                    y = value,
                                    fill = model)) +
    ggplot2::geom_boxplot(
      orientation = "x", width = 0.64, linewidth = 0.22,
      outlier.size = 0.45, outlier.stroke = 0.15, na.rm = TRUE) +
    ggplot2::facet_grid(
      cols = ggplot2::vars(dataset), drop = FALSE,
      labeller = ggplot2::labeller(dataset = compact_dataset_labels)) +
    ggplot2::scale_x_discrete(drop = FALSE) +
    ggplot2::scale_fill_manual(values = colors, guide = "none") +
    #ggplot2::labs(x = NULL, y = NULL, title = metric_labels[[metric]]) +
    ggplot2::labs(x = NULL,
      y = metric_labels[[metric]],
      title = panel_labels[[metric]]) +
    ggplot2::theme_bw(base_size = 8) +
    ggplot2::theme(
      legend.position = "none",
      plot.title = ggplot2::element_text(size = 10, face = "bold", margin = ggplot2::margin(b = 5)),
      plot.title.position = "plot",
      axis.text.y = ggplot2::element_text(size = 7, colour = "black"),
      axis.text.x = ggplot2::element_text(
        size = 6.5, angle = 65, hjust = 1, vjust = 1, colour = "black"),
      axis.ticks.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_text(
        size = 10,
        face = "bold",
        margin = ggplot2::margin(r = 8)
      ) ,
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(colour = "grey90", linewidth = 0.2),
      panel.spacing.x = grid::unit(1.8, "lines"),
      strip.background = ggplot2::element_rect(fill = "grey95", colour = "grey70", linewidth = 0.25),
      strip.text.x = ggplot2::element_text(size = 8, face = "bold", margin = ggplot2::margin(t = 4, b = 4)),
      plot.margin = ggplot2::margin(t = 5, r = 7, b = 4, l = 7)
    )
  
  if (!show_diseases) {
    p <- p + ggplot2::theme(
      strip.text.x = ggplot2::element_blank(),
      strip.background = ggplot2::element_blank())
  }
  
  if (metric == "BS") {
    upper <- max(0.30, ceiling(max(shared_values) * 20) / 20)
    p <- p + ggplot2::scale_y_continuous(
      breaks = pretty(c(0, upper), n = 4), minor_breaks = NULL,
      labels = function(x) formatC(x, format = "f", digits = 2)) +
      ggplot2::coord_cartesian(ylim = c(-0.01, upper), expand = TRUE)
  } else if (metric %in% c("AUC", "F1")) {
    p <- p + ggplot2::scale_y_continuous(
      breaks = seq(0, 1, 0.25), minor_breaks = NULL,
      labels = function(x) formatC(x, format = "f", digits = 2)) +
      ggplot2::coord_cartesian(ylim = c(0, 1.02), expand = TRUE)
  } else {
    lower <- floor(log10(min(shared_values)))
    upper <- ceiling(log10(max(shared_values)))
    if (lower == upper) upper <- lower + 1
    exponents <- seq(lower, upper)
    if (length(exponents) > 5L) {
      exponents <- unique(round(seq(lower, upper, length.out = 5L)))
    }
    p <- p + ggplot2::scale_y_log10(
      breaks = 10^exponents, minor_breaks = NULL,
      labels = function(x) format(x, scientific = FALSE, trim = TRUE, big.mark = ",")) +
      ggplot2::coord_cartesian(ylim = 10^c(lower, upper), expand = TRUE)
  }
  p
}

# Arrange the four metric rows and align the dataset columns.

  metric_plots <- lapply(names(metric_labels),
                         function(metric) {
    make_metric_row(plot_data, metric,
                    show_diseases = metric == "BS")
  })
  grobs <- lapply(metric_plots, ggplot2::ggplotGrob)
  shared_widths <- do.call(grid::unit.pmax,
                           lapply(grobs, function(g) g$widths))
  for (i in seq_along(grobs)) grobs[[i]]$widths <- shared_widths
  
  children <- lapply(seq_along(grobs), function(i) {
    grid::grobTree(grobs[[i]],
                   vp = grid::viewport(layout.pos.row = i, layout.pos.col = 1))
  })
  
  figure <- grid::grobTree(
    children = do.call(grid::gList, children),
    vp = grid::viewport(layout = grid::grid.layout(
      nrow = 4, ncol = 1, heights = grid::unit(c(1.15, 1, 1, 1), "null"))))
  

  stem <- file.path(results_img_path,
                    "tcga_all_metrics_four_datasets")
  
  ggplot2::ggsave(paste0(stem, ".pdf"), figure,
                  width = 8.27, height = 10.5, units = "in", bg = "white")
  ggplot2::ggsave(paste0(stem, ".png"), figure,
                  width = 8.27, height = 10.5, units = "in", dpi = 300, bg = "white")

