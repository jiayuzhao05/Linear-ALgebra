
rm(list=ls())

library(tidyverse)
library(rio)
library(tidylog)
library(Hmisc)
library(jtools)

options(scipen=999)


#set working directory, note slashes are reversed from Windows
#I have three set here, corresponding to different computers I use.  You will generally only need one working directory
setwd ("C:/Users/Prism/Dropbox/_HLM 2026/Demonstration Data")  #Home
setwd ("C:/Users/Marshall/Dropbox/_HLM 2026/Demonstration Data")  #Laptop
setwd ("C:/Users/Marshall Jean/Dropbox/_HLM 2026/Demonstration Data")  #Office



res <- import("./Thai/resfil1.sav") 



res$PropScore <- res$FITVAL  #call it PropScore to help is remember

#STEP 3: Identify common support


ggplot(res, aes(x = PropScore)) +
    geom_histogram(fill = "cadetblue", colour = "black") +
    facet_grid(PRED1D ~ .)

range(res$PropScore[res$PRED1D==1], na.rm = T)
range(res$PropScore[res$PRED1D==0], na.rm = T)

#You eliminate data below the highest minimum and above the lowest maximum
mins <- c(min(res$PropScore[res$PRED1D==1], na.rm = T), min(res$PropScore[res$PRED1D==0], na.rm = T) )
maxs <- c(max(res$PropScore[res$PRED1D==1], na.rm = T), max(res$PropScore[res$PRED1D==0], na.rm = T) )

summary(res$PropScore)
res$PropScore[res$PropScore < max(mins) | res$PropScore > min(maxs) ] <- NA
summary(res$PropScore)
res <- res %>% filter (is.na(res$PropScore)==0)
    #we only eliminated a moderate number of students, which is good because we get to keep most of our data; but even if we lose a lot, this step is still necessary

ggplot(res, aes(x = PropScore)) +
    geom_histogram(fill = "cadetblue", colour = "black") +
    facet_grid(PRED1D ~ .)


#STEP 4: Stratify on propensity score 

#broken into steps so you can see the interim outputs
res$Stratum <- cut_number(res$PropScore, 10)   #cuts data into n strata based on propensity score
res$Stratum <- as.numeric(res$Stratum)  #changes the outputted variable into one that is numbered 
res$Stratum <- as.factor(res$Stratum)   #changes the numbered variable to categorical
#end result is that each stratum will be treated as its own category in regression, and they are labeled with numbers

res$Stratum <- as.factor(as.numeric(cut_number(res$PropScore, 10)))   #same as above in one line

describe(res$Stratum)

#STEP 5: Check balance

###WITH HYPOTHESIS TESTS
#with ANOVA - omnibus test for each variable to see if balanced
#want to see main effect of treatment and interaction with stratum not significant
summary (aov(PropScore ~ PRED1D * Stratum, data=res)) 
summary (aov(SESC ~ PRED1D * Stratum, data=res)) 
summary (aov(DSSEX ~ PRED1D * Stratum, data=res))
summary (aov(DIALCT1 ~ PRED1D * Stratum, data=res))
summary (aov(L_ENRC ~ PRED1D * Stratum, data=res))   

#with t-tests for continuous predictors
#want to see tests of mean difference to be insignificant 
t.test (res$PropScore[res$Stratum==1] ~ res$PRED1D[res$Stratum==1])
t.test (res$PropScore[res$Stratum==2] ~ res$PRED1D[res$Stratum==2])
t.test (res$PropScore[res$Stratum==3] ~ res$PRED1D[res$Stratum==3])
t.test (res$PropScore[res$Stratum==4] ~ res$PRED1D[res$Stratum==4])
t.test (res$PropScore[res$Stratum==5] ~ res$PRED1D[res$Stratum==5]) 
t.test (res$PropScore[res$Stratum==6] ~ res$PRED1D[res$Stratum==6]) #.....

