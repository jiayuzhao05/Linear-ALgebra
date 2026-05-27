# Purpose: Load data, clean variables, create analysis dataset

# Clear environment
rm(list = ls())

# 1. Install and load packages

packages <- c(
  "haven",
  "dplyr",
  "ggplot2",
  "lme4",
  "lmerTest",
  "broom.mixed",
  "knitr",
  "kableExtra",
  "htmltools"
)

options(repos = c(CRAN = "https://cloud.r-project.org"))

installed <- rownames(installed.packages())

for (p in packages) {
  if (!(p %in% installed)) {
    install.packages(p)
  }
}

library(haven)
library(dplyr)
library(ggplot2)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(knitr)
library(kableExtra)
library(htmltools)

# 2. Create output folders

dir.create("output", showWarnings = FALSE)
dir.create("output/models", showWarnings = FALSE)
dir.create("output/tables", showWarnings = FALSE)
dir.create("output/figures", showWarnings = FALSE)
dir.create("output/data", showWarnings = FALSE)

# 3. Load data

student_data <- read_dta("data/eclsk_1.dta")
school_data  <- read_dta("data/eclsk_2.dta")

# Check variable names
print(names(student_data))
print(names(school_data))

# 4. Basic data checks

cat("Student-level data dimensions:\n")
print(dim(student_data))

cat("School-level data dimensions:\n")
print(dim(school_data))

cat("Number of schools in student data:\n")
print(length(unique(student_data$S1_ID)))

cat("Number of schools in school data:\n")
print(length(unique(school_data$S1_ID)))

# eclsk_1 already includes school variables, so we mainly use eclsk_1.
# This checks whether school variables exist.
required_vars <- c(
  "S1_ID",
  "Read1",
  "Sports",
  "Male",
  "NonWhite",
  "SES",
  "Arts",
  "ReadK",
  "Age",
  "Catholic",
  "OthPriv",
  "SchKEnrl"
)

missing_vars <- setdiff(required_vars, names(student_data))

if (length(missing_vars) > 0) {
  stop(paste("Missing variables:", paste(missing_vars, collapse = ", ")))
}

# 5. Clean analysis dataset

dat <- student_data %>%
  select(
    S1_ID,
    Read1,
    Sports,
    Male,
    NonWhite,
    SES,
    Arts,
    ReadK,
    Age,
    Catholic,
    OthPriv,
    SchKEnrl
  ) %>%
  mutate(
    S1_ID = as.factor(S1_ID),
    Sports = as.numeric(Sports),
    Male = as.numeric(Male),
    NonWhite = as.numeric(NonWhite),
    SES = as.numeric(SES),
    Arts = as.numeric(Arts),
    ReadK = as.numeric(ReadK),
    Read1 = as.numeric(Read1),
    Age = as.numeric(Age),
    Catholic = as.numeric(Catholic),
    OthPriv = as.numeric(OthPriv),
    SchKEnrl = as.numeric(SchKEnrl)
  ) %>%
  na.omit()

# 6. Descriptive statistics

cat("Final analytic sample size:\n")
print(nrow(dat))

cat("Number of schools:\n")
print(length(unique(dat$S1_ID)))

cat("Sports participation rate:\n")
print(mean(dat$Sports))

desc_table <- dat %>%
  summarise(
    N = n(),
    Schools = n_distinct(S1_ID),
    Mean_Read1 = mean(Read1),
    SD_Read1 = sd(Read1),
    Sports_Rate = mean(Sports),
    Mean_SES = mean(SES),
    Mean_ReadK = mean(ReadK),
    Mean_Age = mean(Age)
  )

print(desc_table)

write.csv(
  desc_table,
  "output/tables/descriptive_statistics.csv",
  row.names = FALSE
)

# Save cleaned dataset
saveRDS(dat, "output/data/analysis_data.rds")

cat("00_setup_clean_data.R completed successfully.\n")