
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
