trace_plot_probs <- function(trace,
                             variables,
                             output = NULL,
                             colors = NULL,
                             bayes = TRUE,
                             strength_lines = FALSE) {
  
  ## ---- checks --------------------------------------------------------------
  if (!is.character(variables) || length(variables) != 1) {
    stop("`variables` must be a single variable name present in the trace.")
  }
  
  ## ---- load required packages ---------------------------------------------
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
  
  if (!variables %in% names(tr[[1]])) {
    stop(paste("Variable", variables, "not found in trace."))
  }
  
  ## ---- extract variable ---------------------------------------------------
  vals <- tr[[1]][[variables]]
  
  if (!is.numeric(vals) || any(vals %% 1 != 0)) {
    stop("`variables` must contain integer-valued categories.")
  }
  
  ## ---- posterior probabilities -------------------------------------------
  prob_df <- as.data.frame(table(vals), stringsAsFactors = FALSE)
  names(prob_df) <- c("category", "count")
  
  prob_df$category <- as.integer(prob_df$category)
  prob_df$probability <- prob_df$count / sum(prob_df$count)
  
  prob_df <- prob_df |>
    dplyr::arrange(category)
  
  prob_df <- prob_df |>
    dplyr::mutate(
      prob_label = sprintf("%.3f", probability)
    )
  
  n_cat <- nrow(prob_df)
  
  ## ---- color handling -----------------------------------------------------
  if (length(colors) == 1) {
    fill_cols <- rep(colors, n_cat)
    
  } else if (!is.null(colors) && length(colors) == n_cat) {
    fill_cols <- colors
    
  } else if (is.null(colors)) {
    
    if (n_cat <= 12) {
      fill_cols <- RColorBrewer::brewer.pal(n_cat, "Paired")
    } else {
      fill_cols <- viridis::turbo(n_cat)
    }
    
  } else {
    stop("`colors` must have length 1 or match the number of categories.")
  }
  
  names(fill_cols) <- prob_df$category
  
  ## ---- Bayes factors ------------------------------------------------------
  bf_table <- NULL
  bf_annot <- NULL
  
  if (bayes) {
    
    bf_table <- expand.grid(
      cat1 = prob_df$category,
      cat2 = prob_df$category,
      stringsAsFactors = FALSE
    ) |>
      dplyr::filter(cat1 < cat2) |>
      dplyr::left_join(prob_df, by = c("cat1" = "category")) |>
      dplyr::rename(p1 = probability) |>
      dplyr::left_join(prob_df, by = c("cat2" = "category")) |>
      dplyr::rename(p2 = probability) |>
      dplyr::mutate(
        BF = pmax(p1, p2) / pmin(p1, p2)
      )
    
    ## annotation positions
    y_base <- max(prob_df$probability)
    y_step <- y_base * 0.08  # vertical spacing between comparisons
    
    bf_annot <- bf_table |>
      dplyr::arrange(cat1, cat2) |>
      dplyr::mutate(
        idx = dplyr::row_number(),
        x1 = as.factor(cat1),
        x2 = as.factor(cat2),
        y  = y_base + idx * y_step,
        label = paste0("BF = ", round(BF, 2))
      )
    
  }
  
  ## ---- plotting -----------------------------------------------------------
  p <- ggplot2::ggplot(
    prob_df,
    ggplot2::aes(
      x = factor(category, levels = category),
      y = probability,
      fill = factor(category)
    )
  ) +
    ggplot2::geom_col(
      color = "black",
      alpha = 0.7,
      width = 0.7
    ) +
    ggplot2::geom_text(
      ggplot2::aes(
        label = prob_label
      ),
      color = "black",
      size = 3.5,
      vjust = -0.5
    ) +
    ggplot2::scale_fill_manual(values = fill_cols) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position = "none"
    ) +
    ggplot2::labs(
      x = "Model",
      y = "Posterior probability"
    ) 
  
  ## ---- add BF annotations -------------------------------------------------
  if (bayes) {
    
    p <- p +
      ggplot2::geom_segment(
        data = bf_annot,
        ggplot2::aes(x = x1, xend = x2, y = y, yend = y),
        inherit.aes = FALSE
      ) +
      ggplot2::geom_text(
        data = bf_annot,
        ggplot2::aes(x = (as.numeric(x1) + as.numeric(x2)) / 2,
                     y = y * 1.02,
                     label = label),
        size = 3,
        inherit.aes = FALSE
      ) + 
      ggplot2::expand_limits(y = max(bf_annot$y) * 1.05)
  }
  
  
  ## ---- add strength of support annotations -------------------------------------------------
  if (strength_lines) {
    
    BF_vals <- c(3.2, 10, 100)
    prior   <- 1 / n_cat
    strength <- BF_vals / (BF_vals + (n_cat - 1))
    
    y_lines <- c(prior, strength)
    labels  <- c("no support", "weak", "substantial", "strong")
    
    p <- p +
      ggplot2::geom_hline(
        yintercept = prior,
        linetype = "solid",
        color = "grey"
      ) +
      ggplot2::geom_hline(
        yintercept = strength,
        linetype = c("dotted", "dashed", "longdash"),
        color = "grey"
      ) +
      ggplot2::annotate(
        "text",
        x = Inf,
        y = y_lines,
        label = labels,
        hjust = 1.05,
        vjust = 0.8,
        size = 3,
        color = "grey40"
      )
  }
  
  ## ---- output -------------------------------------------------------------
  if (!is.null(output)) {
    
    ggplot2::ggsave(paste0(output, ".pdf"), p, width = 7, height = 5)
    
    if (bayes) {
      utils::write.csv(
        bf_table |>
          dplyr::select(cat1, cat2, BF),
        paste0(output, "_BF.csv"),
        row.names = FALSE
      )
    }
    print(paste("Output saved to file at", output))
    invisible(list(plot = p, BF = bf_table))
    
  } else {
    
    if (bayes) {
      return(list(plot = p, BF = bf_table))
    } else {
      return(p)
    }
  }
}
