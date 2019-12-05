
## This is an example of reliability analysis in R from a two-test experiment ##


library(tidyverse)

# A data frame of two tests to calculate reliability from 
df <- data.frame(t1 = c(41.6, 115.3, 48.4, 59.9, 67.2, 63.4, 94.2, 130, 98.8, 78.6, 38), 
                 t2 = c(38, 114.4, 50.9, 59.7, 66.7, 62.8, 91.4, 136.6, 88.5, 61.7, 38.5)) 


### Calculation of technical error 

# Technical error is defined as 2 * (SD of change / sqrt(2))
# First we calculate the change score (Trial 2 - Trial 1), second we can calculate the absolute TE
# and finally the relative TE as a percentage of the mean test-score.

df %>%
        mutate(change = t2 - t1) %>%
        group_by() %>%
        summarise(sd.change = sd(change), 
                  mean.test = mean(c(t1, t2)), 
                  te.abs = 2*(sd.change / sqrt(2)), 
                  te.relative = (te.abs / mean.test) * 100) %>%
        print()


### Calculation of smallest worthwhile change
# SWC is defined as 0.2 * between subject SD. 
df %>%
        group_by() %>%
        summarise(sd = sd(c(t1, t2)), 
                  swc = 0.2 * sd) %>%
         print()




