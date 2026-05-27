# Purpose: Create final clean tables for report write-up

rm(list = ls())

library(dplyr)
library(knitr)
library(kableExtra)
library(htmltools)
library(broom.mixed)

# 1. Load saved results

naive_model <- readRDS("output/models/naive_model.rds")
adjusted_model <- readRDS("output/models/adjusted_model.rds")
final_ps_model <- readRDS("output/models/final_ps_stratified_model.rds")
final_ps_adjusted_model <- readRDS("output/models/final_ps_adjusted_model.rds")

desc <- read.csv("output/tables/descriptive_statistics.csv")
balance_summary <- read.csv("output/tables/balance_summary.csv")
balance_thresholds <- read.csv("output/tables/balance_thresholds.csv")
sensitivity_table <- read.csv("output/tables/sensitivity_sports_effects.csv")

# 2. Main model comparison table

get_fixed_table <- function(model, model_name) {
  tidy(model, effects = "fixed") %>%
    mutate(model = model_name) %>%
    select(model, term, estimate, std.error, statistic)
}

model_comparison <- bind_rows(
  get_fixed_table(naive_model, "Naive"),
  get_fixed_table(adjusted_model, "Adjusted"),
  get_fixed_table(final_ps_model, "PS Stratified"),
  get_fixed_table(final_ps_adjusted_model, "PS Stratified + Adjusted")
)

write.csv(
  model_comparison,
  "output/tables/full_model_comparison.csv",
  row.names = FALSE
)

model_comparison_html <- model_comparison %>%
  kable(
    format = "html",
    digits = 3,
    caption = "Full Model Comparison"
  ) %>%
  kable_styling(full_width = FALSE)

save_html(
  model_comparison_html,
  "output/tables/full_model_comparison.html"
)

# 3. Clean sports-only table for report

sports_report_table <- sensitivity_table %>%
  mutate(
    estimate = round(estimate, 3),
    std.error = round(std.error, 3),
    statistic = round(statistic, 3),
    conf.low = round(conf.low, 3),
    conf.high = round(conf.high, 3)
  )

write.csv(
  sports_report_table,
  "output/tables/report_table_sports_effect.csv",
  row.names = FALSE
)

sports_report_html <- sports_report_table %>%
  kable(
    format = "html",
    caption = "Estimated Association Between Sports Participation and First-Grade Reading"
  ) %>%
  kable_styling(full_width = FALSE)

save_html(
  sports_report_html,
  "output/tables/report_table_sports_effect.html"
)

# 4. Balance table for report

balance_report_table <- balance_summary %>%
  select(variable, stage, strata, abs_smd) %>%
  mutate(abs_smd = round(abs_smd, 3))

write.csv(
  balance_report_table,
  "output/tables/report_table_balance.csv",
  row.names = FALSE
)

balance_report_html <- balance_report_table %>%
  kable(
    format = "html",
    caption = "Balance Diagnostics Using Absolute Standardized Mean Differences"
  ) %>%
  kable_styling(full_width = FALSE)

save_html(
  balance_report_html,
  "output/tables/report_table_balance.html"
)

# 5. Write short text results for easy copy into report

sports_naive <- sensitivity_table %>%
  filter(model == "Naive HLM") %>%
  pull(estimate)

sports_adjusted <- sensitivity_table %>%
  filter(model == "Covariate-Adjusted HLM") %>%
  pull(estimate)

sports_ps <- sensitivity_table %>%
  filter(model == "PS-Stratified HLM") %>%
  pull(estimate)

sports_ps_adj <- sensitivity_table %>%
  filter(model == "PS-Stratified + Covariate-Adjusted HLM") %>%
  pull(estimate)

balance_01 <- balance_thresholds$prop_below_01
balance_02 <- balance_thresholds$prop_below_02

results_text <- paste0(
  "RESULTS SUMMARY\n\n",
  "Naive HLM Sports coefficient: ", round(sports_naive, 3), "\n",
  "Covariate-adjusted HLM Sports coefficient: ", round(sports_adjusted, 3), "\n",
  "PS-stratified HLM Sports coefficient: ", round(sports_ps, 3), "\n",
  "PS-stratified + covariate-adjusted HLM Sports coefficient: ", round(sports_ps_adj, 3), "\n\n",
  "Proportion of within-stratum SMDs below .10: ", round(balance_01, 3), "\n",
  "Proportion of within-stratum SMDs below .20: ", round(balance_02, 3), "\n\n",
  "Suggested interpretation:\n",
  "The naive model showed a relatively large positive association between sports participation ",
  "and first-grade reading achievement. After adjusting for student- and school-level covariates, ",
  "the estimated association became much smaller, suggesting that much of the naive association ",
  "was due to pre-existing differences between students. Propensity score stratification produced ",
  "a smaller positive estimate similar to the adjusted model, indicating that sports participation ",
  "remained positively associated with reading achievement after improving covariate balance. ",
  "However, because unobserved confounding may remain, the results should be interpreted as ",
  "associational rather than definitively causal.\n"
)

cat(results_text)

writeLines(
  results_text,
  "output/tables/results_summary_for_report.txt"
)

cat("04_make_report_tables.R completed successfully.\n")