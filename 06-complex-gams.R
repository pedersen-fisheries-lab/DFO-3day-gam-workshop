
#6. more complex models

# part 1: Choosing a family to fit your data ####

# part 2: Choosing a smooth to model a relationship


dat_2010$strata <- as.factor(dat_2010$strata)
mod_space_depth_select <- gam(cod ~ te(long, lat, k=15)+
                                s(depth, k=20) +
                                s(temp_bottom, k=10) +
                                s(strata, bs="re"),
                              select=TRUE,
                              data=dat_2010, method="REML", family=tw)

#    - cyclic smoothers
#    - soap

# load the soap boundary
soap_bnd <- read.csv("data/soap_boundary.csv")
soap_knots <- expand.grid(long = seq(-58.5, -48, length.out=8),
                          lat  = seq(46, 54.5, length.out=8))
X <- soap_knots[,1]
Y <- soap_knots[,2]
ind <- inSide(soap_bnd,x=X,y=Y) ## remove outsiders
soap_knots <- soap_knots[ind,]

plot(soap_bnd, type="l")
points(soap_knots)

names(soap_bnd) <- c("long", "lat")
mod_soap <- gam(cod ~ s(long, lat, bs="so", k=20, xt=list(bnd=list(soap_bnd))),
                knots=soap_knots,
                data=dat_2010, method="REML",
                family=tw())
summary(mod_soap)

plot(mod_soap)
points(dat_2010[,c("long", "lat")])

# easier to see what's happening with k in a split basis model
# **the same model** is fitted here, we can just more easily diagnose
#  issues with basis size
mod_soap_split <- gam(cod ~ s(long, lat, bs="sf", xt=list(bnd=list(soap_bnd)))+
                        s(long, lat, bs="sw", k=20,
                          xt=list(bnd=list(soap_bnd))),
                      knots=soap_knots,
                      data=dat_2010, method="REML",
                      family=tw())
summary(mod_soap_split)

#    - MRFs
load("data/mrf_strata.RData")
dat_2010$strata <- as.factor(dat_2010$strata)
mod_mrf <- gam(cod ~ s(strata, bs="mrf", xt=list(polys=nl_strata)),
               data=dat_2010, method="REML",
               family=tw())
summary(mod_mrf)

plot(mod_mrf)




#    - factor-smooths
# could revisit the temperature-depth model?
# multi-species?
#  - other responses:
#    - `ocat`/gev/`mvn`/etc


