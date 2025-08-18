#' Step 1: Add a test sample to MOFA input matrices
#'
#' Reads one or more input test CSVs (first column = gene IDs)
#' and appends the test sample to selected MOFA input objects, saving updated .RData files.
#'
#' @name add_sample_to_mofa
#' @param test_matrix_path Character vector of CSV paths; each must have first col as gene IDs
#' @param mofa_dir Directory containing MOFA .RData input files (objects with rownames = gene IDs)
#' @param value_data_types Character vector of MOFA object names to update; same length as `test_matrix_path`
#' @param outdir Directory to save updated .RData files
#' @param python_bin Python environment
#' @return Saves updated matrices as RData files in 'outdir' (one file per MOFA object per sample)
#' @export
add_sample_to_mofa <- function(test_matrix_path,
                               mofa_dir = system.file("extdata", package = "MESOMICS"),
                               value_data_types = c("D_exprB_MOFA"),
                               outdir = "output/",
                               python_bin) {

  if (!requireNamespace("reticulate", quietly = TRUE)) stop("Package 'reticulate' is required.")
  reticulate::use_python(python_bin, required = TRUE)


  # ---- Setup & input checks ----------------------------------------------------
  test_matrix_path <- as.character(test_matrix_path)
  value_data_types <- as.character(value_data_types)

  # Ensure output dir exists
  if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

  # 1) Lengths must match: each file pairs with exactly one MOFA object by index
  if (length(test_matrix_path) != length(value_data_types)) {
    stop(
      "Input data mismatch: found ", length(test_matrix_path), " test_matrix_path item(s) but ",
      length(value_data_types), " value_data_types. ",
      "Each test matrix path must align by index with a data type."
    )
  }

  # ---- Load all MOFA .RData objects into a named list -------------------------
  mofa_inputs <- list()
  rdata_files <- list.files(mofa_dir, pattern = "\\.RData$", full.names = TRUE)
  for (f in rdata_files) {
    obj_names <- load(f)
    for (nm in obj_names) {
      # Keep as data.frame for simplicity; preserve colnames as-is
      obj <- get(nm)
      mofa_inputs[[nm]] <- as.data.frame(obj, check.names = FALSE)
    }
  }

  # Announce pairing: file i -> data_type i
  cat("✓ Pairing (test_matrix_path -> data_type):\n")
  for (i in seq_along(test_matrix_path)) {
    cat("  - [", i, "] ", basename(test_matrix_path[i]), " -> ", value_data_types[i], "\n", sep = "")
  }

  # ---- Main loop: process each (file, data_type) pair -------------------------
  for (i in seq_along(test_matrix_path)) {
    tm_path     <- test_matrix_path[i]
    paired_type <- value_data_types[i]

    if (!file.exists(tm_path)) stop("Test matrix file does not exist: ", tm_path)

    # Load this test matrix; first column must be gene IDs
    test_matrix <- read.csv(tm_path, check.names = FALSE, stringsAsFactors = FALSE)
    if (ncol(test_matrix) < 2) {
      stop("Test matrix '", tm_path, "' must have 'gene_id' + at least one sample column.")
    }
    colnames(test_matrix)[1] <- "gene_id"
    if (!("gene_id" %in% colnames(test_matrix))) {
      stop("Test matrix '", tm_path, "' must contain a 'gene_id' column as the first column.")
    }

    # Identify sample columns (everything except 'gene_id')
    sample_names <- setdiff(names(test_matrix), "gene_id")

    cat("→ Processing file #", i, ": ", basename(tm_path),
        " (", length(sample_names), " sample(s)) against data_type '",
        paired_type, "'\n", sep = "")

    # For each sample column in this matrix
    for (sample_name in sample_names) {
      sample_column <- test_matrix[, c("gene_id", sample_name)]

      # Iterate all loaded MOFA objects:
      # - If it's the paired data type, add real values from this sample
      # - Otherwise, add NA column (keeps original behavior)
      for (data_type in names(mofa_inputs)) {
        mat <- as.data.frame(mofa_inputs[[data_type]], check.names = FALSE)

        if (identical(data_type, paired_type)) {
          # Ensure the MOFA matrix has gene ID rownames to align with
          if (is.null(rownames(mat))) {
            stop("MOFA object '", data_type, "' has no rownames to match against 'gene_id'.")
          }

          # Map test rows to MOFA row order; unmatched become NA
          idx <- match(rownames(mat), sample_column$gene_id)
          matched   <- !is.na(idx)
          n_total   <- nrow(mat)
          n_match   <- sum(matched)
          n_missing <- n_total - n_match

          # Friendly message: whether incoming order already matches MOFA's
          order_ok <- n_missing == 0 && all(sample_column$gene_id[idx] == rownames(mat))
          if (order_ok) {
            cat("• [", data_type, " | ", sample_name, "] gene order OK (",
                n_match, "/", n_total, " matched)\n", sep = "")
          } else {
            cat("• [", data_type, " | ", sample_name, "] reordered to MOFA row order; ",
                n_missing, " genes missing in test (filled NA)\n", sep = "")
          }

          # Insert values in MOFA row order
          mat[[sample_name]] <- sample_column[idx, sample_name]
        } else {
          # Not the paired type for this file -> follow original behavior: add NA column
          mat[[sample_name]] <- NA_real_
        }

        # Save updated object: one file per (data_type, sample)
        obj_to_save <- data_type
        assign(obj_to_save, mat)
        if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)
        save(list = obj_to_save,
             file = file.path(outdir, paste0(data_type, "_", sample_name, ".RData")))
        cat(paste0("✓ Saved: ", data_type, "_", sample_name, ".RData\n"))
      }

      cat("✅ All matrices processed for sample: ", sample_name,
          " (file #", i, " paired with ", paired_type, ")\n", sep = "")
    }
  }
}