#with chi-squared tests for binary predictors
#want to see tests to be insignificant 
chisq.test(res$DSSEX[res$Stratum==1], (res$PRED1D)[res$Stratum==1])
chisq.test(res$DSSEX[res$Stratum==2], (res$PRED1D)[res$Stratum==2])
chisq.test(res$DSSEX[res$Stratum==3], (res$PRED1D)[res$Stratum==3])
chisq.test(res$DSSEX[res$Stratum==4], (res$PRED1D)[res$Stratum==4])
chisq.test(res$DSSEX[res$Stratum==5], (res$PRED1D)[res$Stratum==5])
chisq.test(res$DSSEX[res$Stratum==6], (res$PRED1D)[res$Stratum==6]) #.....
#.... continue with all variables, across all strata


   #this is tedious but can be automated with functions
   #useful for figuring out which strata in particular are problematic (i.e. unbalanced between treatment and control)

#If you use hypothesis tests, you want to see balance on at least 95% of your tests



### WITH STANDARDIZED MEAN DIFFERENCES
#want to see SMDs at least under .2 , and ideally under .1

#SMDs for continuous variables
abs( mean(res$PropScore[res$PRED1D==1 & res$Stratum==1]) - mean(res$PropScore[res$PRED1D==0 & res$Stratum==1]) ) / (sqrt( ( sd(res$PropScore[res$PRED1D==1  & res$Stratum==1])^2 + sd(res$PropScore[res$PRED1D==0 & res$Stratum==1])^2 )/2 ))
abs( mean(res$PropScore[res$PRED1D==1 & res$Stratum==2]) - mean(res$PropScore[res$PRED1D==0 & res$Stratum==2]) ) / (sqrt( ( sd(res$PropScore[res$PRED1D==1  & res$Stratum==2])^2 + sd(res$PropScore[res$PRED1D==0 & res$Stratum==2])^2 )/2 ))
abs( mean(res$PropScore[res$PRED1D==1 & res$Stratum==3]) - mean(res$PropScore[res$PRED1D==0 & res$Stratum==3]) ) / (sqrt( ( sd(res$PropScore[res$PRED1D==1  & res$Stratum==3])^2 + sd(res$PropScore[res$PRED1D==0 & res$Stratum==3])^2 )/2 ))
abs( mean(res$PropScore[res$PRED1D==1 & res$Stratum==4]) - mean(res$PropScore[res$PRED1D==0 & res$Stratum==4]) ) / (sqrt( ( sd(res$PropScore[res$PRED1D==1  & res$Stratum==4])^2 + sd(res$PropScore[res$PRED1D==0 & res$Stratum==4])^2 )/2 ))
abs( mean(res$PropScore[res$PRED1D==1 & res$Stratum==5]) - mean(res$PropScore[res$PRED1D==0 & res$Stratum==5]) ) / (sqrt( ( sd(res$PropScore[res$PRED1D==1  & res$Stratum==5])^2 + sd(res$PropScore[res$PRED1D==0 & res$Stratum==5])^2 )/2 ))
abs( mean(res$PropScore[res$PRED1D==1 & res$Stratum==6]) - mean(res$PropScore[res$PRED1D==0 & res$Stratum==6]) ) / (sqrt( ( sd(res$PropScore[res$PRED1D==1  & res$Stratum==6])^2 + sd(res$PropScore[res$PRED1D==0 & res$Stratum==6])^2 )/2 ))

