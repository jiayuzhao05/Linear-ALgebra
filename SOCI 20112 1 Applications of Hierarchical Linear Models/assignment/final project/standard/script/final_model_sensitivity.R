# Purpose: Final HLM after propensity score stratification
#          and sensitivity comparison across models

rm(list = ls())

library(dplyr)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(knitr)
library(kableExtra)
library(htmltools)

dat_ps <- readRDS("output/data/analysis_data_ps_strata.rds")

naive_model <- readRDS("output/models/naive_model.rds")
adjusted_model <- readRDS("output/models/adjusted_model.rds")

# 1. Final propensity score stratified HLM
# Random intercept for school
# Strata entered as fixed effects

final_ps_model <- lmer(
  Read1 ~ Sports + strata + (1 | S1_ID),
  data = dat_ps,
  REML = FALSE,
  control = lmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 100000)
  )
)

cat("FINAL PS-STRATIFIED MODEL SUMMARY\n")
print(summary(final_ps_model))


# 2. Optional doubly adjusted PS model
# This includes strata plus original covariates
# You can use this as a sensitivity analysis

final_ps_adjusted_model <- lmer(
  Read1 ~ Sports + strata +
    Male + NonWhite + SES + Arts + ReadK + Age +
    Catholic + OthPriv + SchKEnrl +
    (1 | S1_ID),
  data = dat_ps,
  REML = FALSE,
  control = lmerControl(
    optimizer = "bobyqa",
    optCtrl = list(maxfun = 100000)
  )
)

cat("FINAL PS + COVARIATE ADJUSTED MODEL SUMMARY\n")
print(summary(final_ps_adjusted_model))

# 3. Save model objects

saveRDS(final_ps_model, "output/models/final_ps_stratified_model.rds")
saveRDS(final_ps_adjusted_model, "output/models/final_ps_adjusted_model.rds")

# 4. Save summaries as text

sink("output/models/final_ps_stratified_model_summary.txt")
print(summary(final_ps_model))
sink()

sink("output/models/final_ps_adjusted_model_summary.txt")
print(summary(final_ps_adjusted_model))
sink()

# 5. Fixed effects tables

final_fixed <- tidy(
  final_ps_model,
  effects = "fixed",
  conf.int = TRUE
)

final_adjusted_fixed <- tidy(
  final_ps_adjusted_model,
  effects = "fixed",
  conf.int = TRUE
)

write.csv(
  final_fixed,
  "output/tables/final_ps_stratified_model_fixed_effects.csv",
  row.names = FALSE
)

write.csv(
  final_adjusted_fixed,
  "output/tables/final_ps_adjusted_model_fixed_effects.csv",
  row.names = FALSE
)

# 6. HTML tables

final_html <- final_fixed %>%
  select(term, estimate, std.error, statistic, conf.low, conf.high) %>%
  kable(
    format = "html",
    digits = 3,
    caption = "Final Propensity Score Stratified HLM"
  ) %>%
  kable_styling(full_width = FALSE)

save_html(
  final_html,
  "output/models/final_ps_stratified_model.html"
)

final_adjusted_html <- final_adjusted_fixed %>%
  select(term, estimate, std.error, statistic, conf.low, conf.high) %>%
  kable(
    format = "html",
    digits = 3,
    caption = "Final Propensity Score + Covariate Adjusted HLM"
  ) %>%
  kable_styling(full_width = FALSE)

save_html(
  final_adjusted_html,
  "output/models/final_ps_adjusted_model.html"
)

# 7. Sensitivity analysis table
# Compare Sports coefficient across models

extract_sports <- function(model, model_name) {
  tidy(model, effects = "fixed", conf.int = TRUE) %>%
    filter(term == "Sports") %>%
    mutate(model = model_name) %>%
    select(model, term, estimate, std.error, statistic, conf.low, conf.high)
}

sensitivity_table <- bind_rows(
  extract_sports(naive_model, "Naive HLM"),
  extract_sports(adjusted_model, "Covariate-Adjusted HLM"),
  extract_sports(final_ps_model, "PS-Stratified HLM"),
  extract_sports(final_ps_adjusted_model, "PS-Stratified + Covariate-Adjusted HLM")
)

print(sensitivity_table)

write.csv(
  sensitivity_table,
  "output/tables/sensitivity_sports_effects.csv",
  row.names = FALSE
)

sensitivity_html <- sensitivity_table %>%
  kable(
    format = "html",
    digits = 3,
    caption = "Sensitivity Analysis: Sports Coefficient Across Models"
  ) %>%
  kable_styling(full_width = FALSE)

save_html(
  sensitivity_html,
  "output/tables/sensitivity_sports_effects.html"
)

cat("03_final_model_sensitivity.R completed successfully.\n")