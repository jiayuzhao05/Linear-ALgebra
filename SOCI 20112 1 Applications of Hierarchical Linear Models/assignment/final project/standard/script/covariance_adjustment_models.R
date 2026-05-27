############################################################
# 01_covariance_adjustment_models.R
# Purpose: Naive HLM and covariate-adjusted HLM
############################################################

rm(list = ls())

library(dplyr)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(knitr)
library(kableExtra)
library(htmltools)

dat <- readRDS("output/data/analysis_data.rds")

# 1. Naive HLM
# Model: Read1 ~ Sports + random intercept and random Sports slope

naive_model <- lmer(
  Read1 ~ Sports + (1 + Sports | S1_ID),
  data = dat,
  REML = FALSE,
  control = lmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 100000)
  )
)

cat("NAIVE MODEL SUMMARY\n")
print(summary(naive_model))

# 2. Adjusted HLM
# Model with all covariates

adjusted_model <- lmer(
  Read1 ~ Sports + Male + NonWhite + SES + Arts + ReadK + Age +
    Catholic + OthPriv + SchKEnrl +
    (1 + Sports | S1_ID),
  data = dat,
  REML = FALSE,
  control = lmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 100000)
  )
)

cat("ADJUSTED MODEL SUMMARY\n")
print(summary(adjusted_model))

# 3. Save model objects

saveRDS(naive_model, "output/models/naive_model.rds")
saveRDS(adjusted_model, "output/models/adjusted_model.rds")

# 4. Extract fixed effects tables

naive_fixed <- tidy(
  naive_model,
  effects = "fixed",
  conf.int = TRUE
)

adjusted_fixed <- tidy(
  adjusted_model,
  effects = "fixed",
  conf.int = TRUE
)

write.csv(
  naive_fixed,
  "output/tables/naive_model_fixed_effects.csv",
  row.names = FALSE
)

write.csv(
  adjusted_fixed,
  "output/tables/adjusted_model_fixed_effects.csv",
  row.names = FALSE
)

# 5. Create HTML tables for Canvas / report

naive_html <- naive_fixed %>%
  select(term, estimate, std.error, statistic, conf.low, conf.high) %>%
  kable(
    format = "html",
    digits = 3,
    caption = "Naive HLM: Read1 predicted by Sports"
  ) %>%
  kable_styling(full_width = FALSE)

adjusted_html <- adjusted_fixed %>%
  select(term, estimate, std.error, statistic, conf.low, conf.high) %>%
  kable(
    format = "html",
    digits = 3,
    caption = "Covariate-Adjusted HLM"
  ) %>%
  kable_styling(full_width = FALSE)

save_html(
  naive_html,
  "output/models/naive_model.html"
)

save_html(
  adjusted_html,
  "output/models/adjusted_model.html"
)

# 6. Save text summaries

sink("output/models/naive_model_summary.txt")
print(summary(naive_model))
sink()

sink("output/models/adjusted_model_summary.txt")
print(summary(adjusted_model))
sink()

cat("01_covariance_adjustment_models.R completed successfully.\n")