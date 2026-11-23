# Aufruf: R-code/02-simulation
# Plot for paper


paper_methods <- c("best",
                   "wa",
                   "lr",
                   "lasso",
                   "cobra",
                   "rf",
                   "diablo-mis",
                   "bf",
                   "pl",
                   "srf",
                   "srf-mis"
                   )

paper_method_labels <- c(best = "Best",
                         wa = "WA",
                         lr = "LR",
                         lasso = "LASSO", 
                         cobra = "COBRA",
                         rf = "LRF",
                         "diablo-mis" = "DIABLO",
                         bf = "BlockForest",
                         pl = "PriorityLasso",
                         srf = "SRF",
                         "srf-mis" = "SRF-mis")

paper_effects <- list(me = c("null_null_null",
                             "low_null_null",
                             "moderate_null_null"),
                      mege = c("low_low_null",
                               "low_moderate_null",
                               "moderate_moderate_null"),
                      megepro = c("low_low_low",
                                  "low_low_moderate",
                                  "low_moderate_moderate",
                                  "moderate_moderate_moderate"))

paper_panels <- c(me = "A  Effect in one modality",
                  mege = "B  Effect in two modalities",
                  megepro = "C  Effect in three modalities")


# Each list element is one simulation run, so runtime and baseline predictions
# are never duplicated across metric rows or across meta-learners.
load_paper_results <- function(perf_dirs,
                               type = c("complete", "missing"),
                               methods = paper_methods,
                               source = c("registry", "rds"),
                               config_file = NA_character_) {
  type <- match.arg(type)
  source <- match.arg(source)
  
  if (!identical(names(perf_dirs), names(paper_effects)))
    stop("perf_dirs must be named me, mege, megepro, in that order.")
  
  if (any(!methods %in% paper_methods))
    stop("Unknown method identifier.")
  
  prefix <- if (type == "complete") "com" else "mis"
  output <- list()
  
  for (scenario in names(perf_dirs)) {
    baseline <- list()
    for (method in methods) {
      if (source == "registry") {
        path <- file.path(perf_dirs[[scenario]],
                          paste0("03-", prefix, "-", scenario,
                                 "-perf-", method))
        
        if (!dir.exists(path)) stop("Missing registry: ", path)
        reg <- batchtools::loadRegistry(path,
                                        writeable = FALSE, 
                                        conf.file = config_file)
        ids <- batchtools::findDone(reg = reg)
        if (!nrow(ids)) stop("No completed results: ", path)
        runs <- batchtools::reduceResultsList(ids = ids, reg = reg)
      } else {
        # Saved folder names differ from the registry suffix for PriorityLasso.
        folder <- switch(method,
                         pl = "priolasso",
                         "diablo-mis" = "diablo_miss",
                         "srf-mis" = "srf_mis",
                         method)
        path <- file.path(perf_dirs[[scenario]], folder)
        files <- list.files(path, pattern = "\\.rds$", full.names = TRUE)
        if (!length(files)) stop("No performance RDS files: ", path)
        runs <- lapply(files, readRDS)
      }
      
      for (i in seq_along(runs)) {
        
        x <- as.data.frame(runs[[i]])
        
        needed <- c("perf_measure",
                    "effect",
                    "seed", 
                    "runtime")
        
        if (!all(needed %in% names(x))) stop("Not a performance result: ",
                                             path)
        if (length(unique(x$seed)) != 1L || length(unique(x$effect)) != 1L)
          stop("Expected one seed and effect per saved result: ", path)
        if (!all(x$effect %in% paper_effects[[scenario]]))
          stop("Unexpected effect in ", path, ": ", paste(unique(x$effect),
                                                          collapse = ", "))
        
        add <- function(model, metric, value) {
          data.frame(type = type,
                     scenario = scenario,
                     effect = x$effect[1],
                     seed = x$seed[1],
                     model = model, 
                     metric = metric, 
                     value = value)
        }
        late <- method %in% c("best", "wa", "lr", "lasso", "cobra", "rf")
        column <- if (late) "meta_layer" else "perf"
        
        if (!column %in% names(x))
          stop("Missing ", column, " in ", path)
        
        output[[length(output) + 1L]] <- add(paper_method_labels[[method]],
                                           x$perf_measure, 
                                           x[[column]])
        
        rt <- if (inherits(x$runtime, "difftime"))
          
          as.numeric(x$runtime, units = "secs") else as.numeric(x$runtime)
        
        if (length(unique(rt)) != 1L) stop("Inconsistent runtime in ", path)
        
        output[[length(output) + 1L]] <- add(paper_method_labels[[method]],
                                             "TIME",
                                             rt[1])
        # The second runtime metric includes shared base-model training for late integration.
        # Other methods already measure their own model training in runtime.
        rt_fuse <- rt
        if (late) {
          seconds <- function(z) {
            if (inherits(z, "difftime")) as.numeric(z, units = "secs") else as.numeric(z)
          }
          if ("runtime_fuse" %in% names(x)) {
            rt_fuse <- seconds(x$runtime_fuse)
          } else if ("runtime_basemodel" %in% names(x)) {
            rt_fuse <- rt + seconds(x$runtime_basemodel)
          } else {
            rt_fuse <- rep(NA_real_, length(rt))
          }
        }
        if (length(unique(rt_fuse)) != 1L) stop("Inconsistent runtime_fuse in ", path)
        output[[length(output) + 1L]] <- add(paper_method_labels[[method]],
                                             "TIME_FUSE", rt_fuse[1])
        if (late) {
          for (col in c("methylation", "geneexpr", "proteinexpr")) {
            if (!col %in% names(x)) stop("Missing baseline column: ", col)
            key <- paste(x$seed[1], x$effect[1], col, sep = ":")
            values <- stats::setNames(x[[col]], x$perf_measure)
            
            # Keep each baseline once, from the first loaded method (default: Best).
            if (is.null(baseline[[key]])) {
              baseline[[key]] <- values
              label <- c(methylation = "RF methylation", geneexpr = "RF expression",
                         proteinexpr = "RF protein")[[col]]
              output[[length(output) + 1L]] <- add(label, x$perf_measure, x[[col]])
            }
          }
        }
      }
    }
  }
  
  result <- do.call(rbind, output)
  keys <- result[c("type", "scenario", "effect", "seed", "model", "metric")]
  if (anyDuplicated(keys)) stop("Duplicate simulation results; check input folders.")
  result
}


