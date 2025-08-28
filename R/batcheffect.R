#' Plot Batch Effects Using Density of Pairwise Distances
#'
#' This function loads MESOMICS and test matrices,
#' computes pairwise Euclidean distances within each batch and between batches, and
#' plots their density distributions to detect potential batch effects. A rightward
#' shift in the inter-batch density suggests a batch effect.
#'
#' @param meso_matrix_path Path to the MESOMICS expression matrix CSV (rows = genes, columns = samples).
#' @param test_matrix_path Path to the test expression matrix CSV (same format as MESOMICS).
#' @param out_pdf Optional path to save the plot as PDF; if NULL, displays in R device.
#' @param python_bin Python environment
#'
#' @return Invisible NULL; produces a plot.
#' @export

plot_batch_effects <- function(meso_matrix_path, test_matrix_path, out_pdf = NULL) {

  reticulate::use_python(python_bin, required = TRUE)

  # Load matrices (rows = genes, columns = samples, assume row names in first column)
  meso <- read.csv(meso_matrix_path, row.names = 1, check.names = FALSE)
  test <- read.csv(test_matrix_path, row.names = 1, check.names = FALSE)

  # Ensure same genes (rows)
  if (!identical(rownames(meso), rownames(test))) {
    stop("MESOMICS and test matrices must have identical rows (genes).")
  }

  # Transpose so rows = samples, columns = genes
  meso <- t(meso)
  test <- t(test)

  # Sample counts (now rows after transpose)
  n_meso <- nrow(meso)
  n_test <- nrow(test)
  if (n_meso < 2 || n_test < 2) {
    stop("Each matrix needs at least 2 samples for intra-batch distances.")
  }

  # Combine for full distance matrix
  combined <- rbind(meso, test)
  d <- dist(combined, method = "euclidean")
  dm <- as.matrix(d)

  # Extract intra-MESOMICS distances (lower triangle, excluding diagonal)
  intra_meso <- dm[1:n_meso, 1:n_meso][lower.tri(dm[1:n_meso, 1:n_meso])]

  # Extract intra-test distances
  intra_test <- dm[(n_meso + 1):(n_meso + n_test), (n_meso + 1):(n_meso + n_test)][lower.tri(dm[(n_meso + 1):(n_meso + n_test), (n_meso + 1):(n_meso + n_test)])]

  # Extract inter-batch distances (full rectangle)
  inter <- as.vector(dm[1:n_meso, (n_meso + 1):(n_meso + n_test)])

  # Compute density
  dens_meso <- density(intra_meso)
  dens_test <- density(intra_test)
  dens_inter <- density(inter)

  # Plot setup
  if (!is.null(out_pdf)) {
    pdf(out_pdf)
  }

  # Find plot limits
  xlim <- range(c(dens_meso$x, dens_test$x, dens_inter$x))
  ylim <- range(c(dens_meso$y, dens_test$y, dens_inter$y))

  # Plot densities
  plot(dens_meso, main = "Density of Pairwise Distances (Batch Effects Check)",
       xlab = "Euclidean Distance", ylab = "Density", xlim = xlim, ylim = ylim,
       col = "blue", lwd = 2)
  lines(dens_test, col = "green", lwd = 2)
  lines(dens_inter, col = "red", lwd = 2)
  legend("topright", legend = c("Intra-MESOMICS", "Intra-Test", "Inter-Batch"),
         col = c("blue", "green", "red"), lwd = 2)

  if (!is.null(out_pdf)) {
    dev.off()
  }

  invisible(NULL)
}
