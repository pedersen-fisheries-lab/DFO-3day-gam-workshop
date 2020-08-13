## ----setup, include=FALSE, cache=FALSE----------------------------------------
library('here')
library('mgcv')
library('gratia')
library('ggplot2')
library('sf')
library('dplyr')


## ----load-shrimp--------------------------------------------------------------
shrimp <- read.csv(here('data', 'trawl_nl.csv'))


## ----shrimp-richness----------------------------------------------------------
m_rich <- gam(richness ~ s(year),
              family = poisson,
              method = "REML",
              data = shrimp)


## ----richness-violin, fig.height=5, fig.width=5, echo=FALSE-------------------
ggplot(shrimp) +
  geom_violin(aes(x = richness, y = factor(year))) +
    labs(x = "Number of species", y = "Year")


## ----biom-space-time-plot, fig.height=8, fig.width=15, echo=FALSE-------------
coast <- read_sf(here("data/nl_coast.shp"))
ggplot(shrimp) +
  geom_point(aes(x = long, y = lat, size = shrimp), alpha=.5) +
  geom_sf(data = coast) +
  facet_wrap(~year, ncol = 5)


## ----fit-shrimp-space-time----------------------------------------------------
m_spt <- gam(shrimp ~ te(x, y, year, d = c(2,1), bs = c('tp', 'cr'), k = c(20, 5)),
             data = shrimp,
             family = tw,
             method = "REML")


## ----plot-richness-model------------------------------------------------------
plot(m_rich)


## ----draw-richness-model------------------------------------------------------
draw(m_rich)


## ----plot-conf-band-plus-posterior-smooths, fig.height = 5--------------------
sm_fit <- evaluate_smooth(m_rich, 's(year)') # tidy data on smooth
sm_post <- smooth_samples(m_rich, 's(year)', n = 20, seed = 42) # more on this later
draw(sm_fit) + geom_line(data = sm_post, aes(x = .x1, y = value, group = draw),
                         alpha = 0.3, colour = 'red')

## ----predict-newdata----------------------------------------------------------
new_year <- with(shrimp, tibble(year = seq(min(year), max(year), length.out = 100)))
pred <- predict(m_rich, newdata = new_year, se.fit = TRUE, type = 'link')
pred <- bind_cols(new_year, as_tibble(as.data.frame(pred)))
pred


## ----predict-newdata-resp-----------------------------------------------------
ilink <- inv_link(m_rich)                         # inverse link function
crit <- qnorm((1 - 0.89) / 2, lower.tail = FALSE) # or just `crit <- 2`
pred <- mutate(pred, richness = ilink(fit),
               lwr = ilink(fit - (crit * se.fit)), # lower...
               upr = ilink(fit + (crit * se.fit))) # upper credible interval
pred


## ----plot-predictions-richness, fig.height = 4--------------------------------
ggplot(pred, aes(x = year)) +
    geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = 0.2) +
    geom_line(aes(y = richness)) + labs(y = "Species richness", x = NULL)


## ----spt-example-predict------------------------------------------------------
sp_new <- with(shrimp, expand.grid(x = seq_min_max(x, n = 100),
                                   y = seq_min_max(y, n = 100),
                                   year = unique(year)))
sp_pred <- predict(m_spt, newdata = sp_new, se.fit = TRUE) # link scale is default
sp_pred <- bind_cols(as_tibble(sp_new), as_tibble(as.data.frame(sp_pred)))
sp_pred


## ----spt-example-response-scale-----------------------------------------------
ilink <- inv_link(m_spt)
too_far <- exclude.too.far(sp_pred$x, sp_pred$y, shrimp$x, shrimp$y, dist = 0.1)
sp_pred <- sp_pred %>% mutate(biomass = ilink(fit),
                              biomass = case_when(too_far ~ NA_real_,
                                                  TRUE ~ biomass))
sp_pred


## ----spt-example-plot, fig.height = 5.5---------------------------------------
ggplot(sp_pred, aes(x = x, y = y, fill = biomass)) + geom_raster() +
    scale_fill_viridis_c(option = "plasma") + facet_wrap(~ year, ncol = 5) +
    coord_equal()

