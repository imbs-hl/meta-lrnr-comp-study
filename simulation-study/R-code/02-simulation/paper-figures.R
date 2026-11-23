# Run from R-code/02-simulation
source("../functions/paper-performance-plots.R")

# Directory containing registry/, results/, and images/.
proc_dir <- "~/interconnect/scripts/meta-lrnr-comp-study-2026/simulation-study"
paper_working_dir <- "/imbs/projects/p23048/meta-lrnr-comp-study-2026"
paper_source <- "registry" # alternatively "rds" for saved performance files

# Two figures per metric: effect scenarios and N/N/N, each as PDF and PNG.
paper_metrics <- c("BS", "AUC", "F1", "TIME", "TIME_FUSE")

code_dir <- file.path(proc_dir, "R-code")

## Provide a configuration and a template file
config_file <- file.path(code_dir, "batchtools-config/batchtools.conf.R")
template <- file.path(code_dir, "batchtools-config/.batchtools.slurm.tmpl")
nodename <- "localhost"
partition <- "prio"
account <- "p23048"

scenario_folders <- c(me = "01-methyl",
                      mege = "02-methyl-genexpr",
                      megepro = "03-methyl-genexpr-proexpr")

base <- if(paper_source == "registry") "registry" else "results"

# Dirs
complete_dirs <- stats::setNames(file.path(paper_working_dir,
    base,
    "02-simulation",
    "01-complete",
    scenario_folders,
    "perf"),
  names(scenario_folders))

missing_dirs <- stats::setNames(file.path(paper_working_dir,
    base,
    "02-simulation",
    "02-missing",
    scenario_folders,
    "perf"),
  names(scenario_folders))

complete_results <- load_paper_results( perf_dirs = complete_dirs,
  type= "complete",
  source = paper_source,
  config_file = config_file)

missing_results <- load_paper_results(perf_dirs = missing_dirs,
  type = "missing",
  source = paper_source,
  config_file = config_file)

# Effects: complete above missing. Null: complete and missing side by side.
paper_figures <- create_paper_figures(
  complete = complete_results,
  missing = missing_results,
  image_dir = file.path(paper_working_dir, "images"),
  metrics = paper_metrics,
  bs_ylim = c(-0.02, 0.30), # Effects; null BS uses 0 to 0.45.
  time_log = TRUE, # seconds on a log axis; FALSE for a linear axis
  time_digits = 2,
  width = 20,
  height = 11
)
