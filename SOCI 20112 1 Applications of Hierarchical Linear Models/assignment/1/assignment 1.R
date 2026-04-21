install.packages(c("haven", "dplyr", "lme4", "lmerTest", "ggplot2", "sjPlot"))
library(haven)
library(dplyr)
library(lme4)
library(lmerTest)
library(ggplot2)
library(sjPlot)

hsb1 <- read_sav("hsb1.sav")
hsb2 <- read_sav("hsb2.sav")

names(hsb1)
names(hsb2)

datA <- hsb1 %>%
  left_join(hsb2, by = "ID")

glimpse(datA)
summary(datA)

# part a 1 OLS
ols_gap <- lm(MATHACH ~ MINORITY, data = datA)
summary(ols_gap)
coef(summary(ols_gap))

#（2）
datA <- datA %>%
  group_by(ID) %>%
  mutate(
    MINORITY_MEAN = mean(MINORITY, na.rm = TRUE),
    MINORITYCWC = MINORITY - MINORITY_MEAN
  ) %>%
  ungroup()



model_A2 <- lmer(
  MATHACH ~ MINORITYCWC + MINORITY_MEAN + (1 | ID),
  data = datA,
  REML = FALSE
)

summary(model_A2)


coef(summary(model_A2))


#（3）
gap_diff <- national_gap - within_gap
cat("Difference between national and within-school gap =", gap_diff, "\n")

#（4）
model_A4 <- lmer(
  MATHACH ~ MINORITYCWC + MINORITY_MEAN + (1 + MINORITYCWC | ID),
  data = datA,
  REML = FALSE
)

summary(model_A4)
VarCorr(model_A4)

anova(model_A2, model_A4)
VarCorr(model_A4)

re_A4 <- ranef(model_A4, condVar = TRUE)$ID
head(re_A4)

fixed_slope <- fixef(model_A4)["MINORITYCWC"]

school_effects <- re_A4 %>%
  mutate(
    school = rownames(re_A4),
    gap_EB = fixed_slope + MINORITYCWC
  )


sector_df <- datA %>%
  group_by(ID) %>%
  summarise(SECTOR = first(SECTOR))

school_effects <- school_effects %>%
  left_join(sector_df, by = c("school" = "ID"))


school_effects <- school_effects %>%
  arrange(gap_EB) %>%
  mutate(rank = row_number())


ggplot(school_effects, aes(x = rank, y = gap_EB, color = factor(SECTOR))) +
  geom_point() +
  geom_line(aes(group = 1), color = "black", linewidth = 0.4) +
  labs(
    x = "School rank",
    y = "Empirical Bayes estimate of minority gap",
    color = "Sector",
    title = "School-specific Minority-Majority Gaps"
  ) +
  theme_minimal()

#（5）
model_A5 <- lmer(
  MATHACH ~ MINORITYCWC + MINORITY_MEAN + SECTOR + MINORITYCWC:SECTOR +
    (1 + MINORITYCWC | ID),
  data = datA,
  REML = FALSE
)

summary(model_A5)

fixef(model_A5)


beta_gap_public <- fixef(model_A5)["MINORITYCWC"]
beta_gap_diff <- fixef(model_A5)["MINORITYCWC:SECTOR"]
beta_gap_catholic <- beta_gap_public + beta_gap_diff

cat("Public school gap =", beta_gap_public, "\n")
cat("Catholic school gap =", beta_gap_catholic, "\n")

coef(summary(model_A5))["MINORITYCWC:SECTOR", ]

#（6）
model_A6 <- lmer(
  MATHACH ~ MINORITYCWC + MINORITY_MEAN + SECTOR + HIMINTY +
    MINORITYCWC:SECTOR + MINORITYCWC:HIMINTY +
    (1 + MINORITYCWC | ID),
  data = datA,
  REML = FALSE
)

summary(model_A6)

coef(summary(model_A6))

tab_model(
  ols_gap, model_A2, model_A4, model_A5, model_A6,
  show.re.var = TRUE,
  show.icc = FALSE,
  show.aic = TRUE
)

