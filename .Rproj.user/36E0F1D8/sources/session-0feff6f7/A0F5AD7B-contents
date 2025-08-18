#' Collect test-sample factor rows from MOFA HDF5 models.
#'
#' Loads \code{MOFA-*.hdf5} models and extracts the last row (test sample) of factors
#' for each model, binding them into a single table and saving it.
#'
#'
#' @param models_dir Directory containing MOFA-*.hdf5 from 'run_mofa'.
#' @param outfile Output TSV filename (written to models_dir).
#' @param group   Group to use (default "group1").
#' @return Invisibly returns the data.frame that was written.
#' @export
collect_testsamples_factors <- function(
    models_dir = "output/",
    outfile    = "test-samples-mofa_factors.txt",
    group      = "group1"
) {
  model_files <- list.files(models_dir, pattern = "\\.hdf5$", full.names = TRUE)
  all_factors <- data.frame()

  for (model_file in model_files) {
    mod      <- MOFA2::load_model(model_file)
    factors  <- MOFA2::get_factors(mod)[[group]]
    last_idx <- nrow(factors)
    last_row <- factors[last_idx, , drop = FALSE]

    # row-bind (keeps the sample name as rowname, like your script)
    all_factors <- rbind(all_factors, last_row)
    cat("Processed model:", basename(model_file), "\n")
  }

  # add Run from rownames (same as your script)
  all_factors$Run <- rownames(all_factors)

  utils::write.table(
    all_factors,
    file      = file.path(models_dir, outfile),
    row.names = FALSE,
    sep       = "\t",
    quote     = FALSE
  )

  invisible(all_factors)
}
