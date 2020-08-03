# make a soap film boundary


library(sf)
library(lwgeom)

# coastline shapefile
coast <- read_sf("../../data/nl_coast.shp")

# data extent
trawl_map <- read.csv("../../data/trawl_nl.csv") %>%
  st_as_sf(coords = c("long","lat"),remove=FALSE)%>%
  st_set_crs(4326)
data_bbox <- st_as_sfc(st_bbox(trawl_map))


# just get the geometry
coast <- st_geometry(coast)
coast_bbox <- st_as_sfc(st_bbox(coast))

# make a larger bounding box which accomodates the data and the coast
big_box <- st_union(coast_bbox, data_bbox)

# what does that look like?
# two lines, we need to draw a box around them and joint them up...
plot(big_box)
plot(coast, add=TRUE)

# now just need to difference the two
soap_bnd <- st_difference(big_box, coast)
plot(soap_bnd)

# just need a matrix for soap
soap_bnd <- st_coordinates(soap_bnd)[,1:2]

write.csv(soap_bnd, file="../../data/soap_boundary.csv", row.names=FALSE)
