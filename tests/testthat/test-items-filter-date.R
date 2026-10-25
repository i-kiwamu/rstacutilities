test_that("filter catalog by dates", {
  dates <- c("2019-04-08", "2019-05-05", "2019-06-02", "2019-07-09")
  catalog <- search_catalog(fieldsHRO, "2019-04-01", "2019-08-01",
                            "sentinel-2-l2a")
  catalog_sub <- catalog |>
    items_filter_date(dates, fieldsHRO)
  expect_equal(rstac::items_length(catalog_sub), 8)
  expect_in(catalog_sub |>
              rstac::items_as_tibble() |>
              dplyr::pull(datetime) |>
              lubridate::ymd_hms() |>
              lubridate::with_tz("Asia/Tokyo") |>
              format("%Y-%m-%d"),
            dates)
})
