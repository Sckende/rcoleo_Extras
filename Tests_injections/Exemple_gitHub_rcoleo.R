###########################
##### Injection Cellules ##
###########################

# load
#devtools::load_all(".")
library(rcoleo)

# Authentification
bearer <- readRDS(".httr-oauth")

# Ajouter les polygones de cellules
# shp_cells_1 <- rgdal::readOGR(dsn="C:/Users/HP_9470m/Desktop/rcoleo_Extras/Tests_injections/Test_injections_cellules/extdata/shp",layer="cellule_terrain_BdQc")

# LINUX
setwd("/home/claire/Bureau/rcoleo_Extras/Tests_injections/Test_injections_cellules")
shp_cells_1 <- rgdal::readOGR(dsn="./extdata/shp",layer="Cellule_terrain_2016-2020")
shp_cells_2 <- rgdal::readOGR(dsn="./extdata/shp",layer="553_cell")

# WINDOWS
shp_cells_1 <- rgdal::readOGR(dsn="C:/Users/HP_9470m/Desktop/rcoleo_Extras/Tests_injections/Test_injections_cellules/extdata/shp",layer="Cellule_terrain_2016-2020")
shp_cells_2 <- rgdal::readOGR(dsn="C:/Users/HP_9470m/Desktop/rcoleo_Extras/Tests_injections/Test_injections_cellules/extdata/shp",layer="553_cell")

# Reprojection vers WGS84
shp_cells_1 <- sp::spTransform(shp_cells_1,sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs;"))
shp_cells_2 <- sp::spTransform(shp_cells_2,sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs;"))

# On séléctionne les colonnes d'intérêts pour le merge
shp_cells_1@data <- dplyr::select(shp_cells_1@data, IJ, Nom)
shp_cells_2@data <- dplyr::select(shp_cells_2@data, IJ)
shp_cells_2@data$Nom <- NA

# Merge two shapefiles
shp_cells <- rbind(shp_cells_1,shp_cells_2)
shp_cells@data$Nom <- as.character(shp_cells@data$Nom)

# # On enlève les polygones si le code de cellule est dupliqué
# shp_cells <- shp_cells[-duplicated(shp_cells$IJ),]

# Loop par dessus les noms de cellules pour aller chercher son polygon.
cells_ls <- list()

library(rgdal)
library(geojsonio)

for(i in 1:nlevels(shp_cells$IJ)){
#for(i in 1:length(unique(shp_cells$IJ))){
  
  cell_code <- levels(shp_cells$IJ)[i]
  shp <- shp_cells[shp_cells$IJ == cell_code ,]
  
  cells_ls[[i]] <- list()
  cells_ls[[i]]$cell_code <- cell_code
  cells_ls[[i]]$name <- shp_cells[shp_cells$IJ == cell_code & !is.na(shp_cells$Nom),]@data$Nom
  
  if(identical(cells_ls[[i]]$name,character(0))){
    cells_ls[[i]]$name <- NULL
    }
  
  shp_sp <- as(shp, "SpatialPolygons")
  cells_ls[[i]]$geom <- geojsonio::geojson_list(shp)$features[[1]]$geometry
  
  # Add CRS fields
  cells_ls[[i]]$geom$crs <- list(type="name",properties=list(name="EPSG:4326"))
  
}

# Envoyer seulement les donnees avec un nom de cellule
#resp_cells <- post_cells(cells_ls)