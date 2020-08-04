# build Markov random field data

library(sf)


# load strata shapefile
strata <- read_sf("../../data/all_strata.shp")

# load and subset data
dat <- read.csv("../../data/trawl_nl.csv")
dat_2010 <- subset(dat, year==2010)
# which strata do we need?

strata_ids <- unique(dat_2010$stratum)

# convert stratum id to character
strata_ids <- as.character(strata_ids)
strata$stratum <- as.character(strata$stratum)

# only pull these out
strata <- subset(strata, stratum %in% strata_ids)

# for mgcv, we want a list of polygons (matrix of vertices)
nl_strata <- list()
for(id in strata_ids){
  nl_strata[[id]] <- st_coordinates(subset(strata, stratum == id))[, 1:2]
}

save(nl_strata, file="../../data/mrf_strata.RData")
