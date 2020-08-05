library(rnaturalearth)
library(sf)
library(dplyr)

trawl_map <- read.csv("data/trawl_nl.csv") %>%
  st_as_sf(coords = c("long","lat"),remove=FALSE)%>%
  st_set_crs(4326)




nl_coast <- ne_coastline(scale = 110,returnclass = "sf") %>%
  st_transform(st_crs(trawl_map))%>%
  st_intersection(st_as_sfc(st_bbox(trawl_map) ))



# unfortunately these are defined backwards, so the lines work but
# a merged polygon is a mess, fix this here :)
nl_geom <- st_geometry(nl_coast)
nl_south <- rbind(nl_geom[[1]][[2]][nrow(nl_geom[[1]][[2]]):1, ],
                  nl_geom[[1]][[1]][nrow(nl_geom[[1]][[1]]):1, ])#,
nl_south <- st_polygon(list(nl_south))
nl_north <- st_cast(nl_geom[[2]], "POLYGON")
nl_coast <- st_sfc(st_union(nl_south, nl_north), crs=4326)



#hand-adding Trinity, Conception, St. Mary's bays, because that's what this has
#come to:
bays <- list(st_polygon(list(matrix(c(-52.75,47.8139,
                                        -53.1,47.43,
                                        -53.103662, 47.81122,
                                        -52.7,48.081356,
                                        -52.75,47.8139),
                                      nrow = 5,byrow = TRUE))),
               st_polygon(list(matrix(c(-52.8,48.19,
                                        -53.3517,47.9775,
                                        -53.534302,47.718161,
                                        -53.666454,47.609326, 
                                        -53.672106,47.950084, 
                                        -53.,48.482204,
                                        -52.8,48.19),
                                      nrow = 7,byrow = TRUE))),
             st_polygon(list(matrix(c(-54.148434,46.668949, 
                                      -53.665673,47.203478, 
                                      -53.640295,46.543577,
                                      -54.148434,46.668949),
                                    nrow = 4,byrow = TRUE))),
             st_polygon(list(matrix(c(-55.345423,51.490983, 
                                      -57.004583,49.716780, 
                                      -56.877998,49.522891,
                                      -55.850159,50.308871,
                                      -55.345423,51.490983 ),
                                    nrow = 5,byrow = TRUE))))

bays <- st_multipolygon(bays)%>%
  st_sfc()%>%
  st_set_crs(4326)


nl_coast <- nl_coast %>%
  st_difference(bays)


trawl_strata <- read_sf("data/all_strata.shp")%>%
  filter(DIV%in%c("2J","3K","3L")) %>%
  #dealing with the annoying issue of strata with subareas. strata should be 3-digit numbers
  mutate(stratum = ifelse(stratum>1000, round(stratum/10,0),stratum))%>%
  filter(stratum %in% trawl_map$stratum)

write_sf(nl_coast,dsn="data/nl_coast.shp",delete_layer = TRUE)
write_sf(trawl_strata,dsn="data/trawl_strata.shp",delete_layer = TRUE)
