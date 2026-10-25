#' Download images only in each polygon
#'
#' @importFrom rlang .data
#' @param df A `dataframe` prepared for the download
#' @param nodata A numerical value if nodata appears
#' @return A `dataframe` includes the stored file path
#' @export
download_images <- function(df, nodata = 0) {
  unique_geoms <- unique(df$geometry)
  n_geoms <- length(unique_geoms)
  polygon_file_names <- character(n_geoms)
  for(j in 1:n_geoms) {
    polygon_file_names[j] <- tempfile(fileext = ".geojson")
    sf::st_write(unique_geoms[j], polygon_file_names[j], quiet = TRUE)
  }

  n <- nrow(df)
  image_file_names <- character(n)

  for(i in 1:n) {
    image_file_names[i] <- tempfile(fileext = ".tif")
    polygon_file_name <- polygon_file_names[which(df$geometry[i] == unique_geoms)]

    url <- paste0(
      "/vsicurl",
      "?pc_url_signing=yes",
      "&pc_collection=",
      df$collection[i],
      "&url=",
      df$href[i])
    sf::gdal_utils("warp", source = url, destination = image_file_names[i],
                   options = c("-te", df$geometry[i] |>
                                 sf::st_transform(df$epsg[i]) |>
                                 sf::st_bbox(),
                               "-cutline", polygon_file_name,
                               "-dstnodata", nodata))
  }

  df$image_files <- image_file_names
  return(df)
}