# One metric, optionally both data types: complete above missing.
create_paper_metric_plot <- function(results,
    #Offer both the original runtime and runtime including base training.
    metric = c("BS", "AUC", "F1", "TIME", "TIME_FUSE"),
    file = NULL,
    time_log = TRUE, 
    time_digits = 2,
    bs_ylim = c(-0.05, 0.30),
    width = 20,
    height = 11,
    scenario_set = c("all", "effects", "null")) {
  metric <- match.arg(metric)
  scenario_set <- match.arg(scenario_set)
  is_null <- scenario_set == "null"
  enabled_models <- c("RF methylation", "RF expression", "RF protein",
                      unname(paper_method_labels[paper_methods]))
  
  d <- results[results$metric == metric & results$model %in% enabled_models, ]
  if (scenario_set == "effects") d <- d[d$effect != "null_null_null", ]
  if (scenario_set == "null") d <- d[d$effect == "null_null_null", ]
  if (!nrow(d)) stop("No results for ", metric)
  bad <- !is.finite(d$value)
  if (any(bad)) warning(sum(bad), " non-finite results omitted for ", metric)
  
  d <- d[!bad, ]
  
  if (!nrow(d)) stop("No finite results for ", metric)
  
  model_order <- c("RF methylation", "RF expression", "RF protein",
                   unname(paper_method_labels))
  
  d$model <- factor(d$model,
                    levels = model_order[model_order %in% d$model])
  
  effects <- unlist(paper_effects, use.names = FALSE)
  
  labels <- vapply(strsplit(effects, "_"),
    function(z) {
      paste(
        c(null = "N", low = "L", moderate = "M")[z],
        collapse = "/")
    },
    character(1))
  
  d$effect <- factor(d$effect, levels = effects)
  d$scenario <- factor(d$scenario, levels = names(paper_panels), labels = paper_panels)
  d$type <- factor(d$type, levels = c("complete", "missing"),
                   #labels = c("Complete data", "Modality-wise missing data"))
                   labels = c("Complete data", "Modality-wise missingness"))

  colors <- c(
    "RF methylation" = "#A6A6A6",
    "RF expression"  = "#C2C2C2",
    "RF protein"     = "#DEDEDE",
    "Best"          = "#8C3F5D",  # Dunkles Beerenrot
    "WA"            = "#2A9D8F",  # Türkis
    "LR"            = "#75608D",
    "LASSO"         = "#527DB5",  # Mittelblau
    "COBRA"         = "#E76F51",  # Koralle
    "LRF"           = "#E9B44C",  # Gold 
    "DIABLO"        = "#38B6D9",  # Cyan
    "BlockForest"   = "#667A3E",  # Olivgrün
    "PriorityLasso" = "#C65D7B",  # Altrosa 
    "SRF"           = "#8C510A",  # Braun
    "SRF-mis"       = "#332288"   
  )
  ylabel <- c(BS = "Brier score",
              AUC = "AUC",
              F1 = "F1 score",
              # Distinguish the two time figures in the axis labels.
              TIME = "Runtime excluding shared base training (seconds)",
              TIME_FUSE = "Runtime (sec, log scale)")[[metric]]
  

    caption <- NULL
  
  if (is_null) {
    
    p <- ggplot2::ggplot(
      d,
      ggplot2::aes(
        x = model,
        y = value,
        fill = model
      )
    ) +
      ggplot2::geom_boxplot(
        width = 0.72,
        linewidth = 0.45,
        outlier.size = 0.9
      ) +
      ggplot2::scale_x_discrete(
        drop = TRUE
      ) +
      ggplot2::labs(
        x = NULL,
        y = ylabel,
        fill = NULL,
        caption = caption
      )
    
  } else {
    
    p <- ggplot2::ggplot(
      d,
      ggplot2::aes(
        x = effect,
        y = value,
        fill = model
      )
    ) +
      ggplot2::geom_boxplot(
        position = ggplot2::position_dodge2(
          preserve = "single"
        ),
        linewidth = 0.3,
        outlier.size = 0.7
      ) +
      ggplot2::scale_x_discrete(
        labels = stats::setNames(labels, effects)
      ) +
      ggplot2::labs(
        x = "Effect strength",
        y = ylabel,
        fill = NULL,
        caption = caption
      )
  }

  
  p <- p +
    ggplot2::scale_fill_manual(
      values = colors,
      drop = TRUE
    ) +
    ggplot2::theme_bw(base_size = 18) +
    ggplot2::theme(
      
      # Y-axis title: much larger
      axis.title.y = ggplot2::element_text(
        size = 24,
        face = "bold",
        margin = ggplot2::margin(r = 15)
      ),
      
      # X-axis title
      axis.title.x = ggplot2::element_text(
        size = 21,
        face = "bold",
        margin = ggplot2::margin(t = 12)
      ),
      
      # Y-axis numbers
      axis.text.y = ggplot2::element_text(
        size = 19,
        colour = "black"
      ),
      
      # X-axis labels
      axis.text.x = ggplot2::element_text(
        size = 18,
        colour = "black"
      ),
      
      # Larger panel headings
      strip.text = ggplot2::element_text(
        size = 21,
        face = "bold",
        colour = "black",
        margin = ggplot2::margin(
          t = 10, b = 10, l = 8, r = 8
        )
      ),
      
      strip.background = ggplot2::element_rect(
        fill = "grey95",
        colour = "grey65"
      ),
      
      panel.spacing.y = grid::unit(1.2, "lines"),
      
      panel.grid.major.y = ggplot2::element_line(
        colour = "grey93",
        linewidth = 0.25,
        linetype = "dotted"
      ),
      
      panel.grid.minor.y = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor.x = ggplot2::element_blank(),
      
      plot.caption = ggplot2::element_text(
        hjust = 0,
        size = 13
      ),
      
      plot.margin = ggplot2::margin(
        t = 15, r = 15, b = 20, l = 15
      )
    )
  if (is_null) {
    
   
    p <- p +
      ggplot2::facet_grid(. ~ type) +
      ggplot2::theme(
        
        legend.position = "none",
        
        # Larger panel headings for null models
        strip.text.x = ggplot2::element_text(
          size = 24,
          face = "bold",
          colour = "black",
          margin = ggplot2::margin(
            t = 12, b = 12
          )
        ),
        
        # Slanted model names
        axis.text.x = ggplot2::element_text(
          size = 17,
          angle = 45,
          hjust = 1,
          vjust = 1,
          colour = "black"
        ),
        
        axis.title.x = ggplot2::element_blank()
      )
    
  } else {
    
    
    p <- p +
      ggplot2::facet_grid(
        type ~ scenario,
        scales = "free_x",
        space = "free_x"
      ) +
      ggplot2::theme(
        
        legend.position = "bottom",
        
        legend.text = ggplot2::element_text(
          size = 17
        ),
        
        legend.key.size = grid::unit(
          0.8, "lines"
        ),
        
        strip.text.x = ggplot2::element_text(
          size = 20,
          face = "bold"
        ),
        
        strip.text.y = ggplot2::element_text(
          size = 20,
          face = "bold"
        )
      ) +
      ggplot2::guides(
        fill = ggplot2::guide_legend(
          nrow = 2,
          byrow = TRUE
        )
      )
  }
  
  # --------------------------------------------------
  # Y-axis
  # --------------------------------------------------
  
  decimal_labels <- function(x) {
    formatC(x, format = "f", digits = 2)
  }
  
  if (metric == "BS") {
    
    if (is_null) {
      bs_ylim <- c(0, 0.45)
    }
    
    outside <- sum(
      d$value < bs_ylim[1] |
        d$value > bs_ylim[2]
    )
    
    if (outside) {
      warning(
        outside,
        " BS values outside displayed range ",
        paste(bs_ylim, collapse = " to "),
        "; retained in boxplot calculation."
      )
    }
    
    p <- p +
      ggplot2::scale_y_continuous(
        breaks = seq(
          0, bs_ylim[2], by = 0.05
        ),
        minor_breaks = NULL,
        labels = function(x) {
          ifelse(
            abs(x) < 1e-10,
            "0",
            formatC(
              x,
              format = "f",
              digits = 2
            )
          )
        }
      ) +
      ggplot2::coord_cartesian(
        ylim = bs_ylim,
        expand = FALSE
      )
    
  } else if (metric %in% c("AUC", "F1")) {
    
    metric_ylim <- if (is_null) {
      c(0, 0.80)
    } else {
      c(0.30, 1.02)
    }
    
    p <- p +
      ggplot2::scale_y_continuous(
        breaks = seq(
          metric_ylim[1],
          metric_ylim[2],
          by = 0.05
        ),
        minor_breaks = NULL,
        labels = decimal_labels
      ) +
      ggplot2::coord_cartesian(
        ylim = metric_ylim,
        expand = FALSE
      )
    
  } else {
    
    # Runtime metrics
    
    if (time_log && any(d$value <= 0)) {
      stop(
        "Log runtime requires positive times; ",
        "use time_log = FALSE."
      )
    }
    
    positive <- d$value[d$value > 0]
    
    digits <- time_digits
    
    if (length(positive)) {
      digits <- max(
        digits,
        ceiling(-log10(min(positive)))
      )
    }
    
    time_labels <- function(x) {
      formatC(
        x,
        format = "f",
        digits = digits,
        big.mark = ","
      )
    }
    
    if (time_log) {
      
      exponent <- seq(
        floor(log10(min(positive))),
        ceiling(log10(max(positive)))
      )
      
      ticks <- sort(
        as.vector(
          outer(c(1, 2, 5), 10^exponent)
        )
      )
      
      ticks <- ticks[
        ticks >= min(positive) &
          ticks <= max(positive)
      ]
      
      if (length(ticks) < 2) {
        ticks <- pretty(
          range(positive),
          n = 6
        )
      }
      
      ticks <- ticks[ticks > 0]
      
      p <- p +
        ggplot2::scale_y_log10(
          breaks = ticks,
          labels = time_labels
        )
      
    } else {
      
      p <- p +
        ggplot2::scale_y_continuous(
          breaks = function(x) {
            pretty(x, n = 10)
          },
          labels = time_labels
        )
    }
  }
  
  # --------------------------------------------------
  # Save figure
  # --------------------------------------------------
  
  if (!is.null(file)) {
    
    dir.create(
      dirname(file),
      recursive = TRUE,
      showWarnings = FALSE
    )
    
    ggplot2::ggsave(
      filename = file,
      plot = p,
      width = width,
      height = height,
      units = "in",
      dpi = 300
    )
  }
  
  # --------------------------------------------------
  # Return
  # --------------------------------------------------
  
  list(
    plot = p,
    results = d,
    counts = aggregate(
      value ~ type + scenario + effect + model,
      d,
      length
    )
  )
}

