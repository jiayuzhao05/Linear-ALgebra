# Export ECLS-K data for HLM (MDM): clean numeric IDs, no labels, .sav + .dta
# Run from the "standard" folder (parent of script/).

library(haven)
library(dplyr)

# --- paths ---
args_wd <- commandArgs(trailingOnly = TRUE)
if (length(args_wd) > 0 && dir.exists(args_wd[[1]])) {
  setwd(args_wd[[1]])
} else if (file.exists("data/eclsk_1.dta")) {
  # already in standard/
} else if (file.exists("../data/eclsk_1.dta")) {
  setwd("..")
} else {
  stop("Set working directory to the 'standard' folder, then re-run.")
}

out_dir <- "data"
dir.create(out_dir, showWarnings = FALSE)
dir.create("output", showWarnings = FALSE)

hlm_dir <- "C:/HLMproject"
if (!dir.exists(hlm_dir)) {
  hlm_dir <- NULL
}

# --- helpers ---
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

# --- load ---
e1 <- read_dta(file.path(out_dir, "eclsk_1.dta"))
e2 <- read_dta(file.path(out_dir, "eclsk_2.dta"))

# --- Level 1 (student): outcome + student covariates + clustering ID ---
e1_hlm <- e1 %>%
  transmute(
    S1_ID = as.numeric(as.character(S1_ID)),
    Read1 = as.numeric(Read1),
    Sports = as.numeric(Sports),
    Male = as.numeric(Male),
    NonWhite = as.numeric(NonWhite),
    SES = as.numeric(SES),
    Arts = as.numeric(Arts),
    ReadK = as.numeric(ReadK),
    Age = as.numeric(Age)
  ) %>%
  filter(if_all(everything(), ~ !is.na(.))) %>%
  arrange(S1_ID)

# --- Level 2 (school): one row per school, school-level predictors ---
e2_hlm <- e2 %>%
  transmute(
    S1_ID = as.numeric(as.character(S1_ID)),
    Catholic = as.numeric(Catholic),
    OthPriv = as.numeric(OthPriv),
    SchKEnrl = as.numeric(SchKEnrl)
  ) %>%
  filter(if_all(everything(), ~ !is.na(.))) %>%
  distinct(S1_ID, .keep_all = TRUE) %>%
  filter(S1_ID %in% unique(e1_hlm$S1_ID)) %>%
  arrange(S1_ID)

e1_hlm <- to_hlm_df(e1_hlm)
e2_hlm <- to_hlm_df(e2_hlm)

# --- export to project data/ ---
write_hlm_files(e1_hlm, file.path(out_dir, "eclsk_1"))
write_hlm_files(e2_hlm, file.path(out_dir, "eclsk_2"))

# optional copy for HLM project folder
if (!is.null(hlm_dir)) {
  write_hlm_files(e1_hlm, file.path(hlm_dir, "eclsk_1"))
  write_hlm_files(e2_hlm, file.path(hlm_dir, "eclsk_2"))
}

# --- verification ---
check_roundtrip <- function(path) {
  d <- read_sav(path)
  c(rows = nrow(d), cols = ncol(d), id_class = class(d[["S1_ID"]])[1])
}

info <- list(
  level1_rows = nrow(e1_hlm),
  level2_rows = nrow(e2_hlm),
  level1_schools = length(unique(e1_hlm$S1_ID)),
  level2_schools = length(unique(e2_hlm$S1_ID)),
  sav_l1 = check_roundtrip(file.path(out_dir, "eclsk_1.sav")),
  sav_l2 = check_roundtrip(file.path(out_dir, "eclsk_2.sav"))
)

cat("HLM export verification\n")
cat("Level-1 rows:", info$level1_rows, "| schools:", info$level1_schools, "\n")
cat("Level-2 rows:", info$level2_rows, "| schools:", info$level2_schools, "\n")
cat("eclsk_1.sav round-trip:", paste(names(info$sav_l1), info$sav_l1, collapse = " "), "\n")
cat("eclsk_2.sav round-trip:", paste(names(info$sav_l2), info$sav_l2, collapse = " "), "\n")
cat("S1_ID is numeric in export:", is.numeric(e1_hlm$S1_ID), "\n")
cat("Files written to:", normalizePath(out_dir), "\n")
if (!is.null(hlm_dir)) cat("Also copied to:", hlm_dir, "\n")

writeLines(
  capture.output(str(info), str(e1_hlm), str(e2_hlm)),
  "output/hlm_data_export_log.txt"
)

cat("data_form.r completed successfully.\n")
