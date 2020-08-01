library(rnaturalearth)
library(sf)
library(dplyr)

trawl_map <- read.csv("data/trawl_nl.csv") %>%
  st_as_sf(coords = c("long","lat"),remove=FALSE)%>%
  st_set_crs(4326)

nl_coast <- ne_coastline(scale = 110,returnclass = "sf") %>%
  st_transform(st_crs(trawl_map))%>%
  st_intersection(st_as_sfc(st_bbox(trawl_map)))

trawl_strata <- read_sf("data/all_strata.shp")%>%
  filter(DIV%in%c("2J","3K","3L"))

write_sf(nl_coast,dsn="data/nl_coast.shp")
write_sf(trawl_strata,dsn="data/trawl_strata.shp")
