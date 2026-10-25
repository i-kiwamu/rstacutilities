#' Filter by date
#'
#' @importFrom rlang .data
#' @param catalog A `rstac` catalog object
#' @param dates A list of dates to filter (character or Date object)
#' @param polygon A `sf` object of polygon
#' @return filtered catalog object
#' @export
items_filter_date <- function(catalog, dates, polygon) {
  if(inherits(dates, "character"))
    dates <- lubridate::ymd(dates)

  sf_catalog_filtered <- catalog |>
    rstac::items_as_sf() |>
    sf::st_filter(polygon) |>
    dplyr::mutate(date = lubridate::date(lubridate::ymd_hms(.data$datetime))) |>
    dplyr::filter(is.element(.data$date, dates)) |>
    dplyr::group_by(.data$date) |>
    dplyr::mutate(n = dplyr::n()) |>
    dplyr::ungroup()

  catalog_filtered <- catalog |>
    rstac::items_filter(filter_fn = function(x) {
      is.element(x$properties$`s2:granule_id`,
                 sf_catalog_filtered$`s2:granule_id`)
    })

  return(catalog_filtered)
}
