trace_violin <- function(trace,
                         variables,
                         match = c("partial", "total"),
                         output = NULL,
                         colors = NULL) {
  
  ## ---- checks --------------------------------------------------------------
  match <- match.arg(match)
  
  if (!is.character(variables) || length(variables) < 1) {
    stop("`variables` must be a character vector with at least one entry.")
  }
  
  ## ---- load required packages ----------------------------------------------
  if (!requireNamespace("RevGadgets", quietly = TRUE))
    stop("Package 'RevGadgets' is required.")
  
  if (!requireNamespace("ggplot2", quietly = TRUE))
    stop("Package 'ggplot2' is required.")
  
  if (!requireNamespace("dplyr", quietly = TRUE))
    stop("Package 'dplyr' is required.")
  
  if (!requireNamespace("RColorBrewer", quietly = TRUE))
    stop("Package 'RColorBrewer' is required.")
  
  if (!requireNamespace("viridis", quietly = TRUE))
    stop("Package 'viridis' is required.")
  
  ## ---- read trace if needed ------------------------------------------------
  if (is.character(trace)) {
    tr <- RevGadgets::readTrace(trace)
  } else if (is.list(trace)) {
    tr <- trace
  } else {
    stop("`trace` must be a file path or an object created by readTrace().")
  }
  
  ## ---- collect all variable names ------------------------------------------
  var_names <- names(tr[[1]])
  
  if (match == "total") {
    
    matched_vars <- variables[variables %in% var_names]
    
  } else {
    
    matched_vars <- unlist(
      lapply(variables, function(v)
        var_names[grepl(v, var_names)])
    )
    
    matched_vars <- unique(matched_vars)
  }
  
  if (length(matched_vars) == 0) {
    stop("No variables matched the provided `variables` argument.")
  }
  
  ## ---- extract samples -----------------------------------------------------
  df <- lapply(matched_vars, function(v) {
    data.frame(
      variable = v,
      value = tr[[1]][[v]]
    )
  }) |> dplyr::bind_rows()
  
  df$variable <- factor(df$variable, levels = matched_vars)
  
  ## ---- compute 95% HPD -----------------------------------------------------
  hpd_df <- df |>
    dplyr::group_by(variable) |>
    dplyr::summarise(
      lower = quantile(value, 0.025),
      upper = quantile(value, 0.975),
      mean  = mean(value),
      median = median(value),
      .groups = "drop"
    )
  
  df <- df |>
    dplyr::left_join(hpd_df, by = "variable") |>
    dplyr::mutate(
      inside_hpd = value >= lower & value <= upper
    )
  
  ## ---- color handling ------------------------------------------------------
  n_var <- length(matched_vars)
  
  if (length(colors) == 1) {
    fill_cols <- rep(colors, n_var)
    
  } else if (length(colors) == n_var) {
    fill_cols <- colors
    
  } else if (missing(colors)) {
    
    if (n_var <= 12) {
      fill_cols <- RColorBrewer::brewer.pal(n_var, "Paired")
    } else {
      fill_cols <- viridis::turbo(n_var)
    }
    
  } else {
    stop("`colors` must have length 1 or match the number of matched variables.")
  }
  
  names(fill_cols) <- matched_vars
  
  ## ---- Legend ------------------------------------------------------------
  hpd_long <- dplyr::bind_rows(
    hpd_df |> dplyr::mutate(stat = "Mean",   y = mean),
    hpd_df |> dplyr::mutate(stat = "Median", y = median)
  )
  
  hpd_df$variable   <- factor(hpd_df$variable, levels = matched_vars)
  hpd_long$variable <- factor(hpd_long$variable, levels = matched_vars)
  
  ## ---- plotting ------------------------------------------------------------
  p <- ggplot2::ggplot(df |> dplyr::filter(inside_hpd),
                       ggplot2::aes(x = variable, y = value, fill = variable)) +
    
    ggplot2::geom_violin(
      color = "black",
      alpha = 0.6,
      trim = FALSE
    ) +
    
    ggplot2::geom_point(
      data = hpd_long,
      ggplot2::aes(x = variable, y = y, shape = stat),
      size = 3,
      color = "black",
      inherit.aes = FALSE
    ) +
    
    ggplot2::scale_fill_manual(values = fill_cols) +
    
    ggplot2::scale_shape_manual(
      name = NULL,
      values = c(
        Mean = 8,    # *
        Median = 15 # square
      )
    ) +
    ggplot2::guides(
      fill  = "none",
      color = "none"
    ) +
    
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "right",
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    ) +
    ggplot2::labs(x = NULL, y = "Value")
  
  ## ---- output --------------------------------------------------------------
  if (!is.null(output)) {
    ggplot2::ggsave(paste0(output, ".pdf"), p, width = 8, height = 5)
    ggplot2::ggsave(paste0(output, ".png"), p, width = 8, height = 5, dpi = 300)
    invisible(p)
  } else {
    return(p)
  }
}