## ----plotting the uncertainty-------------------------------------------------
ggplot(sp_pred, aes(x = x, y = y, fill = se.fit)) + geom_raster() +
    scale_fill_viridis_c(option = "plasma") + facet_wrap(~ year, ncol = 5) +
    coord_equal()

## ----plotting the confidence interval-----------------------------------------
sp_pred <- sp_pred %>% mutate(lwr = ilink(fit - (2 * se.fit)),
                              upr = ilink(fit + (2 * se.fit)))

ggplot(sp_pred, aes(x = x, y = y, fill = lwr)) + geom_raster() +
    scale_fill_viridis_c(option = "plasma") + facet_wrap(~ year, ncol = 5) +
    coord_equal() +
    labs(title = "Lower 95% interval")

ggplot(sp_pred, aes(x = x, y = y, fill = upr)) + geom_raster() +
    scale_fill_viridis_c(option = "plasma") + facet_wrap(~ year, ncol = 5) +
    coord_equal() +
    labs(title = "Upper 95% interval")

## ----vis.gam------------------------------------------------------------------
vis.gam(m_spt, view = c("x", "y"), type = "response", plot.type = "contour", asp = 1,
        too.far = 0.1)
## median year (or year closest to media)

## ----vis.gam 2----------------------------------------------------------------
vis.gam(m_spt, view = c("x", "y"), cond = list(year = 2007),
        type = "response", plot.type = "contour", asp = 1,
        too.far = 0.1)

## ----show-m-spt---------------------------------------------------------------
m_spt


## ----shrimp-ti-model----------------------------------------------------------
m_ti <- gam(shrimp ~ ti(x, y, year, d = c(2, 1), bs = c("tp", "cr"), k = c(20, 5)) +
                s(x, y, bs = "tp", k = 20) +
                s(year, bs = "cr", k = 5),
            data = shrimp, family = tw, method = "REML")


## ----summary-spt-ti-----------------------------------------------------------
summary(m_ti)


## ----pred-data-ti-model-------------------------------------------------------
ti_new <- with(shrimp, expand.grid(x = mean(x), y = mean(y),
                                   year = seq_min_max(year, n = 100)))

ti_pred <- predict(m_ti, newdata = ti_new, se.fit = TRUE,
                   exclude = c("ti(x,y,year)", "s(x,y)")) #<<

ti_pred <- bind_cols(as_tibble(ti_new), as_tibble(as.data.frame(ti_pred))) %>%
    mutate(biomass = ilink(fit),
           lwr = ilink(fit - (crit * se.fit)),
           upr = ilink(fit + (crit * se.fit)))


## ----pred-data-ti-model-terms, results = "hide"-------------------------------
predict(m_ti, newdata = ti_new, se.fit = TRUE, terms = "s(year)")


## ----plot-ti-marginal-trend, fig.height = 5-----------------------------------
ggplot(ti_pred, aes(x = year)) +
    geom_ribbon(aes(ymin = lwr, ymax = upr), alpha = 0.3) +
    geom_line(aes(y = biomass)) +
    labs(y = "Biomass", x = NULL)


## ----plot-conf-band-plus-posterior-smooths, fig.height = 5, echo = FALSE------
sm_fit <- evaluate_smooth(m_rich, 's(year)') # tidy data on smooth
sm_post <- smooth_samples(m_rich, 's(year)', n = 20, seed = 42) # more on this later
draw(sm_fit) + geom_line(data = sm_post, aes(x = .x1, y = value, group = draw),
                         alpha = 0.3, colour = 'red')


## ----richness-coefs-----------------------------------------------------------
sm_year <- get_smooth(m_rich, "s(year)") # extract the smooth object from model
idx <- gratia:::smooth_coefs(sm_year)    # indices of the coefs for this smooth
idx

beta <- coef(m_rich)                     # vector of model parameters


## ----richness-vcov------------------------------------------------------------
Vb <- vcov(m_rich) # default is the bayesian covariance matrix


## ----richness-xp-matrix-------------------------------------------------------
new_year <- with(shrimp, tibble(year = seq_min_max(year, n = 100)))
Xp <- predict(m_rich, newdata = new_year, type = 'lpmatrix')
dim(Xp)


