library(haven)
library(lme4)

dat <- read_dta("eclsk_1.dta")

naive <- lmer(
  Read1 ~ Sports + (1 + Sports | S1_ID),
  data = dat
)

adjusted <- lmer(
  Read1 ~ Sports + Male + NonWhite + SES + Arts + ReadK + Age +
          Catholic + OthPriv + SchKEnrl +
          (1 + Sports | S1_ID),
  data = dat
)

ps_model <- glm(
  Sports ~ Male + NonWhite + SES + Arts + ReadK + Age +
           Catholic + OthPriv + SchKEnrl,
  data = dat,
  family = binomial
)

dat$ps <- predict(ps_model, type = "response")

dat2 <- dat[dat$ps >= 0.05 & dat$ps <= 0.95, ]

dat2$strata <- cut(
  dat2$ps,
  breaks = quantile(dat2$ps, probs = seq(0, 1, 0.2), na.rm = TRUE),
  include.lowest = TRUE,
  labels = 1:5
)

final <- lmer(
  Read1 ~ Sports + factor(strata) + (1 | S1_ID),
  data = dat2
)

summary(naive)
summary(adjusted)
summary(ps_model)
summary(final)