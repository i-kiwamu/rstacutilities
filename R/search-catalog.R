#' Search catalog from STAC API
#'
#' @importFrom rlang .data
#' @param aoi A `sf` object of polygon or its bounding box
#' @param start_date Start date to search
#' @param end_date End date to search
#' @param collection Collection name
#' @param max_cloud_cover Maximum percentage of cloud cover (0-100, default 50)
#' @param url A url of STAC API (default: the url of Microsoft Planetary Computer)
#' @return A `sf` object
#' @export
search_catalog <-
  function(aoi, start_date, end_date, collection,
           max_cloud_cover = 50,
           url = "https://planetarycomputer.microsoft.com/api/stac/v1") {
  bbox <- NULL
  if(inherits(aoi, c("sf", "sfc"))) {
    if(all(is.element(sf::st_geometry_type(aoi),
                      c("POLYGON", "MULTIPOLYGON")))) {
      bbox <- aoi |>
        sf::st_transform(4326) |>
        sf::st_bbox()
    } else {
      stop("ERROR: aoi argument requires POLYGON or MULTIPOLYGON geometry!")
    }
  } else if("bbox" %in% class(aoi)) {
    bbox <- aoi
  } else {
    stop("ERROR: aoi argument requires sf object or its bounding box!")
  }
  spatial_range <- rstac::cql2_bbox_as_geojson(bbox)

  if(inherits(start_date, "Date"))
    start_date <- as.character(start_date)
  if(inherits(end_date, "Date"))
    end_date <- as.character(end_date)
  date_range <- rstac::cql2_interval(start_date, end_date)

  catalog <- rstac::stac(url) |>
    rstac::ext_filter(collection == {{collection}} &&
                        t_intersects(datetime, {{date_range}}) &&
                        s_intersects(geometry, {{spatial_range}}) &&
                        `eo:cloud_cover` < {{max_cloud_cover}}) |>
    rstac::post_request()

  return(catalog)
}

utils::globalVariables(c("datetime", "geometry", "eo:cloud_cover",
                         "t_intersects", "s_intersects"))
