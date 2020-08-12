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

# here I've fiddled with k to make it really big, see later slides/examples
# to see how to do this!

# negative binomial
b_shrimp_nb <- gam(shrimp ~ s(x, y, k=160),
                         data=shrimp2010,
                         family=nb(),
                         method="REML")

# things to look at:
# check that the "Family:" line is what you expect
# check that the number in brackets (the negative binomial parameter) is estimated
summary(b_shrimp_nb)

# compare plot to gratia output
plot(b_shrimp_nb, scheme=2, asp=1)
# here coord_equal() does the same as asp=1 and sets the aspect ratio
draw(b_shrimp_nb) + coord_equal()



# tweedie
b_shrimp_tw <- gam(shrimp ~ s(x, y, k=160),
                         data=shrimp2010,
                         family=tw(),
                         method="REML")
# things to look at:
# check that the "Family:" line is what you expect
# check that the number in brackets (the Tweedie power parameter) is estimated
summary(b_shrimp_tw)

# compare this to the above nb plot
# not much difference (general shape is the same)
# but the scale is different!
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

mega_shrimp <- gam(shrimp ~ __YOUR_FORMULA_HERE__,
                   data=shrimp2010,
                   family=__OTHER_DISTRIBUTIONS__,
                   method="REML")

## solution

# I'll use Tweedie (tw()) for all these examples to keep things simple

# building the model with te()
mega_shrimp_te <- gam(shrimp ~ s(x, y, k=40) +
                        # note here I prefer to specify 2 ks to remind myself that
                        # this will lead to 25 basis functions!
                               te(temp_bottom, depth, k=c(6, 6)),
                      data=shrimp2010,
                      family=tw(),
                     method="REML")
summary(mega_shrimp_te)

# now with ti()
mega_shrimp_ti <- gam(shrimp ~ s(x, y, k=40) +
                               ti(temp_bottom, depth, k=c(6, 6)) +
                               ti(temp_bottom, k=6) +
                               ti(depth, k=6),
                      data=shrimp2010,
                      family=tw(),
                      method="REML")
summary(mega_shrimp_ti)

# notes/things to think about
#  - the sum of the EDFs for the ti() terms in mega_shrump_ti should be
#    roughly the EDF for the te() term in mega_shrimp_te
#  - in the ti() formulation we see that temp_bottom has EDF ~= 1 & isn't
#    significant

# gratia produces much nicer plots!
draw(mega_shrimp_te)
draw(mega_shrimp_ti)

