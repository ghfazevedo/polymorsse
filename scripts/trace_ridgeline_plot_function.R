trace_ridgeline <- function(trace,
                            variables,
                            match = c("partial", "total"),
                            output = NULL,
                            colors = NULL,
                            overlap = TRUE) {
  
  ## ---- checks --------------------------------------------------------------
  match <- match.arg(match)
  
  if (!is.logical(overlap) || length(overlap) != 1) {
    stop("`overlap` must be TRUE or FALSE.")
  }
  
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
  
  if (!requireNamespace("ggridges", quietly = TRUE))
    stop("Package 'ggridges' is required.")
  
  ## ---- read trace if needed ------------------------------------------------
  if (is.character(trace)) {
    tr <- RevGadgets::readTrace(trace)
  } else if (is.list(trace)) {
    tr <- trace
  } else {
    stop("`trace` must be a file path or an object created by readTrace().")
  }
  
  ## ---- collect variable names ----------------------------------------------
  var_names <- names(tr[[1]])
  
  if (match == "total") {
    matched_vars <- variables[variables %in% var_names]
  } else {
    matched_vars <- unique(unlist(
      lapply(variables, function(v)
        var_names[grepl(v, var_names)])
    ))
  }
  
  if (length(matched_vars) == 0) {
    stop("No variables matched the provided `variables` argument.")
  }
  
  ## ---- extract samples -----------------------------------------------------
  df <- lapply(matched_vars, function(v) {
    data.frame(variable = v, value = tr[[1]][[v]])
  }) |> dplyr::bind_rows()
  
  df$variable <- factor(df$variable, levels = matched_vars)
  
  ## ---- compute 95% interval (for axis only) -------------------------------
  hpd_df <- df |>
    dplyr::group_by(variable) |>
    dplyr::summarise(
      lower = quantile(value, 0.025),
      upper = quantile(value, 0.975),
      .groups = "drop"
    )
  
  x_min <- min(hpd_df$lower)
  x_max <- max(hpd_df$upper)
  
  ## ---- color handling ------------------------------------------------------
  n_var <- length(matched_vars)
  
  if (!missing(colors) && length(colors) == 1) {
    fill_cols <- rep(colors, n_var)
  } else if (!missing(colors) && length(colors) == n_var) {
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
  
  ## ---- overlap control -----------------------------------------------------
  ridge_scale <- if (overlap) 1.3 else 0.9
  
  ## ---- plotting ------------------------------------------------------------
  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = value, y = variable, fill = variable)
  ) +
    
    ggridges::geom_density_ridges(
      alpha = 0.85,
      color = "black",
      scale = ridge_scale,
      rel_min_height = 0.01
    ) +
    
    ggplot2::scale_fill_manual(values = fill_cols) +
    
    ggplot2::coord_cartesian(xlim = c(x_min, x_max)) +
    
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "none"
    ) +
    
    ggplot2::labs(x = "Value", y = NULL)
  
  ## ---- output --------------------------------------------------------------
  if (!is.null(output)) {
    ggplot2::ggsave(paste0(output, ".pdf"), p, width = 8, height = 5)
    ggplot2::ggsave(paste0(output, ".png"), p, width = 8, height = 5, dpi = 300)
    invisible(p)
  } else {
    return(p)
  }
}
