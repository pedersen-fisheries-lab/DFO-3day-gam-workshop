# build Markov random field data

library(sf)


# load strata shapefile
strata <- read_sf("../../data/all_strata.shp")

# load and subset data
dat <- read.csv("../../data/trawl_nl.csv")
dat_2010 <- subset(dat, year==2010)
# which strata do we need?
strata_ids <- unique(dat_2010$strata)

# convert stratum id to character
strata$stratum <- as.character(strata$stratum)

# ABSOLUTELY HORRENDOUS
# stratum labels don't match, so do this geographically
problem_ids <- strata_ids[grepl("_", strata_ids)]
# find the strata we didn't match yet
unmatched <-  strata$stratum[!(strata$stratum  %in% strata_ids[!(strata_ids %in% problem_ids)])]

# over the problem strata in the data
for(prob in problem_ids){

  # make a point sf object
  prob_pts <- st_sfc(st_multipoint(as.matrix(dat_2010[dat_2010$strata == prob,][,c("long", "lat")])), crs=st_crs(strata))

  # is in inside the any of the strata we've not matched yet?
  right_strata <- strata[st_within(prob_pts, strata)[[1]],]$stratum

  # replace the label with the one in the data
  strata[strata$stratum == right_strata, ]$stratum <- prob
}

# only pull these out
strata <- subset(strata, stratum %in% strata_ids)

# for mgcv, we want a list of polygons (matrix of vertices)
nl_strata <- list()
for(id in strata_ids){
  nl_strata[[id]] <- st_coordinates(subset(strata, stratum == id))[, 1:2]
}

save(nl_strata, file="../../data/mrf_strata.RData")
