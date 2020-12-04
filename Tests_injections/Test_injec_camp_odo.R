#### Test injection des campagnes pour odonates ####
rm(list = ls())

library(readr)

#--------------------------------------------#
# WINDOWS
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
camp_odo <- read.csv("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/Campagne_odonate_V2.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")

# LINUX
# setwd("/home/claire/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
# camp_odo <- read_delim("data/Campagne_odonate.csv", ",")

#### ----- Infos déjà présentes dans Coléo ----- ####
library(plyr) # pour rbind.fill()
# Acquisition cellules Coléo
cells <- rcoleo::get_cells()
cells <- do.call("rbind.fill", cells[[1]]$body)
# Acquisition sites Coléo
sites <- rcoleo::get_sites()
sites <- do.call("rbind.fill", sites[[1]]$body)
# Acquisition campagnes Coléo
camp <- rcoleo::get_campaigns()
camp <- do.call("rbind.fill", camp[[1]]$body)
# Acquisition observations Coléo
obs <- rcoleo::get_gen("/observations")
obs <- do.call("rbind.fill", obs[[1]])
# Acquisition des espèces dans Coléo
species <- rcoleo::get_species()
species <- do.call("rbind.fill", species[[1]]$body)

#### ----- Nettoyage des données ----- ####
summary(camp_odo)
table(camp_odo$nom_scientifique, useNA = "always")
table(camp_odo$nom_commun, useNA = "always")  
  
camp_odo[is.na(camp_odo$nom_commun) & is.na(camp_odo$nom_scientifique),]
camp_odo[is.na(camp_odo$nom_scientifique),]

tail(camp_odo, 10)

camp_odo[is.na(camp_odo$abondance),]

# Extra nettoyage
camp_odo <- camp_odo[-c(50, 51),] 

t <- table(camp_odo$type_milieu)

camp_odo$type_milieu[camp_odo$type_milieu == names(t)[2]] <- "marais"
camp_odo$type_milieu[camp_odo$type_milieu == names(t)[3] | camp_odo$type_milieu == names(t)[4]] <- "tourbière"

#### ---------- Test pour vérifier si présence des espèces à insérer dans la table ref_species de Coléo ---------- ####
sp_abs <- rcoleo::COLEO_comp(unique(camp_odo$nom_scientifique), unique(species$name))

#### ---------- Test pour vérifier l'existence des cellules dans Coléo ---------- ####
cell_abs <- rcoleo::COLEO_comp(unique(camp_odo$no_de_reference_de_la_cellule), unique(cells$cell_code))
# ==> nécessité de création de 2 cellules "73_137" & "130_87"

#### ---------- Création des cellules manquantes dans Coléo ---------- ####
# Windows
#shp_cells <- rgdal::readOGR(dsn = "C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/extdata/shp", layer = "Cellule_terrain_2016-2020")
# Linux
shp_cells <- rgdal::readOGR(dsn="/home/claire/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/extdata/shp",layer="Cellule_terrain_2016-2020")

cell_code <- cell_abs
#cell_code <- c("73_137", "130_87")
# cell_code <- "73_137"
# cell_code <- "130_87"
# Extraction des données spécifiques à la cellule à partir du shapefile où il y a toutes les cellules
shp_cells_list <- list()
for (i in 1:length(cell_code)){
  shp <- shp_cells[shp_cells$IJ == cell_code[i] ,]
  # Création d'une liste avec les informations nécessaires
  cells_ls <- list()
  cells_ls$cell_code <- cell_code[i] # le code de la cellule
  cells_ls$name <- unique(shp_cells[shp_cells$IJ == cell_code[i] & !is.na(shp_cells$Nom),]@data$Nom) # le nom de la cellule
  
  if(identical(cells_ls$name, character(0))){
    cells_ls$name <- NULL
  } # si pas de nom, retrait de ce niveau de liste
  #Création de l'objet spatial pour les coordonnées de la cellule
  shp_sp <- as(shp, "SpatialPolygons")
  cells_ls$geom <- geojsonio::geojson_list(shp)$features[[1]]$geometry # Caractéristiques de l'objet spatial
  cells_ls$geom$crs <- list(type="name",properties=list(name="EPSG:4326")) # Add CRS fields
  
  shp_cells_list[[i]] <- cells_ls
}


# Check for the JSON format - Car API très sensible à la présence de brackets !
#jsonlite::toJSON(shp_cells_list[[2]])

# Envoyer la nouvelle cellule vers Coléo
resp_cells <- rcoleo::post_cells(shp_cells_list) # Fonctionne

#resp_cells <- rcoleo::post_gen("/cells", shp_cells_list[[2]]) # Fonctionne si envoyée une cellule par une cellule

