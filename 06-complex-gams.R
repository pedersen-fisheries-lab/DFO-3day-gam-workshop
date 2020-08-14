
#6. more complex models

#Loading required libraries ####

library(mgcv)
library(dplyr)
library(ggplot2)
library(gratia)
library(sf)


# part 1: Choosing a smooth to model a relationship ####

# MRF smooths ####

# loading the stratum map and trawl data

trawl_strata <- read_sf("data/trawl_strata.shp") %>%
  group_by(stratum)%>%
  summarize()%>% #merging a couple strata that were duplicated
  mutate(stratum = factor(stratum))

trawls <- read.csv("data/trawl_nl.csv")

#filtering for only 2010 data and data in strata that occur in the trawl_stratum file
trawls_2010 <- filter(trawls,
                      year==2010,
                      stratum %in% trawl_strata$stratum) %>%
  mutate(stratum = factor(stratum, levels = trawl_strata$stratum))



# for mgcv, we want a penalty matrix, taking into account neighbourhoods
nl_strata_penalty <- trawl_strata %>%
  st_buffer(dist = 0.01)%>%
  st_intersects(sparse= FALSE)

#The penalty should have -1 on the off-diagonals for any two touching strata
nl_strata_penalty <- -nl_strata_penalty

# The diagonal should be equal to or greater than the negative sum of the columns
diag(nl_strata_penalty) <- -(rowSums(nl_strata_penalty)- diag(nl_strata_penalty))

rownames(nl_strata_penalty) <- colnames(nl_strata_penalty) <-  trawl_strata$stratum


#Note: Always set drop.used.levels = FALSE when using MRF smooths!
mod_shrimp_mrf <- gam(shrimp ~ s(stratum, bs="mrf",k=10,
                                 xt=list(penalty=nl_strata_penalty)),
               data=trawls_2010,
               method="REML",
               drop.unused.levels =  FALSE,
               family=tw())

summary(mod_shrimp_mrf)

ggplot(trawl_strata) +
  geom_sf(aes(fill = predict(mod_shrimp_mrf,
                             type = "response",
                             newdata = trawl_strata)))+
  geom_point(data= trawls_2010,aes(x=long,y=lat),
             size=0.2,
             col = "white")+
  scale_fill_viridis_c("Shrimp density\n(kg/km^2)")




# Time series analyses ####

# GAMs are ideal for decompositing time series. We'll work with a new data set to show this:


mendota_daphnia <- zooplankton %>%
  filter(lake=="Mendota",
         taxon =="D. mendotae")

# key variables here are day (day of year), year, and density_adj
# which is measured in 1000's of individuals per m^3

head(mendota_daphnia)

#We will use a Gamma distribution with a log link to model this:

mod_daphnia_ts1 <- gam(density_adj ~
                           s(year, bs= "tp", k = 10)  #yearly effect
                         + s(day , bs= "cc", k = 12),  #seasonal effect
                       family = Gamma(link = "log"),
                       knots = list(day = c(0,365)),
                       data= mendota_daphnia,
                       method = "REML")

summary(mod_daphnia_ts1)
draw(mod_daphnia_ts1)


# We can also use alternative smoothers for the yearly effect:

mod_daphnia_ts2 <- gam(density_adj ~
                         s(year, bs= "tp", m=1, k = 10)  #yearly effect
                       + s(day , bs= "cc", k = 12),  #seasonal effect
                       family = Gamma(link = "log"),
                       knots = list(day = c(0,365)),
                       data= mendota_daphnia,
                       method = "REML")

summary(mod_daphnia_ts2)
draw(mod_daphnia_ts2)


#years are independent of one another
mod_daphnia_ts3 <- gam(density_adj ~
                         s(year_f, bs= "re")  #yearly effect
                       + s(day , bs= "cc", k = 12),  #seasonal effect
                       family = Gamma(link = "log"),

                       knots = list(day = c(0,365)),
                       data= mendota_daphnia,
                       method = "REML")

summary(mod_daphnia_ts3)
draw(mod_daphnia_ts3)


# Exercise:  #### It is possible to allow for seasonal effects that vary over
# time. Using the te() function, create an interaction of year and day to model
# a varying seasonal effect for the mendota daphnia data. Use a thin-plate
# spline for the yearly basis function

# as a hint: you can set different basis functions for each marginal term in a
# te() smooth by passing it a vector, like: bs = c("tp", "re")


mod_daphnia_interact <- gam(density_adj ~ te(_____, bs= _____, k = _____),
                       family = Gamma(link = "log"),
                       data= mendota_daphnia,
                       knots = list(day = c(0,365)),
                       method = "REML")

draw(mod_daphnia_interact)


# Varying coefficient models and HGAMs ####

# The `by=` in the `s()` function lets you have a smoothly varying covariate in
# a GAM

# For instance, let's say we want to know how shrimp abundance varies with
# species richness:

ggplot(trawls,aes(richness, shrimp+1)) +
  geom_point()+
  geom_smooth(method=lm)+scale_y_log10()

mod_shrimp_rich1 <- gam(shrimp~ richness, family = tw, method = "REML", data= trawls)
summary(mod_shrimp_rich1)

# But how does this relationship vary by year?


mod_shrimp_rich2 <- gam(shrimp~ s(year, by= richness)
                              + s(year),
                        family = tw,
                        method = "REML",
                        data= trawls)

summary(mod_shrimp_rich2)

plot(mod_shrimp_rich2,page=1, scale=0)