#part B
install.packages(c("haven", "dplyr", "nlme", "ggplot2", "sjPlot"))
library(haven)
library(dplyr)
library(nlme)
library(ggplot2)
library(sjPlot)

vocab1 <- read_dta("vocab1hw.dta")
vocab2 <- read_dta("vocab2hw.dta")

names(vocab1)
names(vocab2)

datB <- vocab1 %>%
  left_join(vocab2, by = "CHILDID")

glimpse(datB)
summary(datB)

datB <- datB %>%
  mutate(
    AGE18 = AGE - 18,
    AGE18SQ = AGE18^2
  )

#（3）
model_B0 <- lme(
  fixed = VOCAB ~ AGE18 + AGE18SQ,
  random = ~ AGE18 + AGE18SQ | CHILDID,
  data = datB,
  method = "ML",
  na.action = na.omit,
  control = lmeControl(opt = "optim")
)

summary(model_B0)
intervals(model_B0)
VarCorr(model_B0)
fixef(model_B0)
ranef(model_B0)
logLik(model_B0)
AIC(model_B0)
BIC(model_B0)

beta00 <- fixef(model_B0)[1]
beta10 <- fixef(model_B0)[2]
beta20 <- fixef(model_B0)[3]

cat("beta00 =", beta00, "\n")
cat("beta10 =", beta10, "\n")
cat("beta20 =", beta20, "\n")

#（7）
model_B1 <- lme(
  fixed = VOCAB ~ MOMSPEAK * AGE18 + MOMSPEAK * AGE18SQ,
  random = ~ AGE18 + AGE18SQ | CHILDID,
  data = datB,
  method = "ML",
  na.action = na.omit,
  control = lmeControl(opt = "optim")
)

summary(model_B1)
intervals(model_B1)
VarCorr(model_B1)
fixef(model_B1)
ranef(model_B1)
logLik(model_B1)
AIC(model_B1)
BIC(model_B1)

coefs_B1 <- fixef(model_B1)
print(coefs_B1)

beta00 <- coefs_B1["(Intercept)"]
beta01 <- coefs_B1["MOMSPEAK"]
beta10 <- coefs_B1["AGE18"]
beta11 <- coefs_B1["MOMSPEAK:AGE18"]
beta20 <- coefs_B1["AGE18SQ"]
beta21 <- coefs_B1["MOMSPEAK:AGE18SQ"]

cat("beta00 =", beta00, "\n")
cat("beta01 =", beta01, "\n")
cat("beta10 =", beta10, "\n")
cat("beta11 =", beta11, "\n")
cat("beta20 =", beta20, "\n")
cat("beta21 =", beta21, "\n")

#（6）
anova(model_B0, model_B1)

q25 <- quantile(datB$MOMSPEAK, 0.25, na.rm = TRUE)
q75 <- quantile(datB$MOMSPEAK, 0.75, na.rm = TRUE)

q25
q75

plotdat <- expand.grid(
  AGE = seq(min(datB$AGE, na.rm = TRUE), max(datB$AGE, na.rm = TRUE), length.out = 100),
  MOMSPEAK = c(q25, q75)
)

plotdat <- plotdat %>%
  mutate(
    AGE18 = AGE - 18,
    AGE18SQ = AGE18^2,
    pred = predict(model_B1, newdata = ., level = 0),
    group = ifelse(MOMSPEAK == q25, "25th percentile", "75th percentile")
  )

ggplot(plotdat, aes(x = AGE, y = pred, color = group)) +
  geom_line(linewidth = 1.2) +
  labs(
    x = "Age (months)",
    y = "Predicted Vocabulary",
    color = "MOMSPEAK",
    title = "Model-based Vocabulary Growth Trajectories"
  ) +
  theme_minimal()


tab_model(
  model_B0, model_B1,
  show.re.var = TRUE,
  show.icc = FALSE,
  show.aic = TRUE
)