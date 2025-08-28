#' Plot Violin Distributions of Latent Factors
#'
#' This function loads latent factors from MESOMICS and test samples,  aligns their names, and creates violin plots for each factor to
#' compare their distributions. This helps detect if test samples' factor values are far outside
#' the range of MESOMICS samples, indicating potential batch effects, outliers, or biological
#' differences.
#'
#' @param meso_factors_path Path to the MESOMICS latent factors CSV (samples as rows, factors as columns).
#' @param test_factors_path Path to the test latent factors CSV/TSV (same number of factors as MESOMICS).
#' @param out_pdf Optional path to save the plot as PDF; if NULL, displays in R device.
#' @param python_bin Python environment.
#'
#' @return Invisible NULL; produces a plot.
#' @export

plot_factor_violins <- function(meso_factors_path, test_factors_path, out_pdf = NULL) {
  reticulate::use_python(python_bin, required = TRUE)

  meso <- read.csv(meso_factors_path, row.names = 1, check.names = FALSE)
  test <- read.csv(test_factors_path, row.names = 11, check.names = FALSE, sep = "\t")

  # Select factor columns (exclude Cohort for MESOMICS, Run for test)
  meso_factor_cols <- colnames(meso)[!colnames(meso) %in% c("Cohort", "Sample")]
  test_factor_cols <- colnames(test)[!colnames(test) %in% "Run"]

  print(test_factor_cols)
  print(meso_factor_cols)

  # Subset to factor columns
  meso <- meso[, meso_factor_cols, drop = FALSE]
  test <- test[, test_factor_cols, drop = FALSE]

  # Check number of factors
  n_meso <- length(meso_factor_cols)
  n_test <- length(test_factor_cols)

  if (n_meso != n_test) {
    warning(sprintf("MESOMICS has %d factors, test has %d. Using the first %d factors.",
                    n_meso, n_test, min(n_meso, n_test)))
    n_factors <- min(n_meso, n_test)
    meso_factor_cols <- meso_factor_cols[1:n_factors]
    test_factor_cols <- test_factor_cols[1:n_factors]
    meso <- meso[, meso_factor_cols, drop = FALSE]
    test <- test[, test_factor_cols, drop = FALSE]
  } else {
    n_factors <- n_meso
  }

  # Check for valid factors
  if (n_factors == 0) {
    stop("No valid factor columns found in one or both files.")
  }

  # Rename columns to Factor1, Factor2, ..., FactorN
  colnames(meso) <- paste0("Factor", seq_len(n_factors))
  colnames(test) <- paste0("Factor", seq_len(n_factors))

  # Add group column for plotting
  meso$Group <- "MESOMICS"
  test$Group <- "Test"

  # Combine data frames
  combined <- rbind(meso, test)

  # Reshape for ggplot (long format)
  melted <- reshape2::melt(combined, id.vars = "Group", variable.name = "Factor", value.name = "Value")

  # Create the plot
  library(ggplot2)
  p <- ggplot(melted, aes(x = Group, y = Value, fill = Group)) +
    geom_violin(trim = FALSE) +
    geom_jitter(aes(color = Group), width = 0.15, alpha = 0.6, size = 0.8) +
    geom_boxplot(width = 0.1, fill = "white") +
    facet_wrap(~ Factor, scales = "free_y") +
    theme_minimal() +
    labs(title = "Violin Plots of Latent Factors (MESOMICS vs. Test)",
         x = "Group", y = "Factor Value") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  # Save to PDF or display
  if (!is.null(out_pdf)) {
    ggsave(out_pdf, p, width = 12, height = 8)
  } else {
    print(p)
  }

  invisible(NULL)
}
