# Function for plotting metaMDS objects from package vegan
# x                     metaMDS object
# dims                  which axes to be plotted
# var                   logical: whether variables are shown
# varlab                logical: whether labels should be plotted for
#                       variables
# obslab                logical: whether labels should be plotted for
#                       observations
# obscolor              char colour or vector with colours for 
#                       observations
# obssize               size of obs points or vectors with values that
#                       are used for scaling the points
# surf                  output from vegan::ordisurf or list of outputs from ordisurf
# surfcolor             color or vector of colors for the isolines derived from surf
# envfit                output from vegan::envfit for plotting vectors
# p.max                 Maximum estimated P value for displayed variables.
#                       You need to calculate P values with setting permutations
#                       to use this option
# title                 title for the plot
# color_legend_title    title for the color legend
# size_legend_title     title for the size legend
# surf_legend_labels    labels for the surf legend
# theme                 ggplot2 theme
# ...                   passed to sub-functions

autoplot.metaMDS <- function(x,
                             dims = c(1, 2),
                             var = FALSE,
                             varlab = FALSE,
                             obslab = FALSE,
                             obscolor = NULL,
                             obssize = NULL,
                             surf = NULL,
                             surfcolor = NULL,
                             envfit = NULL,
                             p.max = NULL,
                             title = NULL,
                             color_legend_title = "Groups",
                             size_legend_title = NULL,
                             surf_legend_labels = NULL,
                             theme = theme_light(),
                             ...) {
  require(vegan)
  require(ggplot2)
  require(ggrepel)

  # Observation scores
  mdsobs <- as.data.frame(vegan::scores(x, display = "sites"))[, dims]

  # Variable scores (in case NMDS was not based on a distance object)
  if ("matrix" %in% class(x$species)) {
    mdsvar <- as.data.frame(vegan::scores(x, display = "species"))[, dims]
  } else {
    var <- FALSE
    varlab <- FALSE
    mdsvar <- NULL
  }

  namx <- colnames(mdsobs)[1]
  namy <- colnames(mdsobs)[2]

  # Build a color vector
  # Function to check if all elements are valid colors
  is_valid_color <- function(col) {
    if (is.numeric(col)) {
      return(FALSE)
    }
    tryCatch({
      grDevices::col2rgb(col)
      TRUE
    }, error = function(e) {
      FALSE
    })
  }
  
  # Add color to mdsobj
  if (is.null(obscolor)) {
    mdsobs$obscolor <- "#333333"
  } else if (is_valid_color(obscolor)) {
    mdsobs$obscolor <- obscolor
  } else { 
    mdsobs$obscolor <- as.factor(obscolor)
  }

  collegend <- ifelse(length(unique(mdsobs$obscolor)) == 1, FALSE, TRUE)

  # Add point size to mdsobs if provided
  if (!is.null(obssize)) {
    mdsobs$obssize <- obssize
    sizlegend <- ifelse(length(unique(mdsobs$obssize)) == 1, FALSE, TRUE)
  } else {
    sizlegend <- FALSE
  }

  # Legend titles
  if (is.null(color_legend_title)) {
    color_legend_title <- deparse(substitute(obscolor))
  }

  g <- ggplot(mdsobs, aes(x = get(namx), y = get(namy)))


  if (collegend && sizlegend) {
    g <- g + geom_point(aes(colour = obscolor, size = obssize), alpha = 0.7)
  } else if (collegend) {
    g <- g + geom_point(aes(colour = obscolor), alpha = 0.7)
  } else if (sizlegend) {
    g <- g + geom_point(aes(size = obssize), alpha = 0.7)
  } else {
    g <- g + geom_point(colour = mdsobs$obscolor, alpha = 0.7)
  }

  g <- g + labs(x = namx, y = namy, colour = color_legend_title, size = size_legend_title) + coord_fixed(ratio = 1)

  if (var) {
    g <- g + geom_point(data = mdsvar,
                        aes(x = mdsvar[, 1], y = mdsvar[, 2]),
                        colour = "darkgrey", shape = 3, inherit.aes = FALSE)
  }

  if (varlab) {
    g <- g + ggrepel::geom_text_repel(data = mdsvar,
                                      aes(x = mdsvar[, 1], y = mdsvar[, 2], label = rownames(mdsvar)),
                                      colour = "red", show.legend = FALSE, inherit.aes = FALSE, ...)
  }

  if (obslab) {
    g <- g + ggrepel::geom_text_repel(data = mdsobs,
                                      aes(x = get(namx), y = get(namy), label = rownames(mdsobs)),
                                      show.legend = FALSE, inherit.aes = FALSE, ...)
  }

  # Add isolines from vegan::ordisurf
  if (!is.null(surf)) {

    if (!inherits(surf, "list")) {
      surf_names <- deparse(substitute(surf))
      surf <- list(surf)
    } else {
      surf_names <- sapply(substitute(surf)[-1], deparse)
    }

    if (is.null(surfcolor)) {
      surfcolor <- rep("black", length(surf))
    } else if (length(surfcolor) < length(surf)) {
      surfcolor <- rep(surfcolor, length.out = length(surf))
    }

    if (is.null(surf_legend_labels)) {
      surf_legend_labels <- surf_names
    } else if (length(surf_legend_labels) < length(surf)) {
      surf_legend_labels <- rep(surf_legend_labels, length.out = length(surf))
    }

    for (i in seq_along(surf)) {
      if (!inherits(surf[[i]], "ordisurf")) {
        stop("Each element in 'surf' must be an 'ordisurf' object")
      }
      grid_vals <- expand.grid(x = surf[[i]]$grid$x, y = surf[[i]]$grid$y)
      grid_vals$z <- as.vector(surf[[i]]$grid$z)
      grid_vals$surf_label <- surf_legend_labels[i]
      g <- g + metR::geom_contour2(data = grid_vals, aes(x = x, y = y, z = z, label = after_stat(level), , colour = surf_label, group = surf_label))
    }

    g <- g + scale_colour_manual(values = setNames(surfcolor, surf_legend_labels), name = "Isolines")
  }

  # Set axis limits to match total ranges
  if (var || varlab) {
    xlim_range <- range(c(mdsvar[[namx]], mdsobs[[namx]]), na.rm = TRUE)
    ylim_range <- range(c(mdsvar[[namy]], mdsobs[[namy]]), na.rm = TRUE)
  } else {
    xlim_range <- range(mdsobs[[namx]], na.rm = TRUE)
    ylim_range <- range(mdsobs[[namy]], na.rm = TRUE)
  }
  g <- g + xlim(xlim_range) + ylim(ylim_range)

  # Add vectors from envfit
  if (!is.null(envfit)) {
    if (!is.null(p.max)) {
      take <- envfit$vectors$pvals <= p.max
      envfit$vectors$arrows <- envfit$vectors$arrows[take, , drop = FALSE]
      envfit$vectors$r <- envfit$vectors$r[take]
      labs <- rownames(envfit$vectors$arrows)
    } else {
      labs <- rownames(envfit$vectors$arrows)
    }

    vect <- sqrt(envfit$vectors$r) * envfit$vectors$arrows[, dims, drop = FALSE]

    # Calculate scaling factor based on ggplot2 plot dimensions
    arrow_mul <- function(vect, g, xrange, yrange) {
      gb <- ggplot_build(g)
      u <- c(xrange, yrange)
      r <- c(range(vect[, 1], na.rm = TRUE), range(vect[, 2], na.rm = TRUE))
      fill <- 0.75
      u <- u / r
      u <- u[is.finite(u) & u > 0]
      fill * min(u)
    }

    arrow_mul_factor <- arrow_mul(vect, g, xlim_range, ylim_range)
    vect <- arrow_mul_factor * vect
    vect_df <- data.frame(x = vect[, 1], y = vect[, 2], label = labs)

    g <- g + geom_segment(data = vect_df, aes(x = 0, y = 0, xend = x, yend = y), arrow = arrow(length = unit(0.2, "cm")), color = "blue") +
      geom_text(data = vect_df, aes(x = x, y = y, label = label), color = "blue", hjust = 1.1, vjust = 1.1)
  }
  
  # Apply the specified theme
  g <- g + theme

  # Add title if provided
  if (!is.null(title)) {
    g <- g + ggtitle(title)
  }

  print(g)
}
