### Add spatial data ###
geom <- sf::st_sfc(
  sf::st_point(c(obs[i, "lon"], obs[i, "lat"])), crs = obs[i, "srid"]
)
if(obs[i, "srid"] != 4326) {
  geom <- sf::st_transform(geom, 4326)
}
obs_list$geom <- list()
obs_list$geom <- geojsonio::geojson_list(geom)[c("type", "coordinates")]
rm(geom)








###################################################################
library(sf)
library(sp)

x_coord <- c(-78.0277, -77.1472, -77.3009, -77.1815, -78.0277)
y_coord <- c(50.2733, 49.1731, 49.2509, 49.3514, 50.2733)
xym <- cbind(x_coord, y_coord)

p <- sp::Polygon(xym)
ps <- sp::Polygons(list(p), 1)
sps <- SpatialPolygons(list(ps))
class(sps)


geom <- as(sps, "sf")


geom <- geojsonio::geojson_list(geom)

########################################################################
poly <- st_polygon(list(cbind(c(-78.0277, -77.1472, -77.3009, -77.1815, -78.0277), c(50.2733, 49.1731, 49.2509, 49.3514, 50.2733))))

geom <- sf::st_sfc(poly)

#polyCOORD <- sf::st_transform(poly2)

geojsonio::geojson_list(poly2)[c("type", "coordinates")]