#SMDs for categorical variables (need to check balance on each category)
abs( mean(res$DSSEX[res$PRED1D==1 & res$Stratum==1]) - mean(res$DSSEX[res$PRED1D==0 & res$Stratum==1]) ) / (sqrt( ( sd(res$DSSEX[res$PRED1D==1  & res$Stratum==1])^2 + sd(res$DSSEX[res$PRED1D==0 & res$Stratum==1])^2 )/2 ))
abs( mean(res$DSSEX[res$PRED1D==1 & res$Stratum==2]) - mean(res$DSSEX[res$PRED1D==0 & res$Stratum==2]) ) / (sqrt( ( sd(res$DSSEX[res$PRED1D==1  & res$Stratum==2])^2 + sd(res$DSSEX[res$PRED1D==0 & res$Stratum==2])^2 )/2 ))
abs( mean(res$DSSEX[res$PRED1D==1 & res$Stratum==3]) - mean(res$DSSEX[res$PRED1D==0 & res$Stratum==3]) ) / (sqrt( ( sd(res$DSSEX[res$PRED1D==1  & res$Stratum==3])^2 + sd(res$DSSEX[res$PRED1D==0 & res$Stratum==3])^2 )/2 ))
abs( mean(res$DSSEX[res$PRED1D==1 & res$Stratum==4]) - mean(res$DSSEX[res$PRED1D==0 & res$Stratum==4]) ) / (sqrt( ( sd(res$DSSEX[res$PRED1D==1  & res$Stratum==4])^2 + sd(res$DSSEX[res$PRED1D==0 & res$Stratum==4])^2 )/2 ))
abs( mean(res$DSSEX[res$PRED1D==1 & res$Stratum==5]) - mean(res$DSSEX[res$PRED1D==0 & res$Stratum==5]) ) / (sqrt( ( sd(res$DSSEX[res$PRED1D==1  & res$Stratum==5])^2 + sd(res$DSSEX[res$PRED1D==0 & res$Stratum==5])^2 )/2 ))
abs( mean(res$DSSEX[res$PRED1D==1 & res$Stratum==6]) - mean(res$DSSEX[res$PRED1D==0 & res$Stratum==6]) ) / (sqrt( ( sd(res$DSSEX[res$PRED1D==1  & res$Stratum==6])^2 + sd(res$DSSEX[res$PRED1D==0 & res$Stratum==6])^2 )/2 ))
#.... continue with all variables, across all strata


#STEP 6: Re-stratify as necessary 

res$Stratum <- as.factor(as.numeric(cut_number(res$PropScore, 8)))   #can change number of strata

res$Stratum[res$Stratum==6] <- 5   #combines strata, e.g. 5 and 6

res$Stratum <- as.character(res$Stratum)  #temporarily changes Stratum to a character variable so we can rename some cases without dealing with creating new levels
res$Stratum[res$Stratum==10 & ( res$PropScore > median(res$PropScore[res$Stratum==10] , na.rm = T)) ] <- "10b"   #splits the upper half of stratum 10 into a new stratum called 10b
res$Stratum <- as.factor(res$Stratum)

#then recheck your balance, repeat step 6 as necessary

   #you can also re-do your propensity score model, with different variables or a different functional form


#Step 7:  Export balanced data to HLM for final analysis

#You need to create dummy variables for your stratum variable
library(fastDummies)
res <- dummy_cols(res, select_columns = "Stratum")

names(res) <- gsub("Stratum", "Strat", names(res))


level1 <- res 

level1 <- level1 %>% arrange(L2ID) %>% select (L2ID,  REP1, PRED1D, starts_with("Strat"))  #Can also include a few variables that don't balance

level1 <- level1 %>% na.omit(level1)

level2 <- res %>% arrange(L2ID) %>% group_by(L2ID) %>% slice(1) %>% select (L2ID, MSESC) #Need to include at least non-ID variable

export(level1, "./Thai/final_1.dta")  #.dta work files are working better than .sav when exporting with rio to HLM
export(level2, "./Thai/final_2.dta")


#additional options: 
#include treatment by stratum interactions
#include treatment by key covariate interactions for heterogeneity analysis
#include linear propensity score to absorb residual bias remaining  after stratification

#you can use the same stratification for other outcomes (e.g. math scores, behavioral outcomes) as long as the propensity model still makes sense


#STEP 9: Sensitivity Analysis

#Run the model you used to create your propensity score, predicting the outcome instead.  Select a powerful predictor.  Note the coefficient
coeff <- -.429

#then fine the mean difference between the treated and control groups on that predictor
meandiff <- mean (res$SESC[res$PRED1D==1]) - mean (res$SESC[res$PRED1D==0])

#estimated plausible bias is the absolute value of partial coefficient of the selected predictor multiplied by the mean difference in that predictor between the treatment and control groups

coeff*meandiff   #this is our estimated plausible bias
  #if our estimated treatment effect is greater than this, then it is robust to the existence of a powerful, unobserved confounding variable (conditional on the propensity score)
 

