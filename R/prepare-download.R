#' Prepare download of selected assets and polygon
#'
#' @importFrom rlang .data
#' @param catalog A `rstac` catalog object
#' @param asset_names A `character` vector of assets
#' @param polygon A `sf` object of polygon
#' @return A data frame including datetime, asset names, url, etc.
#' @export
prepare_download <- function(catalog, asset_names, polygon) {
  catalog_sub <- catalog |>
    rstac::assets_select(asset_names = asset_names)
  df_assets <-
    do.call("rbind",
            lapply(catalog_sub$features,
                   function(feature) {
                     do.call("rbind",
                             prepare_download_feature(feature,
                                                      asset_names))
                   })) |>
    dplyr::as_tibble() |>
    dplyr::rename(geometry_image = geometry)
  df_prepare <- tidyr::crossing(df_assets, polygon) |>
    sf::st_as_sf(crs = sf::st_crs(polygon)) |>
    dplyr::filter(sf::st_intersects(.data$geometry_image, .data$geometry,
                                    by_element = TRUE)) |>
    dplyr::as_tibble() |>
    dplyr::select(-"geometry_image") |>
    sf::st_as_sf() |>
    dplyr::distinct_at(dplyr::vars(-c("href", "mgrs_tile")), .keep_all = TRUE)
  return(df_prepare)
}

prepare_download_feature <- function(feature, asset_names) {
  lapply(asset_names,
         \(x) list(collection = feature$collection,
                   asset_name = x,
                   href = feature$assets[[x]]$href,
                   resolution = feature$assets[[x]]$gsd,
                   epsg = feature$properties$`proj:epsg`,
                   datetime = feature$properties$datetime,
                   platform = feature$properties$platform,
                   mgrs_tile = feature$properties$`s2:mgrs_tile`,
                   geometry = rstac::items_as_sf(feature)$geometry) |>
           tibble::as_tibble() |>
           sf::st_as_sf())
}
