test_that("search catalog", {
  catalog <- search_catalog(fieldsHRO, "2019-04-01", "2019-08-02",
                            "sentinel-2-l2a")
  expect_equal(rstac::items_length(catalog), 69)
})
