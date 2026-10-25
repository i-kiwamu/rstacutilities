test_that("prepare download", {
  dates <- c("2019-04-08", "2019-05-05", "2019-06-19", "2019-07-29")
  catalog <- search_catalog(fieldsHRO, "2019-04-01", "2019-08-02",
                            "sentinel-2-l2a") |>
    items_filter_date(dates, fieldsHRO)
  df_prepare <- catalog |>
    prepare_download(c("B04", "B08"), fieldsHRO)
  expect_equal(nrow(df_prepare), 16)
})
