#' Preview plot from catalog
#'
#' @importFrom rlang .data
#' @param catalog A `rstac` catalog object
#' @param i An index of catalog
#' @export
preview_rgb <- function(catalog, i) {
  n_catalog <- rstac::items_length(catalog)
  if(i %notin% 1:n_catalog) {
    stop(paste("ERROR: argument i should be 1 to", n_catalog))
  }
  catalog$features[[i]] |>
    rstac::assets_url(asset_names = "rendered_preview") |>
    rstac::preview_plot()
}
