library(rnaturalearth)
library(sf)
library(dplyr)

trawl_map <- read.csv("../../data/trawl_nl.csv") %>%
  st_as_sf(coords = c("long","lat"),remove=FALSE)%>%
  st_set_crs(4326)

nl_coast <- ne_coastline(scale = 110,returnclass = "sf") %>%
  st_transform(st_crs(trawl_map))%>%
  st_intersection(st_as_sfc(st_bbox(trawl_map)))

# unfortunately these are defined backwards, so the lines work but
# a merged polygon is a mess, fix this here :)
nl_geom <- st_geometry(nl_coast)
nl_south <- rbind(nl_geom[[1]][[2]][nrow(nl_geom[[1]][[2]]):1, ],
                  nl_geom[[1]][[1]][nrow(nl_geom[[1]][[1]]):1, ])#,
nl_south <- st_polygon(list(nl_south))
nl_north <- st_cast(nl_geom[[2]], "POLYGON")
nl_coast <- st_sfc(st_union(nl_south, nl_north), crs=4326)

trawl_strata <- read_sf("data/all_strata.shp")%>%
  filter(DIV%in%c("2J","3K","3L"))

write_sf(nl_coast,dsn="../../data/nl_coast.shp")
write_sf(trawl_strata,dsn="../../data/trawl_strata.shp")
