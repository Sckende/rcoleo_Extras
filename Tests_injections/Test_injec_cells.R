library(rcoleo)
library(dplyr)

library(sf)
library(st)
library(sp)
library(geojsonio)

# données existantes
cell_list <- get_cells()
str(cell_list, max.level = 3)
all_things <- dplyr::bind_rows(cell_list[[1]]$body)

# nouvelles données
corrections <- read.csv("Test_injec_cells.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")

names(corrections)[1] <- "name"

  # création de l'objet spatial
x_coord <- c(-78.0277, -77.1472, -77.3009, -77.1815, -78.0277)
y_coord <- c(50.2733, 49.1731, 49.2509, 49.3514, 50.2733)
xym <- cbind(x_coord, y_coord)
xym
p <- sp::Polygon(xym)
class(p)
ps <- sp::Polygons(list(p), 1)
ps

sps <- sp::SpatialPolygons(list(ps))
sps
class(sps)

geom <- as(sps, "sf")
geom

#geojsonio::geojson_list(geom)[c("type", "coordinates")]

geom <- geojsonio::geojson_list(geom)
geom














glimpse(all_things)
glimpse(corrections)
all(names(corrections) %in% names(all_things))

###############
# Essai d'intégrer geom
correctionsTOload <- purrr::transpose(corrections)
correctionsTOload[[1]]$geom <- list()
correctionsTOload[[1]]$geom <- geojsonio::geojson_list(geom)

rcoleo::post_gen("/cells", correctionsTOload)
rcoleo::post_cells(correctionsTOload)
