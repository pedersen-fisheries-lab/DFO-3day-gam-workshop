library(mgcv)

# Load in data
trawl_data <- read.csv("data/trawl_nl.csv")
trawl_data_2010 <- trawl_data[trawl_data$year == 2010, ]

shrimp <- gam(
  shrimp ~ offset(log(area_trawled)) + s(depth) + s(temp_bottom),
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
  shrimp ~ offset(log(area_trawled)) + s(depth) + s(temp_bottom),
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
  shrimp ~ offset(log(area_trawled)) + s(depth) + s(temp_bottom),
  data = trawl_data_2010,
  family = tw,
  method = "REML")

summary(shrimp_tw)
plot(shrimp_tw, residuals = TRUE, cex=0.5, pch=21, pages = 1)

par(mfrow = c(2,2))
gam.check(shrimp_tw)
par(mfrow = c(1,1))

shrimp_tw2 <- gam(
  shrimp ~ offset(log(area_trawled)) + s(depth, k = 20) + s(temp_bottom, k = 20),
  data = trawl_data_2010,
  family = tw,
  method = "REML")

summary(shrimp_tw2)
plot(shrimp_tw2, residuals = TRUE, cex=0.5, pch=21, pages = 1)

par(mfrow = c(2,2))
gam.check(shrimp_tw2)
par(mfrow = c(1,1))

shrimp_tw_te <- gam(
  shrimp ~ offset(log(area_trawled)) + te(depth, temp_bottom),
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