create_paper_bs_plot <- function(results, ...) create_paper_metric_plot(results, "BS", ...)
create_paper_auc_plot <- function(results, ...) create_paper_metric_plot(results, "AUC", ...)
create_paper_f1_plot <- function(results, ...) create_paper_metric_plot(results, "F1", ...)
create_paper_time_plot <- function(results, ...) create_paper_metric_plot(results, "TIME", ...)
# Plot estimated total runtime, including shared base-model training.
create_paper_time_fuse_plot <- function(results, ...) create_paper_metric_plot(results, "TIME_FUSE", ...)

# Load once; export an effects figure and a separate null figure per metric.
create_paper_figures <- function(complete,
                                 missing,
                                 image_dir,
                                # Export both time metrics by default.
                                metrics = c("BS", "AUC", "F1", "TIME", "TIME_FUSE"),
                                ...) {
  results <- rbind(complete, missing)
  figures <- stats::setNames(vector("list", length(metrics)), metrics)
  for (metric in metrics) {
    figures[[metric]] <- list()
    for (subset in c("effects", "null")) {
      message("Creating figure: ", metric, " / ", subset)
      
      #name of pdf
      stem <- paste0(tolower(metric),
                     "_", subset,
                     "_all")
      
      figures[[metric]][[subset]] <- create_paper_metric_plot(results, metric,
        scenario_set = subset, file = file.path(image_dir, paste0(stem, ".pdf")), ...)
      ggplot2::ggsave(file.path(image_dir, paste0(stem, ".png")),
        figures[[metric]][[subset]]$plot,
        width = if (is.null(list(...)$width)) 20 else list(...)$width,
        height = if (is.null(list(...)$height)) 11 else list(...)$height,
        units = "in", dpi = 150)
    }
  }
  figures
}
