library(knitr)
library(kableExtra)
library(htmltools)

ps <- read.csv("output/tables/propensity_score_model.csv")
tab <- kable(ps, format = "html", digits = 3,
             caption = "Propensity Score Model (Logistic Regression)") %>%
  kable_styling(full_width = FALSE)
save_html(tab, "output/html/propensity_score_model.html")