#Let's see if there is any evidence that the relationship varies by year:
mod_shrimp_rich3 <- gam(shrimp~ s(year, by= richness)
                        + s(year),
                        family = tw,
                        method = "REML",
                        select = TRUE,
                        data= trawls)

summary(mod_shrimp_rich3)

plot(mod_shrimp_rich3,page=1, scale=0)

# It is also possible to have functional relationships that vary with discrete variables.
# We'll use the mendota data here:


mendota_zooplankton <- zooplankton %>%
  filter(lake=="Mendota",
         year==1989) %>%
  mutate(taxon = factor(taxon))

mod_zoo1 <- gam(density_adj ~ s(day, by = taxon,bs="cc")+
                              s(taxon, bs="re"),
                family = Gamma(link = "log"),
                method= "REML",
                knots = list(day = c(0,365)),
                data = mendota_zooplankton)

summary(mod_zoo1)
draw(mod_zoo1)


# We can also set this up as a hierarchical model to assume that all species
# have similarly smooth curves:

mod_zoo2 <- gam(density_adj ~ s(day,  taxon,bs="fs",xt =list(bs="cc")),
                family = Gamma(link = "log"),
                method= "REML",
                knots = list(day = c(0,365)),
                data = mendota_zooplankton)

summary(mod_zoo2)
draw(mod_zoo2)

#See our 2018 paper for WAY more details on this approach: Pedersen, E.J.,
#Miller, D.L., Simpson, G.L., and Ross, N. (2019). Hierarchical generalized
#additive models in ecology: an introduction with mgcv. PeerJ 7, e6876.


# part 2: Choosing a family to fit your data ####

library('ggplot2')
library('mgcv')
library('gratia')
library('dplyr')
library('tidyr')
library('sf')


# first we'll look at proportion data ####

# Beta regression is specifically about models for continous fractions; if you
# have counts of presence and absence, you should just use the binomial family

# e.g. :

shrimp_presence <- trawls%>%
  filter(!is.na(shrimp),
         !is.na(stratum),
         stratum %in% trawl_strata$stratum)%>%
  mutate(stratum = factor(stratum, levels =levels(trawl_strata$stratum)))%>%
  group_by(stratum, year)%>%
  summarize(n_trawls = n(),
            n_present = sum(shrimp>0),
            x = mean(x),
            y = mean(y))

mod_shrimp_presence <-  gam(cbind(n_present, n_trawls-n_present) ~ s(x,y,k=50),
                            data = shrimp_presence,
                            method = "REML",
                            family =  binomial)

draw(mod_shrimp_presence)

# Beta regression is for actual continous fractions:

mod_shrimp_relfrac <-  gam(shrimp/total ~ s(x,y,k=50),
                            data = trawls,
                            method = "REML",
                            family =  betar)

draw(mod_shrimp_relfrac)

#Let's look at a second example:

daphnia_dominance <- mendota_zooplankton%>%
  group_by(day,year,year_f)%>%
  summarize(daphnia = density_adj[taxon=="D. mendotae"][1],
            total = sum(density_adj))%>%
  mutate(daphnia_frac = daphnia/total)

mod_daphnia_dom <- gam(daphnia_frac~ s(day, bs="cc", k=12),
                       data= daphnia_dominance,
                       family = betar,
                       method="REML")

draw(mod_daphnia_dom)

# other useful families for different data types: scat: t-distribution, for
# continous data with heavier tails than the normal distribution ziP:
# zero-inflated Poisson, where there's some fixed probability of seeing a zero
# in all data
#cox.ph: for censored data
#ocat: if you have ordered categorical data (so level 1 < level 2 < level 3...)
#the ocat family can work, but read up on what it's doing carefully


# Distributional models ####

#mgcv also now includes models that allow for different predictors for the mean
#and variance, or for different parameters in the same model

# examples include:
# family = ziplss for zero-inflated data, where the rate of zero-inflation varies across the study area
# family = twlss - for tweedie data where the scale and shape parameters (rho and p) can also vary with predictors
# family = mvn - multivariate normal data, for species distributions, other correlated data
# family = multinom - multinomial data, where categorical variables aren't ordered

# Let's look at a zero-inflated model for richness (even though we know it's
# definitely not zero-inflated!)

mod_richess_zinf <- gam(list(richness~s(x,y,k=10),
                             ~ s(year,k=4)),
                        data = trawls,
                        family = ziplss,
                        method = "REML")

summary(mod_richess_zinf)
draw(mod_richess_zinf)


#Now we'll try a more meaningfull model for varying mean and scale for shrimp:
mod_shrimp_lss <- gam(list(shrimp~s(x,y,k=20),
                           ~ 1,
                           ~ s(x,y, k = 10)),
                        data = trawls,
                        family = twlss,
                        method = "REML")

summary(mod_shrimp_lss)
draw(mod_shrimp_lss)


# The last one to look at is categorical regression. This can be a minefield
# for interpretation, so be careful when working with these models

#multinom needs the categories as integers, with zero being the baseline
shrimp_categories <- trawls %>%
  mutate(shrimp_level = case_when(shrimp== 0~0, #no shrimp
                                  shrimp < 100~1, #shrimp at commerically insignificant levels
                                  shrimp > 100~2)) #commerical densities of shrimp

# you need one formula for each category level except the first.
mod_shrimp_multinom <- gam(list(shrimp_level ~ s(x,y, k=20) + s(year,k=5),
                                ~ s(x,y, k =20) + s(year, k= 5)),
                           data= shrimp_categories,
                           method= "REML",
                           family =multinom(K = 2)) #K is the # of categories - 1


summary(mod_shrimp_multinom)
draw(mod_shrimp_multinom)
