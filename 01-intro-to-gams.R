# try out some things in R

library(mgcv)
library(gratia)
library(dplyr)
library(tidyr)
library(ggplot2)


dat <- read.csv("data/trawl_nl.csv")


# 1. 1d
#  - simple models with `s()`

# inspect data
plot(log10(dat$depth), dat$temp_bottom)
# try a simple model
mod <- gam(temp_bottom~s(log10(depth)), data=dat, method="REML")
#  - `summary` and `plot`
# what does that look like?
plot(mod)
# is it flexible enough?
summary(mod)
# increase k
mod <- gam(temp_bottom~s(log10(depth), k=30), data=dat, method="REML")
# is it flexible enough?
summary(mod)
# better

#  - adding more than one smooth to yr model
# add year effect?
mod <- gam(temp_bottom~s(log10(depth), k=20) + s(year, k=10),
           data=dat, method="REML")
summary(mod)
# what does that look like?
plot(mod, pages=1)

