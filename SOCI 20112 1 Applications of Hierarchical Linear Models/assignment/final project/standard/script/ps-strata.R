# Export PS-stratified Level-1 data for HLM (strata as dummy indicators)
# Requires: output/data/analysis_data_ps_strata.rds
# Run from the "standard" folder.

library(haven)
library(dplyr)

args_wd <- commandArgs(trailingOnly = TRUE)
if (length(args_wd) > 0 && dir.exists(args_wd[[1]])) {
  setwd(args_wd[[1]])
} else if (file.exists("output/data/analysis_data_ps_strata.rds")) {
  # already in standard/
} else if (file.exists("../output/data/analysis_data_ps_strata.rds")) {
  setwd("..")
} else {
  stop("Set working directory to 'standard', or run propensity_score_stratification.R first.")
}

rds_path <- "output/data/analysis_data_ps_strata.rds"
if (!file.exists(rds_path)) {
  stop(
    "Missing ", rds_path,
    ". Run script/propensity_score_stratification.R first."
  )
}

dir.create("data", showWarnings = FALSE)
dir.create("output", showWarnings = FALSE)

hlm_dir <- "C:/HLMproject"
if (!dir.exists(hlm_dir)) {
  hlm_dir <- NULL
}

to_hlm_df <- function(df) {
  df <- zap_labels(as.data.frame(df))
  for (nm in names(df)) {
    x <- df[[nm]]
    if (is.logical(x)) x <- as.integer(x)
    if (is.factor(x)) x <- as.numeric(x)
    if (is.character(x)) x <- suppressWarnings(as.numeric(x))
    df[[nm]] <- as.double(x)
  }
  df
}

write_hlm_files <- function(df, path_no_ext) {
  write_sav(df, paste0(path_no_ext, ".sav"), compress = FALSE)
  write_dta(df, paste0(path_no_ext, ".dta"))
}

dat_ps <- readRDS(rds_path)

dat_ps_hlm <- dat_ps %>%
  mutate(
    S1_ID = as.numeric(as.character(S1_ID)),
    strata = as.numeric(as.character(strata)),
    strata2 = as.double(strata == 2),
    strata3 = as.double(strata == 3),
    strata4 = as.double(strata == 4),
    strata5 = as.double(strata == 5)
  ) %>%
  select(S1_ID, Read1, Sports, strata2, strata3, strata4, strata5) %>%
  filter(if_all(everything(), ~ !is.na(.))) %>%
  arrange(S1_ID)

dat_ps_hlm <- to_hlm_df(dat_ps_hlm)

cat("PS-strata HLM export\n")
cat("Rows:", nrow(dat_ps_hlm), "\n")
cat("Schools:", length(unique(dat_ps_hlm$S1_ID)), "\n")
cat("Strata2-5 sums:", colSums(dat_ps_hlm[, c("strata2", "strata3", "strata4", "strata5")]), "\n")
print(head(dat_ps_hlm))

write_hlm_files(dat_ps_hlm, "data/eclsk_ps_hlm")
if (!is.null(hlm_dir)) {
  write_hlm_files(dat_ps_hlm, file.path(hlm_dir, "eclsk_ps_hlm"))
}

check <- read_sav("data/eclsk_ps_hlm.sav")
cat(
  "Round-trip eclsk_ps_hlm.sav:",
  nrow(check), "rows,",
  ncol(check), "cols,",
  "S1_ID class:", class(check$S1_ID)[1], "\n"
)

writeLines(
  capture.output(
    cat("Exported:", nrow(dat_ps_hlm), "rows\n"),
    str(dat_ps_hlm)
  ),
  "output/hlm_ps_strata_export_log.txt"
)

cat("Written: data/eclsk_ps_hlm.sav and data/eclsk_ps_hlm.dta\n")
if (!is.null(hlm_dir)) cat("Also copied to:", hlm_dir, "\n")
cat("ps-strata.R completed successfully.\n")
