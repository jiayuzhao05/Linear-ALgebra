############################################################
# 02_propensity_score_stratification.R
# Purpose: Propensity score model, common support, strata, balance
############################################################

rm(list = ls())

library(dplyr)
library(ggplot2)
library(broom)

dat <- readRDS("output/data/analysis_data.rds")

ps_covariates <- c(
  "Male", "NonWhite", "SES", "Arts", "ReadK", "Age",
  "Catholic", "OthPriv", "SchKEnrl"
)

ps_formula <- as.formula(
  paste("Sports ~", paste(ps_covariates, collapse = " + "))
)

ps_model <- glm(ps_formula, data = dat, family = binomial)

dat$ps <- predict(ps_model, type = "response")

ps_summary <- tidy(ps_model, conf.int = TRUE)
write.csv(
  ps_summary,
  "output/tables/propensity_score_model.csv",
  row.names = FALSE
)

sink("output/models/propensity_score_model_summary.txt")
print(summary(ps_model))
sink()

# Common support (trim extreme propensity scores)
dat_ps <- dat %>%
  filter(ps >= 0.05, ps <= 0.95) %>%
  mutate(
    strata = cut(
      ps,
      breaks = quantile(ps, probs = seq(0, 1, 0.2), na.rm = TRUE),
      include.lowest = TRUE,
      labels = FALSE
    ),
    strata = factor(strata)
  )

write.csv(
  dat_ps %>% count(strata, name = "n"),
  "output/tables/ps_strata_counts.csv",
  row.names = FALSE
)

ggsave(
  "output/figures/propensity_score_histogram.png",
  ggplot(dat, aes(x = ps, fill = factor(Sports))) +
    geom_histogram(alpha = 0.6, position = "identity", bins = 40) +
    labs(
      x = "Propensity score",
      y = "Count",
      fill = "Sports",
      title = "Propensity score distribution by Sports participation"
    ) +
    theme_minimal(),
  width = 8,
  height = 5,
  dpi = 150
)

# Standardized mean difference helper
smd_abs <- function(x, treat) {
  x1 <- x[treat == 1]
  x0 <- x[treat == 0]
  if (length(x1) < 2 || length(x0) < 2) {
    return(NA_real_)
  }
  pooled_sd <- sqrt((var(x1) + var(x0)) / 2)
  if (is.na(pooled_sd) || pooled_sd == 0) {
    return(NA_real_)
  }
  abs(mean(x1) - mean(x0)) / pooled_sd
}

compute_balance <- function(data, stage_label) {
  bind_rows(lapply(ps_covariates, function(v) {
    overall <- tibble(
      variable = v,
      stage = stage_label,
      strata = "Overall",
      abs_smd = smd_abs(data[[v]], data$Sports)
    )

    by_stratum <- bind_rows(lapply(levels(data$strata), function(s) {
      sub <- data[data$strata == s, , drop = FALSE]
      tibble(
        variable = v,
        stage = stage_label,
        strata = as.character(s),
        abs_smd = smd_abs(sub[[v]], sub$Sports)
      )
    }))

    bind_rows(overall, by_stratum)
  }))
}

# Pre-stratification balance on trimmed sample (no strata yet)
dat_trim <- dat %>%
  filter(ps >= 0.05, ps <= 0.95) %>%
  mutate(strata = factor(1L))

balance_before <- compute_balance(dat_trim, "Before stratification")

# Post-stratification balance within strata
balance_after <- compute_balance(dat_ps, "Within stratum")

balance_summary <- bind_rows(balance_before, balance_after)

write.csv(
  balance_summary,
  "output/tables/balance_summary.csv",
  row.names = FALSE
)

within_stratum <- balance_after %>%
  filter(strata != "Overall")

balance_thresholds <- tibble(
  prop_below_01 = mean(within_stratum$abs_smd < 0.10, na.rm = TRUE),
  prop_below_02 = mean(within_stratum$abs_smd < 0.20, na.rm = TRUE),
  n_comparisons = sum(!is.na(within_stratum$abs_smd))
)

write.csv(
  balance_thresholds,
  "output/tables/balance_thresholds.csv",
  row.names = FALSE
)

saveRDS(dat_ps, "output/data/analysis_data_ps_strata.rds")
saveRDS(ps_model, "output/models/propensity_score_model.rds")

cat("Propensity score stratification sample size:", nrow(dat_ps), "\n")
cat("02_propensity_score_stratification.R completed successfully.\n")