## ----richness-reduce-xp-------------------------------------------------------
Xp <- Xp[, idx, drop = FALSE]
dim(Xp)


## ----richness-simulate-params-------------------------------------------------
set.seed(42)
beta_sim <- rmvn(n = 20, beta[idx], Vb[idx, idx, drop = FALSE])
dim(beta_sim)


## ----richness-posterior-draws, fig.height = 5, fig.show = 'hide'--------------
sm_draws <- Xp %*% t(beta_sim)
dim(sm_draws)
matplot(sm_draws, type = 'l')


## ----richness-posterior-draws, fig.height = 5, fig.width = 5, echo = FALSE, results = 'hide'----
sm_draws <- Xp %*% t(beta_sim)
dim(sm_draws)
matplot(sm_draws, type = 'l')


## ----plot-posterior-smooths, fig.height = 5-----------------------------------
sm_post <- smooth_samples(m_rich, 's(year)', n = 20, seed = 42)
draw(sm_post)


## ----posterior-sim-model------------------------------------------------------
beta <- coef(m_rich)   # vector of model parameters
Vb <- vcov(m_rich)     # default is the bayesian covariance matrix
Xp <- predict(m_rich, type = 'lpmatrix')
set.seed(42)
beta_sim <- rmvn(n = 1000, beta, Vb) # simulate parameters
eta_p <- Xp %*% t(beta_sim)        # form linear predictor values
mu_p <- inv_link(m_rich)(eta_p)    # apply inverse link function

mean(mu_p[1, ]) # mean of posterior for the first observation in the data
quantile(mu_p[1, ], probs = c(0.025, 0.975))


## ----posterior-sim-model-hist, fig.height = 5---------------------------------
ggplot(tibble(richness = mu_p[587, ]), aes(x = richness)) +
    geom_histogram() + labs(title = "Posterior richness for obs #587")


## ----richness-fitted-samples, fig.height = 4.5--------------------------------
rich_post <- fitted_samples(m_rich, n = 1000, newdata = shrimp, seed = 42)
ggplot(filter(rich_post, row == 587), aes(x = fitted)) +
    geom_histogram() +
    labs(title = "Posterior richness for obs #587", x = "Richness")


## ----total-biomass-posterior-1------------------------------------------------
sp_new <- with(shrimp, expand.grid(x = seq_min_max(x, n = 100),
                                   y = seq_min_max(y, n = 100),
                                   year = 2007))
Xp <- predict(m_spt, newdata = sp_new, type = "lpmatrix")

## work out now which points are too far now
too_far <- exclude.too.far(sp_new$x, sp_new$y, shrimp$x, shrimp$y, dist = 0.1)

beta <- coef(m_spt)   # vector of model parameters
Vb <- vcov(m_spt)     # default is the bayesian covariance matrix
set.seed(42)
beta_sim <- rmvn(n = 1000, beta, Vb) # simulate parameters
eta_p <- Xp %*% t(beta_sim)        # form linear predictor values
mu_p <- inv_link(m_spt)(eta_p)     # apply inverse link function


## ----total-biomass-posterior-2, dependson = -1--------------------------------
mu_copy <- mu_p              # copy mu_p
mu_copy[too_far, ] <- NA     # set cells too far from data to be NA
total_biomass <- colSums(mu_copy, na.rm = TRUE)  # total biomass over the region

mean(total_biomass)
quantile(total_biomass, probs = c(0.025, 0.975))


## ----total-biomass-histogram, echo = FALSE------------------------------------
ggplot(tibble(biomass = total_biomass), aes(x = biomass)) +
    geom_histogram()


## ----biomass-fitted-samples-example-------------------------------------------
bio_post <- fitted_samples(m_spt, n = 1000,
                           newdata = sp_new[!too_far, ],
                           seed = 42) %>%
    group_by(draw) %>%
    summarise(total = sum(fitted),
              .groups = "drop_last")

with(bio_post, mean(total))
with(bio_post, quantile(total, probs = c(0.025, 0.975)))


## ----biomass-fitted-samples-plot, fig.width = 5, fig.height = 5---------------
ggplot(bio_post, aes(x = total)) +
    geom_histogram() +
    labs(x = "Total biomass")

