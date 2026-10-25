#' Merge bands in each datetime and polygon
#'
#' @importFrom rlang .data
#' @param df A `dataframe` after download
#' @param filename_template A `character` to pass `stringr::str_glue()`
#' @return A dataframe
merge_bands <- function(df, filename_template) {
  df_with_names <- df |>
    dplyr::mutate(filename = stringr::str_glue(filename_template)) |>
    dplyr::mutate(filename = merge_bands_export(.data$data, .data$filename))
  return(df_with_names)
}

merge_bands_export <- function(data, filename) {
  trr_merge <- terra::rast(data$image_path)
  names(trr_merge) <- data$asset_name
  terra::writeRaster(trr_merge, filename, overwrite = TRUE)
  return(filename)
}
