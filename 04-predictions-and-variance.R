# example and practical scripts for part 04!

# load requisite packages
library('here')
library('mgcv')
library('gratia')
library('ggplot2')
library('dplyr')

# load the data
shrimp <- read.csv(here("data/trawl_nl.csv"))
## shrimp <- read.csv("data/trawl_nl.csv")

## fit the species richness model
m_rich <- gam(richness ~ s(year), data = shrimp,
              family = poisson, method = "REML")

## Exercise 1

# Let's explore some of the plotting options for GAMs and how we can control what kinds of intervals are drawn

# 1. Using `plot()`, draw the estimated smooth for model `m_rich`
# 2. Draw the estimated smooth again, this time using `seWithMean = TRUE`. Does it change the plot much? Think why this is the case.
# 3. Using `draw()`, draw the estimated smooth
# 4. Repeat 3 but this time account for tune uncertainty due to estimating the smoothness parameters using `unconditional = TRUE`

# Now let's explore working with smooths in a little more detail. First evaluate the smooth over a range of values for `year`
year_sm <- evaluate_smooth(m_rich, "s(year)")
year_sm

# We can add a confidence interval to `year_sm` by hand or use the `confint()` methof
year_sm <- confint(m_rich, "s(year)")
year_sm

## Exercise 2

## Using the spatiotemporal example, we saw how to generate marginal predictions using only one of the model terms, and we were able to generate a prediction for the temporal trend averaged over space. First we'll refit the decomposed spatiotemporal model
m_ti <- gam(shrimp ~ offset(log(area_trawled)) +
                ti(x, y, year, d = c(2, 1), bs = c("tp", "cr"), k = c(20, 5)) +
                s(x, y, bs = "tp", k = 20) +
                s(year, bs = "cr", k = 5),
            data = shrimp, family = tw, method = "REML")

## This time, generate predictions for the marginal spatial effect, averaged over time.

## 1. Look at the model summary and identify the name of the smooths you want to exclude. Note down exactly the names of the smooths as shown in the output.

## 2. Generate some new data to predict at. Remember we want the full spatial grid, but we only need a dummy value for `year` and `area_trawled`. To help you, I've provided a template below, which you need to edit to get the data you want:
new_data <- with(shrimp, expand.grid(x    = seq_min_max(x, n = 100),
                                     y    = seq_min_max(y, n = 100),
                                     year = 2010, # dummy year
                                     area_trawled = median(area_trawled)))

## 3. Predict from the model for the values in `new_data`
spatial_pred <- predict(m_ti, newdata = new_data,
                        exclude = c("ti(x,y,year)", "s(year)"))
spatial_pred <- bind_cols(as_tibble(new_data), tibble(fit = spatial_pred))

spatial_pred

## 4. Extract the inverse of the link function from the model `m_ti`
ilink <- inv_link(m_ti)

## 5. Set grid cells in the prediction data that are too far from the observation data
too_far <- exclude.too.far(new_data$x, new_data$y, shrimp$x, shrimp$y, dist = 0.1)
spatial_pred <- spatial_pred %>% mutate(biomass = ilink(fit),
                                        biomass = case_when(too_far ~ NA_real_,
                                                            TRUE ~ biomass))
spatial_pred

## 6. Plot the marginal spatial effect
ggplot(spatial_pred,
       aes(x    = x,
           y    = y,
           fill = biomass)) +
    geom_raster() +
    scale_fill_viridis_c(option = "plasma") +
    coord_equal()

## Exercise 3

## Using `fitted_samples()`, repeat the final example computing the total biomass over the spatial domain, but for 2014 instead of 2007

## 1. Create data to predict at
sp_new <- with(shrimp, expand.grid(x    = __________,
                                   y    = __________,
                                   year = __________,
                                   area_trawled = median(area_trawled)))

## 2. Draw the rest of the owl! (Follow the example on slide 45)

## 3. Compare the mean of the posterior distribution for 2014 with the one for 2007 (from the slides). Are they different?

## 4. Bonus points! How might you use posterior simulation to estimated the difference in total biomass between 2007 and 2014.
