#### Obtenir un geojson format à partir des shapefiles ####
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
cells <- rcoleo::get_cells()
cells <- do.call(plyr::rbind.fill, cells[[1]]$body)

campaigns <- rcoleo::get_campaigns()
campaigns <- do.call(plyr::rbind.fill, campaigns[[1]]$body)
cell_ids <- unique(campaigns$site.cell_id)

cells <- cells[cells$id %in% cell_ids,]

shp_cells <- rgdal::readOGR(dsn="./extdata/shp",
                            layer="Cellule_terrain_2016-2020") # Ici le fichier shapefile est placé dans un dossier shp et on appelle tous les fichiers nommés "Cellule_terrain_2016_2020"

# Obtention des informations pour un cellule contenues dans les shapefiles
shp <- shp_cells[shp_cells$IJ %in% cells$cell_code ,] # class objet spatial sf
shp <- sf::st_as_sf(shp) # conversion en objet spatial st
shp <- dplyr::left_join(shp, cells[, c("id", "cell_code")], by = c("IJ" = "cell_code"))
shp$Nom <- shp$id # remplacement des noms par les ids
shp <- geojsonsf::sf_geojson(shp) # conversion en geojson
shp

#geojsonio::geojson_write(shp, file = "cellsCoords2.geojson") # Exportation du geojson



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

poly2 <- geojsonio::geojson_list(poly)[c("type", "coordinates")]

jsonlite::toJSON(poly2)
