# Libraries
library(tidyverse)
library(rvest)
library(httr)
library(xgboost)
library(vip)
library(lubridate)
library(gt)
# Create a vector of current 7 swing states
swing <- data.frame(state = c("Arizona", "Georgia", "Michigan", "Nevada", "North Carolina", "Pennsylvania", "Wisconsin"), 
                    ev = c(11, 16, 15, 6, 16, 19, 10))