#### Test pour vérifier l'existence des sites dans Coléo ####
# test pour vérifier l'existence des codes de sites dans Coléo
site_abs <- rcoleo::COLEO_comp(unique(camp_odo$no_de_reference_du_site), unique(sites$site_code))
site_abs

#### ---------- Création des sites manquants dans Coléo ---------- ####
#### Préparation des données à injecter ####
# Variables tables "sites" #
# Table name  / import DF name
# cell_id              /  recuperation avec get_cells
# off_station_code_id / idem ?
# site_code          / no_de_reference_du_site
# type              / type de l'habitat ATTENTION, doit appartenir à la liste suivante : 'lac', 'rivière', 'forestier', 'marais', 'marais côtier', 'toundrique', 'tourbière'
# opened_at        / date_debut
# geom             / association latitude-longitude des lacs, ici identiques à lat/long du site
# notes           / **** INDIQUER LE NOM DU SITE DANS LES NOTES ***

# Subset de données contenant les sites non présent dans Coléo
camp_odo_2 <- camp_odo[camp_odo$no_de_reference_du_site %in% site_abs,]

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de Coléo

inj_odo <- dplyr::select(camp_odo_2,
                         cell_code = no_de_reference_de_la_cellule,
                         site_code = no_de_reference_du_site,
                         type = type_milieu,
                         opened_at = date_debut,
                         lat = latitude,
                         lon = longitude)

# Récupération des cells id
cells <- rcoleo::get_cells() # Mise à jour de la listes des cellules dans Coléo
cells <- do.call("rbind", cells[[1]]$body)

inj_odo <- dplyr::left_join(inj_odo, cells[, c(1,3)], by = "cell_code")
names(inj_odo)[7] <- "cell_id"

# On garde une ligne unique par nouveau site
inj_odo <- inj_odo[!duplicated(inj_odo),]

# Transformer en liste pour injection
sites_ls <- apply(inj_odo, 1, as.list)
str(sites_ls)

# Creer le champs geom de Coléo en utilisant les variables lat & lon
geom <- apply(inj_odo, 1, function(x){
if(!any(is.na(x["lat"]), is.na(x["lon"]))){
  return(geojsonio::geojson_list(as.numeric(c(x["lon"], x["lat"])))$features[[1]]$geometry)
} else {
  return(NA)
}})


# Fusionner les deux listes (geomations + sites)
for(i in 1:length(sites_ls)){
 sites_ls[[i]]$geom <- geom[i][[1]]
 if(is.list(sites_ls[[i]]$geom)){
   sites_ls[[i]]$geom$crs <- list(type = "name", properties = list(name = "EPSG:4326"))
 }
}


sites_ls # ok pour un ou plusieurs sites

#### ---------- Injection du/des nouveaux sites ---------- ####
COLEO_inj <- rcoleo::post_sites(sites_ls) 

#### ---------- Variables tables "campaigns" ---------- ####
# Table name  / import DF name
# site_id      / à récupérer de get_sites() à partir de "no_de_reference_du_site"
# type         / nom de la campagne, ici "zooplanctons"
# technicians  / liste composée de "technicien_1" et "technicien_2"
# opened_at    / "date_debut"
# closed_at    / "date_fin"
# notes        / aucune

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de Coléo
inj_camp_odo <- dplyr::select(camp_odo,
                              site_code = no_de_reference_du_site,
                              opened_at = date_debut,
                              closed_at = date_fin,
                              technicien_1,
                              technicien_2)

# Création du type de campagnes - zooplanctons - ATTENTION - Vérifier l'appellation du type de campagne - 'végétation', 'végétation_transect', 'sol', 'acoustique', 'phénologie', 'mammifères', 'papilionidés', 'odonates', 'insectes_sol', 'ADNe','zooplancton', 'sol','décomposition_sol','température_eau', 'température_sol', 'marais_profondeur_température'
inj_camp_odo$type <- "odonates"


#### Attention - Retrait des observations des campagnes déjà insérées il y a deux ans !!!
odo_vc <- paste(inj_camp_odo$site_code, inj_camp_odo$opened_at, inj_camp_odo$type) # création d'un vecteur avec caractéristiques des campagnes à insérer (code_site, opened_at & type)

# Récupération des site_code pour les campagnes
sit <- sites[, c("id", "site_code")]
names(sit)[1] <- "site_id"
camp <- dplyr::left_join(camp, sit, by = "site_id")

coleo_vc <- paste(camp$site_code, camp$opened_at, camp$type) # création d'un vecteur avec caractéristiques des campagnes déjà présentes dans Coléo (code_site, opened_at & type)

# Comparaison
inj_camp_odo$status_inj <- odo_vc %in% coleo_vc

# On ne garde que les campagnes réellement nouvelles, soit celles avec status_inj == FALSE
inj_camp_odo <- inj_camp_odo[inj_camp_odo$status_inj == FALSE,]

