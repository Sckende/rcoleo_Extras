#### Test injection des campagnes pour zooplancton - dénombrement ####
rm(list = ls())

library(readr)
# WINDOWS
camp_zoopl <- read_delim("C:/Users/HP_9470m/Desktop/rcoleo_Extras/Tests_injections/Campagne_zoopl_denombrement.csv", ";")

# LINUX
camp_zoopl <- read_delim("/home/claire/Bureau/rcoleo_Extras/Tests_injections/Test_injection_campagnes/Campagne_zoopl_denombrement.csv", ";")


#### Test pour vérifier l'existence des cellules dans COLEO ####
cells <- rcoleo::get_cells()
cells <- do.call("rbind", cells[[1]]$body)

unique(camp_zoopl$no_de_reference_de_la_cellule) %in% unique(cells$cell_code)
# ==> nécessité de création d'une cellule "124_93"

#### ---------- Création des cellules manquantes dans COLEO ---------- ####
#shp_cells <- rgdal::readOGR(dsn="/home/claire/Bureau/rcoleo_Extras/Tests_injections/Test_injections_cellules/extdata/shp",layer="Cellule_terrain_2016-2020")

#cell_code <- "124_93"
# Extraction des données spécifiques à la cellule à partir du shapefile où il y a toutes les cellules
#shp <- shp_cells[shp_cells$IJ == cell_code ,]
# Création d'une liste avec les informations nécessaires
#cells_ls <- list()
#cells_ls$cell_code <- cell_code # le code de la cellule
#cells_ls$name <- shp_cells[shp_cells$IJ == cell_code & !is.na(shp_cells$Nom),]@data$Nom # le nom de la cellule

#if(identical(cells_ls$name,character(0))){
#  cells_ls$name <- NULL
#} # si pas de nom, retrait de ce niveau de liste
# Création de l'objet spatial pour les coordonnées de la cellule
#shp_sp <- as(shp, "SpatialPolygons")
#cells_ls$geom <- geojsonio::geojson_list(shp)$features[[1]]$geometry # Caractéristiques de l'objet spatial
#cells_ls$geom$crs <- list(type="name",properties=list(name="EPSG:4326")) # Add CRS fields

# Check for the JSON format - Car API très sensible à la présence de brackets !
#jsonlite::toJSON(cells_ls)

# Envoyer la nouvelle cellule vers COLEO
#resp_cells <- post_cells(cells_ls) # Ne fonctionne pas
#resp_cells <- rcoleo::post_gen("/cells", cells_ls) # FONCTIONNE 

#### Test pour vérifier l'existence des sites dans COLEO ####
sites <- rcoleo::get_sites()
sites <- do.call("rbind", sites[[1]]$body)

# test pour vérifier l'existence des codes de sites dans COLEO
unique(camp_zoopl$no_de_reference_du_site) %in% unique(sites$site_code)
#camp_zoopl2 <- camp_zoopl[!camp_zoopl$no_de_reference_du_site %in% sites$site_code,]
#### ---------- Création des sites manquants dans COLEO ---------- ####
#### Préparation des données à injecter ####
# Variables tables "sites" #
# Table name  / import DF name
# cell_id              /  recuperation avec get_cells
# off_station_code_id / idem ?
# site_code          / no_de_reference_du_site
# type              / zooplanctons
# opened_at        / date_debut
# geom             / association latitude-longitude
# notes           / **** INDIQUER LE NOM DU SITE DANS LES NOTES ***

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de COLEO
#inj_zoop <- dplyr::select(camp_zoopl2, cell_code=no_de_reference_de_la_cellule, site_code=no_de_reference_du_site, type=type_milieu, opened_at=date_debut, lat=latitude, lon=longitude)

# Récupération des cells id
#inj_zoop <- dplyr::left_join(inj_zoop, cells[, c(1,3)], by = "cell_code")
#names(inj_zoop)[7] <- "cell_id"

# On garde une ligne unique par nouveau site
#inj_zoop <- inj_zoop[!duplicated(inj_zoop),]

# Transformer en liste pour injection
#sites_ls <- apply(inj_zoop,1,as.list)
#str(sites_ls)

# Creer geom points
#geom <- apply(inj_zoop,1, function(x){
#  if(!any(is.na(x["lat"]),is.na(x["lon"]))){
#    return(geojsonio::geojson_list(as.numeric(c(x["lon"],x["lat"])))$features[[1]]$geometry)
#  } else {
#    return(NA)
#  }})

#crs_ls <- list(type="name",properties=list(name="EPSG:4326"))

# Fusionner les deux listes (geomations + sites)
#for(i in 1:length(sites_ls)){
#  sites_ls[[i]]$geom <- geom[i][[1]]
#  if(is.list(sites_ls[[i]]$geom)){
#    sites_ls[[i]]$geom$crs <- list(type="name",properties=list(name="EPSG:4326"))
#  }
#}


#sites_ls # ok pour un ou plusieurs sites

#### ---------- Nouvelle fonction pour remplacer POST_SITES() ---------- ####

#endpoint <- "/sites"
#postpost_sites <- function (data) 
#{
#  responses <- list()
#  class(responses) <- "coleoPostResp"
  #endpoint <- endpoints()$sites

#    for (i in 1:length(data)) {
    #data[[i]]$cell_id <- as.data.frame(get_cells(data[[i]]$cell_id))$id
#    responses[[i]] <- post_gen(endpoint, data[[i]])
#  }
#  return(responses)
#}
#### ---------- Injection du/des nouveaux sites ---------- ####
#postpost_sites(sites_ls) # FONCTIONNE

#### Variables tables "campaigns" ####
# Table name  / import DF name
# site_id      / à récupérer de get_sites() à partir de "no_de_reference_du_site"
# type         / nom de la campagne, ici "zooplanctons"
# technicians  / liste composée de "technicien_1" et "technicien_2"
# opened_at    / "date_debut"
# closed_at    / "date_fin"
# notes        / aucune

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de COLEO
inj_camp_zoop <- dplyr::select(camp_zoopl, site_code=no_de_reference_du_site, opened_at=date_debut, closed_at=date_fin)

inj_camp_zoop <- dplyr::left_join(inj_camp_zoop, sites[, c(1,4), by = "site_code"]) # Récupération des sites id
names(inj_camp_zoop)[4] <- "site_id"
