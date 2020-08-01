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
mod <- gam(temp_bottom~s(log10(depth), k=20) + s(year, k=15),
           data=dat, method="REML")
summary(mod)
# what does that look like?
plot(mod, pages=1)


# 2. "twiddling knobs in `gam`"

#  - moving beyond normal data (campylobacter?)
#    - exponential family and conditionally exp family (i.e., `family` + `tw` + `nb`)

# here we have trawls, so data are 0 or greater continous
# (assuming this is CPUE?)

# can try modelling per year totals using different responses
dat_yearly_cod <- dat %>%
  select(year, cod) %>%
  group_by(year) %>%
  mutate(catch = sum(cod)) %>%
  select(-cod) %>%
  distinct()
plot(dat_yearly_cod$year, dat_yearly_cod$catch)

mod_yearly <- gam(catch ~ s(year), data=dat_yearly_cod, method="REML",
                  family=nb())
summary(mod_yearly)
plot(mod_yearly)

# what about the spatial distribution of catches?
#  - more dimensions (something spatial)
#    - thin-plate 2d

ggplot(dat) +
  geom_point(aes(x=long, y=lat, colour=cod), size=0.5) +
  scale_colour_viridis_c(option="A", trans="log") +
  facet_wrap(~year) +
  theme_minimal()

# let's just use one year for speed
dat_2010 <- subset(dat, year==2010)

# spatial model of cod (should project coords
mod_space <- gam(cod ~ s(long, lat), data=dat_2010, method="REML",
                  family=tw)
summary(mod_space)

# tensors
mod_space_te <- gam(cod ~ te(long, lat), data=dat_2010, method="REML",
                  family=tw)
summary(mod_space_te)

par(mfrow=c(1,2))
plot(mod_space, scheme=2, main="tprs")
plot(mod_space_te, scheme=2, main="tensor")



#    - spatio-temporal modelling
#      - `te(x,y,t)` constructions

# this takes a while to fit, may want to make something simplier?
mod_space_time <- gam(cod ~ te(long, lat, year, d=c(2,1), k=c(40, 10)),
                      data=dat, method="REML", family=tw)
summary(mod_space_time)

plot(mod_space_time, scheme=2)


# 3. model checking and selection (follow-up on one or more of the previous data sets, spatial/spatiotemporal seem promising)
#  - `gam.check` is yr pal
#    - 4 plots

# going back to the first model
gam.check(mod)

# follow-up with ZiP later?
gam.check(mod_space_time)

#    - checking `k`
# did this informally above


#    - limitations with count data
# yikes this looks gross
gam.check(mod_space)
# better? (errr)
dsm::rqgam.check(mod_space)


#  - fitting to the residuals
# need to do something better here
dat_2010$spresids <- residuals(mod_space)
mod_resids_space <- gam(spresids ~ s(long, lat),
                        data=dat_2010, method="REML", family=gaussian)
summary(mod_resids_space)


#  - `AIC` etc
# addin depth
mod_space_depth <- gam(cod ~ te(long, lat, k=15)+
                             s(depth, k=20),
                       data=dat_2010, method="REML", family=tw)
summary(mod_space_depth)
AIC(mod_space_depth, mod_space)

#  - shrinkage and `select=TRUE`
# hmmm not sure this is a good example?
mod_space_depth_select <- gam(cod ~ te(long, lat, k=15)+
                             s(depth, k=20) +
                             s(temp_bottom, k=10),
                       select=TRUE,
                       data=dat_2010, method="REML", family=tw)
mod_space_depth_ts <- gam(cod ~ te(long, lat, k=15, bs="ts")+
                             s(depth, k=20, bs="ts")+
                             s(temp_bottom, k=10),
                       data=dat_2010, method="REML", family=tw)
# 
summary(mod_space_depth_select)
summary(mod_space_depth_ts)


#4. predictions and variance
#  - `predict` (`exclude=`?)
#  - what are those bands
#  - getting summaries (abundance estimates?)
#  - posterior simulation


#5. more complex models
#  - other smoothers (each needs an example)
#    - random effects
# add a stratum random effect?
dat_2010$strata <- as.factor(dat_2010$strata)
mod_space_depth_select <- gam(cod ~ te(long, lat, k=15)+
                             s(depth, k=20) +
                             s(temp_bottom, k=10) +
                             s(strata, bs="re"),
                       select=TRUE,
                       data=dat_2010, method="REML", family=tw)

#    - cyclic smoothers
#    - soap
#    - MRFs
#    - factor-smooths
# could revisit the temperature-depth model?
# multi-species?
#  - other responses:
#    - `ocat`/gev/`mvn`/etc


