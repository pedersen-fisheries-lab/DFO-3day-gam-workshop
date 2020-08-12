# example and practical scripts for part 02!

# load requisite packages
library('here')
library('mgcv')
library('ggplot2')
library('gratia')

# load the data
shrimp <- read.csv(here("data/trawl_nl.csv"))
# subset to just 2010's trawls
shrimp2010 <- subset(shrimp, year==2010)


## Exercise 1

# we tried fitting quasipoisson to the shrimp in the lecture
# what about other distributions?

# 1. copy this model and try out using the tw() and nb() distributions in place
#    of __OTHER_DISTRIBUTIONS__. Remember to rename your new models!
# 2. look at the summary() output of these models and compare to those in
#    the slides
# 3. if you have time, plot the models too

# spatial shrimp biomass
b_shrimp_template <- gam(shrimp ~ s(x, y),
                         data=shrimp2010,
                         family=__OTHER_DISTRIBUTIONS__,
                         method="REML")

## solution

# negative binomial
b_shrimp_nb <- gam(shrimp ~ s(x, y),
                         data=shrimp2010,
                         family=nb(),
                         method="REML")
summary(b_shrimp_nb)

# compare plot to gratia output
draw(b_shrimp_nb) + coord_equal()
plot(b_shrimp_nb, scheme=2, asp=1)


# tweedie
b_shrimp_tw <- gam(shrimp ~ s(x, y),
                         data=shrimp2010,
                         family=tw(),
                         method="REML")
summary(b_shrimp_tw)

draw(b_shrimp_tw) + coord_equal()
# ---

## Exercise 2

# we looked at te() and ti() in the slides, let's try a model with
# space and other effects

# 1. modify the model below to:
#   a. have a smooth of x,y and a tensor of temperature and depth, you
#       can choose whether the tensor is using te() or ti()
#   b. use tw(), nb() or quasipoisson() as the response distribution
# 2. look at the summary of this model and compare to those in the slides
# 3. plot the results!

mega_shrimp <- gam(shrimp ~ offset(log(area_trawled)) +
                        __YOUR_FORMULA_HERE__,
                data=shrimp2010,
                family=__OTHER_DISTRIBUTIONS__,
                method="REML")
