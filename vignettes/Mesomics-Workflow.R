## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>",
  message = TRUE, warning = TRUE,
  eval = TRUE,
  fig.width=12, fig.height=8, fig.align='center'
)
knitr::opts_knit$set(progress = TRUE, verbose = TRUE)

## -----------------------------------------------------------------------------
mofa_dir <- system.file("extdata", package = "MESOMICS")
meso_csv <- system.file("extdata", "MESOMICS_latent_factors.csv", package = "MESOMICS")
test_csv <- system.file("extdata", "test-normalised-gene_count.csv", package = "MESOMICS")
meso_gc <- system.file("extdata", "Mesomics-normalised-gene_count.csv", package = "MESOMICS")

stopifnot(meso_csv != "", test_csv != "")


out_dir <- file.path('.', "output")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
out_dir

Sys.setenv(MESOMICS_PYTHON = "/home/lipikal/miniconda3/envs/mofa_env/bin/python") #replace this with your 'which python' output
python_path <- Sys.getenv("MESOMICS_PYTHON", unset = NA)



## -----------------------------------------------------------------------------
print('Starting Step 1')
MESOMICS::add_sample_to_mofa(
  test_matrix_path = test_csv,
  mofa_dir         = mofa_dir,
  value_data_types = "D_exprB_MOFA",
  outdir           = out_dir, 
  python_bin       = python_path
)

## -----------------------------------------------------------------------------
print('Starting Step 2')
MESOMICS::run_mofa(
  inputs_dir       = out_dir,   # <— where Step 1 wrote .RData
  outdir           = out_dir,  # <— where to write MOFA-<sample>.hdf5
  python_bin       = python_path
)

## -----------------------------------------------------------------------------
print('Starting Step 3')
MESOMICS::plot_test_samples(
  models_dir   = out_dir,     
  MESOMICS.LFs = meso_csv,
  python_bin   = python_path
)


## -----------------------------------------------------------------------------
MESOMICS::run_1to3(
  test_matrix_path = test_csv,
  mofa_dir         = mofa_dir,
  inputs_dir       = out_dir,
  models_dir       = out_dir,
  mesomics_csv     = meso_csv,
  python_bin       = python_path
)

## -----------------------------------------------------------------------------
test_factors_file <- file.path(out_dir, "test_samples_factors.tsv")

MESOMICS::collect_testsamples_factors(models_dir   = out_dir, 
                                      outfile   = test_factors_file
)

## ----fig.width=10, fig.height=8, out.width="100%"-----------------------------
MESOMICS::plot_batch_effects(meso_matrix_path = meso_gc, 
                             test_matrix_path = test_csv, 
                             python_bin = python_path)


## ----fig.width=10, fig.height=8, out.width="100%"-----------------------------

MESOMICS::plot_factor_violins(meso_factors_path = meso_csv, 
                             test_factors_path = test_factors_file,
                             python_bin   = python_path

)

