# rstacutilities

## Overview

rstacutilities is a R package containing some utility functions to use [`rstac`](https://brazil-data-cube.github.io/rstac/).

## Install

```{r}
remotes::install_github("i-kiwamu/rstacutilities")
```

## Usage

For example, we would like to download Sentinel-2 images (L2A products) from 2019-04-01 to 2019-08-02 only in two agricultural fields (`fieldsHRO` object bundled in this package).

```{r}
library(tidyverse)
library(rstacutilities)

dates <- c("2019-04-08", "2019-05-05", "2019-06-19", "2019-07-09")

catalog <- search_catalog(fieldsHRO, "2019-04-01", "2019-08-02",
                          "sentinel-2-l2a") |>
  items_filter_date(dates, fieldsHRO)
df_downloads <- catalog |>
  prepare_download(c("B04", "B08"), fieldsHRO) |>
  download_images() |>
  nest_by(datetime, Field) |>
  merge_bands("{str_split_1(datetime, 'T')[1L]}_{Field}.tif")
```
