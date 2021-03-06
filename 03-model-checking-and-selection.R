library(mgcv)

trawl_data <- read.csv("data/trawl_nl.csv")
trawl_data_2010 <- trawl_data[trawl_data$year == 2010, ]

shrimp <- gam(
  shrimp ~ s(depth) + s(temp_bottom),
  data = trawl_data_2010,
  family = gaussian,
  method = "REML")

summary(shrimp)

plot(shrimp, pages = 1)
plot(shrimp, residuals = TRUE, cex=0.5, pch=21, pages = 1)

par(mfrow = c(2,2))
gam.check(shrimp)
par(mfrow = c(1,1))

concurvity(shrimp, full = TRUE)
concurvity(shrimp, full = FALSE)
lapply(concurvity(shrimp, full = FALSE), round, 2)
hist(trawl_data_2010$shrimp)
hist(log(trawl_data_2010$shrimp))

shrimp_log <- gam(
  shrimp ~ s(depth) + s(temp_bottom),
  data = trawl_data_2010,
  family = gaussian(link = "log"),
  method = "REML")

summary(shrimp_log)
plot(shrimp_log, residuals = TRUE, cex=0.5, pch=21, pages = 1)
plot(shrimp_log, residuals = FALSE, cex=0.5, pch=21, pages = 1)

par(mfrow = c(2,2))
gam.check(shrimp_log)
par(mfrow = c(1,1))

shrimp_tw <- gam(
  shrimp ~ s(depth) + s(temp_bottom),
  data = trawl_data_2010,
  family = tw,
  method = "REML")

summary(shrimp_tw)
plot(shrimp_tw, residuals = TRUE, cex=0.5, pch=21, pages = 1)

par(mfrow = c(2,2))
gam.check(shrimp_tw)
par(mfrow = c(1,1))

shrimp_tw2 <- gam(
  shrimp ~ s(depth, k = 20) + s(temp_bottom, k = 20),
  data = trawl_data_2010,
  family = tw,
  method = "REML")

summary(shrimp_tw2)
plot(shrimp_tw2, residuals = TRUE, cex=0.5, pch=21, pages = 1)

par(mfrow = c(2,2))
gam.check(shrimp_tw2)
par(mfrow = c(1,1))

shrimp_tw_te <- gam(
  shrimp ~ te(depth, temp_bottom),
  data = trawl_data_2010,
  family = tw,
  method = "REML")

summary(shrimp_tw_te)
plot(shrimp_tw_te, pages = 1, residuals = TRUE, cex=0.5, pch=21, scheme = 2)

par(mfrow = c(2,2))
gam.check(shrimp_tw_te)
par(mfrow = c(1,1))

# ---- Exercise ----

# Fit a model of bottom temperature, using smooths `stratum`, `depth`,
# and `x`, `y` coordinates

# Plot the model, examine gam.check, diagnostic plots and concurvity

# Modify the model to reduce any poor diagnostics outcomes. You may modify smooths,
# add or remove variables, change `k` values, or change the distribution.

temp <- gam(
  temp_bottom ~ __YOUR_FORMULA_HERE__
  data = trawl_data_2010,
  family = __YOUR_DISTRIBUTION_HERE__,
  method = "REML")


# --- Back to it! Model selection ---

trawl_data_extra <- trawl_data_2010
trawl_data_extra$var1 <- rnorm(nrow(trawl_data_extra))


shrimp_tw_all <- gam(
  shrimp ~ s(depth) + s(x) + s(y) + s(temp_bottom) + s(stratum) + s(var1),
  data = trawl_data_extra,
  family = tw,
  method = "REML")

summary(shrimp_tw_all)
plot(shrimp_tw_all, pages = 1, residuals = TRUE, cex=0.5, pch=21, scheme = 2, scale = 0)

shrimp_tw_sel <- gam(
  shrimp ~ s(depth) + s(x) + s(y) + s(temp_bottom) + s(stratum) + s(var1),
  data = trawl_data_extra,
  family = tw,
  method = "REML",
  select = TRUE)

summary(shrimp_tw_sel)
plot(shrimp_tw_sel, pages = 1, residuals = TRUE, cex=0.5, pch=21, scheme = 2, scale = 0)

par(mfrow = c(2,2))
gam.check(shrimp_tw_sel)
par(mfrow = c(1,1))


# ---- Exercise ----

# Use double penalization to select variables that should remain in the
# following model predicting bottom temperatures
temp_all <- gam(
  temp_bottom ~ s(depth) + s(x) + s(y) + s(stratum) + s(shrimp) + s(cod) + s(total) + s(richness),
  data = trawl_data_2010,
  family = gaussian,
  method = "REML")

# Using gam.check and concurvity, how would you improve this model?