# On garde une ligne unique par nouvelle campagne
inj_camp_odo_unik <- inj_camp_odo[!duplicated(inj_camp_odo),]

# Création de la liste de techniciens
tech <- list()
for(i in 1:length(inj_camp_odo_unik$site_code)){
  tech[[i]] <- list(inj_camp_odo_unik$technicien_1[[i]], inj_camp_odo_unik$technicien_2[[i]])
}
tech
inj_camp_odo_unik$technicians <- tech


head(inj_camp_odo_unik)

# Transformer en liste pour injection
camp_ls <- apply(inj_camp_odo_unik, 1, as.list)
str(camp_ls)

# Injections
COLEO_inj_camp <- rcoleo::post_campaigns(camp_ls) # Non fonctionnel



#### Variables tables "landmarks" & "environments" ####
# TABLE LANDMARKS
# campaign_id / doit matcher avec site_code/site_id, opened_at & type
# geom / utilisation de longitude et latitude


#### TABLE ENVIRONMENTS ####
# campaign_id / doit matcher avec site_code/site_id, opened_at & type
# wind / vent
# sky / ciel
# temp_c / temperature ?
# ----------
# notes 
# samp_surf
# samp_surf_unit

#camp_odo <- read.csv("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/Campagne_odonate_V2.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")
camp_odo <- read.csv("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/Campagne_odonate_V3_slashes.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")
names(camp_odo)

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de Coléo
inj_land_odo <- dplyr::select(camp_odo,
                              site_code = no_de_reference_du_site,
                              opened_at = date_debut,
                              lat = latitude,
                              lon = longitude,
                              wind = vent,
                              sky = ciel,
                              temp_c = temperature)
inj_land_odo$type <- "odonates" 

# On récupère les site_id
inj_land_odo <- dplyr::left_join(inj_land_odo, sites[, c(1, 4)], by = "site_code")
names(inj_land_odo)[9] <- "site_id"

# On récupère les campaign_id
#coleo_odonate <- rcoleo::get_campaigns(type = "odonates")
#coleo_odonate <- do.call("rbind", coleo_odonate[[1]]$body)

inj_land_odo <- dplyr::left_join(inj_land_odo, camp[, c("site_id", "opened_at", "type", "id")], by = c("site_id", "opened_at", "type"))

names(inj_land_odo)[10] <- "campaign_id"

# On garde une ligne par repère (c'est à dire par campagne)
inj_land_odo_unik <- inj_land_odo[!duplicated(inj_land_odo),]

# On retire les variables non utilisées pour injection de la table - ici on ne garde que campaign_id et geom (lat - lon)
inj_land_odo_unik_2 <- inj_land_odo_unik[, c("campaign_id", "lat", "lon")]

# Transformer en liste pour injection
land_ls <- apply(inj_land_odo_unik_2, 1, as.list)
str(land_ls)


# Creer le champs geom de Coléo en utilisant les variables lat & lon
geom <- apply(inj_land_odo_unik_2, 1, function(x){
  if(!any(is.na(x["lat"]),is.na(x["lon"]))){
    return(geojsonio::geojson_list(as.numeric(c(x["lon"],x["lat"])))$features[[1]]$geometry)
  } else {
    return(NA)
  }})

# Fusionner les deux listes (geomations + sites)
for(i in 1:length(land_ls)){
  land_ls[[i]]$geom <- geom[i][[1]]
  if(is.list(land_ls[[i]]$geom)){
    land_ls[[i]]$geom$crs <- list(type="name",properties=list(name="EPSG:4326"))
  }
}

# Injection
COLEO_land_inj <- rcoleo::post_landmarks(land_ls) # Fonctionnel

#### TABLE ENVIRONMENT ####
# Préparation injection table ENVIRONMENTS

inj_env_odo_unik <- inj_land_odo_unik[, c("campaign_id", "wind", "sky", "temp_c")]

# Correction des entrées pour "sky" et "wind" - *** ATTENTION, corrections faites directement dans le .CSV ***
# OPTIONNEL - pour ne pas réinsérer ce qui a fonctionné hier

inj_env_odo_unik <- inj_env_odo_unik[inj_env_odo_unik$wind %in% c("légère brise (6 à 11 km/h)", "très légère brise (1 à 5 km/h)", "petite brise (12 à 19 km/h)" ) ,]

# Transformer en liste pour injection
env_ls <- apply(inj_env_odo_unik, 1, as.list)
str(env_ls)


# Injection
COLEO_env_inj <- rcoleo::post_environments(env_ls)

#### Variables table "efforts" ####
# ---------- obligatoires
# campaign_id
# ---------- facultatifs
# stratum
# time_start
# time_finish
# samp_surf
# samp_surf_unit
# notes

