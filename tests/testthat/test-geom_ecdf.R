skip_if_not_installed("dplyr")
skip_if_not_installed("tidysmd")

library(ggplot2)
library(tidysmd)
library(dplyr)

test_that("plots visualize ECDFs correctly", {
  p1 <- ggplot(
    nhefs_weights,
    aes(x = smokeyrs, color = factor(qsmk))
  ) +
    geom_ecdf()

  p2 <- ggplot(
    nhefs_weights,
    aes(x = smokeyrs, color = factor(qsmk))
  ) +
    geom_ecdf(aes(weights = w_ato))

  expect_doppelganger("Unweighted ECDF", p1)
  expect_doppelganger("Weighted ECDF", p2)
})


test_that("Weighted ECDF calculates correctly", {
  weighted_ecdf <- ggplot(
    nhefs_weights,
    aes(x = smokeyrs, color = factor(qsmk), group = factor(qsmk))
  ) +
    geom_ecdf(aes(weights = w_ato))
  weighted_ecdf_data <- layer_data(weighted_ecdf)

  calculated_edcf <- nhefs_weights %>%
    arrange(qsmk) %>%
    group_by(qsmk) %>%
    arrange(smokeyrs) %>%
    mutate(y = cumsum(w_ato) / sum(w_ato)) %>%
    ungroup()

  expect_equal(sort(calculated_edcf$y), sort(weighted_ecdf_data$y))
})
