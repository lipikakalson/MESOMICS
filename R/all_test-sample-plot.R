#' Plot test samples across models with last-model archetypes
#'
#' Aggregates the test samples from all models into one scatter plot and overlays
#' the Pareto triangle (3 archetypes) taken from the last model processed; writes a single PDF.
#'
#' @param models_dir Directory containing *.hdf5 models. Default: "."
#' @param mesomics_csv Path to MESOMICS_latent_factors.csv
#' @param out_pdf Output file. Default: "plots/all_test_samples.pdf"
#' @param python_bin Python environment
#' @return (Invisibly) the output PDF path.
#' @export
#'
#'
plot_test_all_samples <- function(
    models_dir   = "output/",
    mesomics_csv = system.file("extdata", "MESOMICS_latent_factors.csv", package = "MESOMICS"),
    out_pdf      = "output/plots/all_test_samples.pdf",
    python_bin
) {
  if (!requireNamespace("reticulate", quietly = TRUE)) stop("Package 'reticulate' is required.")
  reticulate::use_python(python_bin, required = TRUE)

  # List all .hdf5 files
  model_files <- list.files(models_dir, pattern = "\\.hdf5$", full.names = TRUE)

  # Load MESOMICS latent factors
  MESOMICS.LFs <- utils::read.csv(mesomics_csv)

  # Collect test samples
  test_samples_df <- data.frame(
    Morphological.factor = numeric(),
    Immune.response.factor = numeric()
  )

  last_archetypes <- NULL
  arc <- NULL  # keep same variable name you use later

  for (i in seq_along(model_files)) {

    # Load the MOFA model
    MOFAmodel <- MOFA2::load_model(model_files[i])

    # LFs from group1 (same as your script)
    MOFA.LFs <- as.data.frame(MOFAmodel@expectations$Z$group1)

    # Correlate and pick most correlated factors
    cor.tmp <- stats::cor(MOFA.LFs[1:120, ], MESOMICS.LFs[, 4:5])
    LFs.tmp <- apply(abs(cor.tmp), 2, which.max)
    LFs.tmp2 <- tibble::as_tibble(MOFA.LFs[, LFs.tmp])

    # Sign flip
    if (cor.tmp[LFs.tmp[1], 1] < 0) LFs.tmp2[, 1] <- -LFs.tmp2[, 1]
    if (cor.tmp[LFs.tmp[2], 2] < 0) LFs.tmp2[, 2] <- -LFs.tmp2[, 2]

    colnames(LFs.tmp2) <- c("Morphological.factor", "Immune.response.factor")

    # Archetype analysis
    arc_ks.LFs.noboot <- ParetoTI::k_fit_pch(
      t(LFs.tmp2), ks = 3, check_installed = TRUE, bootstrap = FALSE, volume_ratio = "t_ratio"
    )

    # Archetype positions
    arc <- as.data.frame(arc_ks.LFs.noboot$XC)
    colnames(arc) <- c("Arc1", "Arc2", "Arc3")

    # Keep last iteration archetypes
    if (i == length(model_files)) last_archetypes <- arc

    # Row 121 test sample
    test_sample <- LFs.tmp2[121, ]
    test_samples_df <- rbind(test_samples_df, test_sample)
  }


  # Final plot (same layers)
  final_plot <- ggplot2::ggplot(test_samples_df,
                                ggplot2::aes(x = Morphological.factor, y = Immune.response.factor)) +
    ggplot2::geom_point(cex = 3, color = "black") +
    ggplot2::geom_segment(
      data = tibble::as_tibble(t(last_archetypes)),
      ggplot2::aes(x = unlist(last_archetypes[1,]), xend = unlist(last_archetypes[1, c(2, 3, 1)]),
                   y = unlist(last_archetypes[2,]), yend = unlist(last_archetypes[2, c(2, 3, 1)])),
      col = "lightblue", linewidth = 2
    ) +
    ggplot2::geom_point(
      data = tibble::as_tibble(t(last_archetypes)),
      col = scales::alpha(c("#B81330", "#58839D", "#79A960"), 0.7),
      cex = 5
    ) +
    ggplot2::geom_text(
      data = tibble::as_tibble(t(arc)),
      label = 1:3, col = "black", cex = 4
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "none")

  # Ensure output dir exists
  dir.create(dirname(out_pdf), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(out_pdf, plot = final_plot, width = 8, height = 6)

  invisible(out_pdf)
}