camp_odo <- read.csv("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/Campagne_odonate_V3_slashes.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")
names(camp_odo)

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de Coléo
inj <- dplyr::select(camp_odo,
                     site_code = no_de_reference_du_site,
                     opened_at = date_debut,
                     time_start = heure_debut,
                     time_finish = heure_fin)
inj$type <- "odonates" 

# On récupère les site_id
inj <- dplyr::left_join(inj, sites[, c(1, 4)], by = "site_code")
names(inj)[6] <- "site_id"

# On récupère les campaign_id
inj <- dplyr::left_join(inj, camp[, c("site_id", "opened_at", "type", "id")], by = c("site_id", "opened_at", "type"))

names(inj)[7] <- "campaign_id"

# On garde une ligne par campagne
inj_unik <- inj[!duplicated(inj),]

# Transformer en liste pour injection
inj_ls <- apply(inj_unik, 1, as.list)
str(inj_ls)

# Injections

COLEO_inj <- rcoleo::post_efforts(inj_ls) # ==> DONE !!!

#### Variables tables "observations" ####
# ---------- obligatoires
# date_obs / date_debut
# is_valid / par défaut = 1
# campaign_id / récupération avec site_id, type et opened_at(=date_obs)
# ---------- facultatifs
# campaign_info / ?
# time_obs
# stratum
# axis
# distance
# distance_unit
# depth / Profondeur_m
# sample_id
# thermograph_id
# notes / Date_denombrement + Taxonomiste

camp_odo <- read.csv("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/Campagne_odonate_V3_slashes.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de Coléo
inj_obs <- dplyr::select(camp_odo,
                         site_code = no_de_reference_du_site,
                         opened_at = date_debut)
inj_obs$is_valid <- 1
inj_obs$type <- "odonates"

# On récupère les site_id
inj_obs <- dplyr::left_join(inj_obs, sites[, c(1, 4)], by = "site_code")
names(inj_obs)[4] <- "site_id"

# On récupère les campaign_id
inj_obs <- dplyr::left_join(inj_obs, camp[, c("id", "site_id", "opened_at", "type")], by = c("site_id", "opened_at", "type"))
names(inj_obs)[6] <- "campaign_id"

# Modification du nom pour la date d'observation
names(inj_obs)[2] <- "date_obs"

# On conserve les lignes uniques
inj_obs <- inj_obs[!duplicated(inj_obs),]

# Transformer en liste pour injection
obs_ls <- apply(inj_obs, 1, as.list)

# Injections
COLEO_obs_inj <- rcoleo::post_obs(obs_ls) # Fonctionnel

#### Variables tables "attributes" ####
rcoleo::get_gen("/attributes")

# Vérifier que les attributs existent

#### Variables tables "obs_species" ####
# -------- obligatoires
# taxa_name / nom_scientifique
# variable / "abondance"
# observation_id / à récupérer avec site_id --> site_code --> campaign_id + opened_at
# -------- facultative
# value / abondance

# On séléctionne les champs d'interêts & on matche les noms de variables avec celles de Coléo
inj_data <- dplyr::select(camp_odo,
                          site_code = no_de_reference_du_site,
                          opened_at = date_debut,
                          taxa_name = nom_scientifique,
                          value = abondance)
inj_data$variable <- "abondance"
inj_data$type <- "odonates"

# On récupère les site_id
inj_data <- dplyr::left_join(inj_data, sites[, c("id", "site_code")], by = "site_code")
names(inj_data)[7] <- "site_id"

# On récupère les campaign_id
inj_data <- dplyr::left_join(inj_data,
                             camp[, c("id", "site_id", "opened_at", "type")],
                             by = c("site_id", "opened_at", "type"))
names(inj_data)[8] <- "campaign_id"

# On récupère les observation_id
names(inj_data)[2] <- "date_obs"
inj_data$date_obs <- inj_data$opened_at

inj_data <- dplyr::left_join(inj_data,
                             obs[, c("id", "campaign_id", "date_obs")],
                             by = c("campaign_id", "date_obs"))

names(inj_data)[length(inj_data)] <- "observation_id"

# Transformer en liste pour injection
data_ls <- apply(inj_data, 1, as.list)

# Injections
COLEO_data_inj <- rcoleo::post_obs_species(data_ls) # ==> DONE !!!




########################################################
#### Récupération des campagnes non injectées ####
#################################################
# 
# camp_odo$type <- "odonates"
# odo_vc <- paste(camp_odo$no_de_reference_du_site, camp_odo$date_debut, inj_land_odo$type)
# 
# # informations campagnes et ajout de site_code
# camp_vc <- paste(camp$site_code, camp$opened_at, camp$type)
# 
# # Comparaison
# camp_odo$status_inj <- odo_vc %in% camp_vc
# 
# camp_odo <- camp_odo[camp_odo$status_inj == FALSE,]
# 
# write.csv(camp_odo, "Campagne_odonate_V2.csv")
