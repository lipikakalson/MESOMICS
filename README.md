## Overview
This R package provides utilities to project new test samples onto MESOMICS latent factor space (from MOFA), and visualise their positions, and quickly check for batch effects, outliers and biological comparability.

### To install the package
```
remotes::install_github("lipikakalson/MESOMICS", build_vignettes = FALSE)
```
## Example Usage
Downlaod mofa_env.yml.

#### Step 0 : On Terminal
```
conda env create -f mofa_env.yml
conda activate mofa_env
which python
# For example: /home/user/miniconda3/envs/mofa_env/bin/python
```
#### Rstudio
#### Defining data paths
```
library(MESOMICS)

mofa_dir <- system.file("extdata", package = "MESOMICS")
meso_csv <- system.file("extdata", "MESOMICS_latent_factors.csv", package = "MESOMICS")
test_csv <- system.file("extdata", "test-normalised-gene_count.csv", package = "MESOMICS")
meso_gc <- system.file("extdata", "Mesomics-normalised-gene_count.csv", package = "MESOMICS")

stopifnot(meso_csv != "", test_csv != "")


out_dir <- file.path('.', "output")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
out_dir

Sys.setenv(MESOMICS_PYTHON = "/path/to/your/env/python") #output of 'which python'
python_path <- Sys.getenv("MESOMICS_PYTHON", unset = NA)
```

#### Step 1
This function adds test sample to MESOMICS samples, one at a time and saves the updated (MESOMICS+1test) file as .Rdata file.
```
print('Starting Step 1')

MESOMICS::add_sample_to_mofa(
  test_matrix_path = test_csv,
  mofa_dir         = mofa_dir,
  value_data_types = "D_exprB_MOFA",
  outdir           = out_dir, 
  python_bin       = python_path
)
```
#### Step 2
This function runs MOFA on updated .Rdata file generated in Step1.
```
print('Starting Step 2')

MESOMICS::run_mofa(
  inputs_dir       = out_dir,   # <— where Step 1 wrote .RData
  outdir           = out_dir,  # <— where to write MOFA-<sample>.hdf5
  python_bin       = python_path
)
```
#### Step 3
This function plots each test sample in MOFA space using the two MOFA factors most correlated with the MESOMICS Morphology and Adaptive-Immune axes, draws the 2D Pareto triangle (3 MESOMICS archetypes), and saves one PDF per model.
After processing all models, it aggregates the highlighted test-sample’s archetype weights and saves one ternary plot showing all test samples relative to the three archetypes.
```
print('Starting Step 3')

MESOMICS::plot_test_samples(
  models_dir   = out_dir,     
  MESOMICS.LFs = meso_csv,
  python_bin   = python_path
)
```
## OR

#### Pipeline wrapper for Steps 1-3
Pipeline wrapper for Step1 to Step3
```
MESOMICS::run_1to3(
  test_matrix_path = test_csv,
  mofa_dir         = mofa_dir,
  inputs_dir       = out_dir,
  models_dir       = out_dir,
  mesomics_csv     = meso_csv,
  python_bin       = python_path
)
```

### Latent factors of test samples
This functions extracts and saves the MOFA latent factors of all test samples into a single text file.
```
test_factors_file <- file.path(out_dir, "test_samples_factors.tsv")

MESOMICS::collect_testsamples_factors(models_dir   = out_dir, 
                                      outfile   = test_factors_file
)
```

### To check for Batch effect - Density curves
This function visualizes pairwise distance distributions of MESOMICS vs test samples to detect potential batch effects.
```
MESOMICS::plot_batch_effects(meso_matrix_path = meso_gc, 
                             test_matrix_path = test_csv, 
                             python_bin = python_path)

```

### MOFA Latent Factors Violin Plots
This function compares MOFA latent factor distributions between MESOMICS and test samples using violin plots.
```
MESOMICS::plot_factor_violins(meso_factors_path = meso_csv, 
                             test_factors_path = test_factors_file,
                             python_bin   = python_path

)

)
```

