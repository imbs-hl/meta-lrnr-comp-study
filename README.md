# Comparison of meta-learners for late integration in multi-omics prediction under complete data and modality-wise missingness

This repository contains the code for the simulation study and the TCGA use case
presented in the paper *Comparison of meta-learners for late integration in multi-omics prediction under complete data and modality-wise missingness*. The two studies can be run independently.

## Simulation study

To reproduce the simulation study results, move to `simulation-study/R-code`.

### 1. Configuration

In `init-global.R`, set the code and output paths, R library, and batchtools
configuration. Install the required packages listed in the file.

### 2. Data generation and preparation

The scripts in `01-preparation` prepare the empirical parameters for InterSIM
using TCGA breast cancer data.

1. Download the two proteomics files listed in `01-preparation/01-protein.R`.
2. Run `01-protein.R` to prepare the protein data.
3. Run `02-load-tcga-data.R` to prepare the empirical parameters used
   for simulation.

### 3. Simulation.

The scripts in `02-simulation` cover two data settings with the same folder
structure:

- `01-complete`: all three modalities are available.
- `02-missing`: modality-wise missing data.

Each setting contains three effect-scenario folders:

| Folder | Modalities with effects | Scenarios |
|---|---|---|
| `01-methyl` | Methylation only, plus the null scenario | N/N/N, L/N/N, M/N/N |
| `02-methyl-genexpr` | Methylation and gene expression | L/L/N, L/M/N, M/M/N |
| `03-methyl-genexpr-proexpr` | Methylation, gene expression, and protein abundance | L/L/L, L/L/M, L/M/M, M/M/M |

Scenario labels refer to methylation, gene expression, and protein abundance,
respectively: N = no effect, L = low effect, and M = moderate effect.

In each scenario folder, run the scripts in this order:

1. **`01-...-data.R`**: generate the simulated datasets. Wait for the jobs
   to finish.
2. **`02-...-train-best.R`**: train the modality-specific models and the Best
   meta-learner. Wait for its jobs to finish before starting the other
   fuseMLR meta-learners.
3. **Other `02-...-train-*.R` and `02-ref-...-train-*.R` scripts**: train
   the remaining meta-learners and reference methods.
4. **`03-...-perform-*.R` scripts**: calculate performance after the
   corresponding training jobs have finished.


After all required performance jobs have finished, set the paths in
`02-simulation/paper-figures.R` and run it from `02-simulation` to create
the figures.

## TCGA use case

To reproduce the TCGA use case results, move to `tcga-use-case-study/scripts`.

### 1. Configuration

In `../init.R`, set the data and output paths, R library, and batchtools configuration.
Install the required packages listed in the file.

### 2. Data preparation

1. **`01_01_prepare_mae.R`**: download and prepare the TCGA
   MultiAssayExperiment objects and identify candidate binary outcomes.
2. **`01_02_prepare_data.R`**: prepare the RNA, miRNA, and RPPA data for
   classification and save the dataset list.
3. **`02_01_create_cv.R`**: create shared cross-validation folds for the
   modalities.
4. **`02_02_create_cv_cc.R`**: prepare complete-case data for BlockForest
   and SRF.
5. **`02_03_create_cv_miss.R`**: prepare data with missing modalities
   for DIABLO, PriorityLasso-miss, and SRF-miss.

### 3. Model training

1. **`03_01_train_rf.R`**: train the modality-specific models and the random
   forest meta-learner. Wait for its jobs to finish before starting the other
   fuseMLR meta-learners.
2. **`03_02`–`03_06`**: train the remaining meta-learners.
3. **`04_01`–`04_04`**: train the reference methods.

### 4. Results and figures

1. After the training jobs finish, run **`04_05_collect_results.R`**.
2. Run **`05_01_create_performance.R`** to calculate prediction performance.
3. Run **`05_02_create_paper_plot.R`** to create the figure.
