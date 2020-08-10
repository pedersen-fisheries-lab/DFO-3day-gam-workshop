

# 2. "twiddling knobs in `gam`"

#  - moving beyond normal data (campylobacter?)
#    - exponential family and conditionally exp family (i.e., `family` + `tw` + `nb`)

# here we have trawls, so data are 0 or greater continuous
# (assuming this is CPUE?)

# can try modelling per year averages using different responses
dat_yearly_cod <- dat %>%
  select(year, cod) %>%
  group_by(year) %>%
  summarize(catch = mean(cod))

plot(dat_yearly_cod$year, dat_yearly_cod$catch)

mod_yearly <- gam(catch ~ s(year,k=5),
                  data=dat_yearly_cod,
                  method="REML",
                  family=tw())

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
