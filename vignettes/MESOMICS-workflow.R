## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>",
  message = TRUE, warning = TRUE,
  eval = FALSE
)
knitr::opts_knit$set(progress = TRUE, verbose = TRUE)

## -----------------------------------------------------------------------------
# mofa_dir <- system.file("extdata", package = "MESOMICS")
# meso_csv <- system.file("extdata", "MESOMICS_latent_factors.csv", package = "MESOMICS")
# test_csv <- system.file("extdata", "test-normalised-gene_count.csv", package = "MESOMICS")
# meso_gc <- system.file("extdata", "Mesomics-normalised-gene_count.csv", package = "MESOMICS")
# 
# stopifnot(meso_csv != "", test_csv != "")
# 
# 
# out_dir <- file.path('.', "output")
# dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
# out_dir
# 
# Sys.setenv(MESOMICS_PYTHON = "/path/to/your/env/python")
# python_path <- Sys.getenv("MESOMICS_PYTHON", unset = NA)
# 
# 

## -----------------------------------------------------------------------------
# print('Starting Step 1')
# MESOMICS::add_sample_to_mofa(
#   test_matrix_path = test_csv,
#   mofa_dir         = mofa_dir,
#   value_data_types = "D_exprB_MOFA",
#   outdir           = out_dir,
#   python_bin       = python_path
# )

## -----------------------------------------------------------------------------
# print('Starting Step 2')
# MESOMICS::run_mofa(
#   inputs_dir       = out_dir,   # <— where Step 1 wrote .RData
#   outdir           = out_dir,  # <— where to write MOFA-<sample>.hdf5
#   python_bin       = python_path
# )

## -----------------------------------------------------------------------------
# print('Starting Step 3')
# MESOMICS::plot_test_samples(
#   models_dir   = out_dir,
#   MESOMICS.LFs = meso_csv,
#   python_bin   = python_path
# )
# 

## -----------------------------------------------------------------------------
# MESOMICS::run_1to3(
#   test_matrix_path = test_csv,
#   mofa_dir         = mofa_dir,
#   inputs_dir       = out_dir,
#   models_dir       = out_dir,
#   mesomics_csv     = meso_csv,
#   python_bin       = python_path
# )

## -----------------------------------------------------------------------------
# MESOMICS::collect_testsamples_factors(models_dir   = out_dir)

## -----------------------------------------------------------------------------
# MESOMICS::plot_batch_effects(meso_matrix_path = meso_gc,
#                              test_matrix_path = test_csv,
#                              python_bin = python_path)
# 

## -----------------------------------------------------------------------------
# MESOMICS::plot_factor_violins(meso_factors_path = meso_csv,
#                               test_factors_path = '/output/of/collect_testsamples_factors',
#                               python_bin   = python_path)

