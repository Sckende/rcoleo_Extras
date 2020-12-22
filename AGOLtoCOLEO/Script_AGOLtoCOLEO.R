# Conversion des données extraites des formulaires de AGOL pour injection dans COLEO
# Formulaires utilisés: papillon/odonate
# Données des formulaires de AGOL extraites sous la forme de 4 fichiers connectés entre eux via GlobalID/ParentGlobalID
# Odonate_X_Papillon_0.csv pour les sites utilisés
# invetaire_1.csv pour le détails des espèces observées sur le terrain
# identification_2.csv pour l'identification post terrain, enlabo
# photo_s_3.csv pour les medias

setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/AGOLtoCOLEO")

# Chargement & nettoyage du fichier sur les campagnes utiles
camp_0 <- readr::read_delim("./AGOL_data_2/Odonate_X_Papillon_0.csv", delim = ",")
camp_0 <- dplyr::select(camp_0,
                 GlobalID,
                 date,
                 labo,
                 lon,
                 lat,
                 cell_code,
                 id,
                 cell_code_FS,
                 site_code,
                 site_code_FS,
                 type_hab,
                 type_hab_FS,
                 time_start,
                 technicien_1,
                 technicien_1_FS,
                 temp_c,
                 sky,
                 wind,
                 time_finish,
                 note)

# Chargement & nettoyage du fichier inventaire
inv_1 <- readr::read_delim("./AGOL_data_2/inventaire_1.csv", delim = ",")
inv_1 <- dplyr::select(inv_1,
                       capture_ou_vu,
                       o_or_p,
                       no_seq_ind_cap,
                       taxa_name_p,
                       taxa_name_p_FS,
                       abondance_cap,
                       rank_cap,
                       category_cap,
                       ParentGlobalID)

# Chargement & nettoyage du fichier identifications au labo
id_2 <- readr::read_delim("./AGOL_data_2/identification_2.csv", delim = ",")
id_2 <- dplyr::select(id_2,
                      o_or_p_labo = p_or_o,
                      no_seq_ind_cap,
                      odonate,
                      papillon,
                      o_p_FS,
                      abondance_labo,
                      rank_labo,
                      category_labo)

# Fusion des fichiers AGOL
data1 <- dplyr::left_join(inv_1,
                          camp_0,
                          by = c("ParentGlobalID" = "GlobalID"))
data2 <- dplyr::left_join(data1,
                          id_2,
                          by = "no_seq_ind_cap")
data2$num <- 1:dim(data2)[1]

#### Etape 1 - Verifier que les colones "xxx_FS" soient vides ####
fs <- data2[, grep("FS", names(data2))] # Recuperation des colonnes "freestyle"

if(all(is.na(fs)) == FALSE){ # Debut de boucle pour verifier les entrées de ces colonnes
  nom <- NULL
  for(i in 1:dim(fs)[2]){
    if(all(is.na(fs[i])) == FALSE)
      nom <- c(nom, names(fs)[i])
  }
  stop(paste("Vérifiez les colonnes suivantes de vos données (ne doit contenir que des NA) :", paste(nom, collapse = ", "), collapse = " "))
}



#### Etape 2 - Verifier l'orthographe des types d'habitat et de campagnes - entree limitee dans coleo ####
if(all(unique(data2$type_hab) %in% c('lac', 'rivière', 'forestier', 'marais', 'marais côtier', 'toundrique', 'tourbière')) == FALSE){
  stop("Vérifiez que le choix du type d'habitat soit contenu dans la liste suivante : 'lac', 'rivière', 'forestier', 'marais', 'marais côtier', 'toundrique', 'tourbière'")
}

if(all(unique(data2$o_or_p) %in% c("odonates", "papilionidés")) == FALSE){
  stop("Vérifiez que le choix du type d'habitat soit contenu dans la liste suivante : 'odonates', 'papilionidés'")
}

#### Etape 3 - Verifier que le code des cellules correspondent aux codes des sites ####
if(all(data2$cell_code == stringr::str_sub(data2$site_code, 1, -5)) == FALSE){
  stop("Vérifier que le code des cellules correspondent au code des sites et vice versa")
}

#### Etape 4 - Formater les dates - Passer de mm/dd/YYYY hh:mm:ss AM/PM a YYYY-mm-dd ####
library(tidyr)
data2$date <- as.character(data2$date)
data2$date <- stringr::str_sub(data2$date, 1, 10)

data2 <- data2 %>% 
  separate(date,
           into = c("mm", "dd", "YYYY"),
           sep = "/")
data2$opened_at <- paste(data2$YYYY, data2$mm, data2$dd, sep = "-")

#### Etape 5 - Formater données en vue de l'injection dans coleo ####

campaign <- NULL

for(i in 1:dim(data2)[1]){
  if(data2$capture_ou_vu[i] == "capture"){
    
    num <- data2$num[i]
    abondance <- data2$abondance_labo[i]
    rank <- data2$rank_labo[i]
    category <- data2$category_labo[i]
    type <- data2$o_or_p_labo[i]
    
    if(type == "odonates"){
      
      taxa_name <- data2$odonate[i]
      
    }else{
      taxa_name <- data2$papillon[i]  
    }
    row_df <- data.frame(num, type, taxa_name, rank, category, abondance)
    campaign <- rbind(campaign, row_df)
  } else {
    
    num <- data2$num[i]
    abondance <- data2$abondance_cap[i]
    rank <- data2$rank_cap[i]
    category <- data2$category_cap[i]
    type <- data2$o_or_p[i]
    taxa_name <- data2$taxa_name_p[i]
    
    row_df <- data.frame(num, type, taxa_name, rank, category, abondance)
    campaign <- rbind(campaign, row_df)
  }
}

# Fusion 
campaign <- dplyr::left_join(campaign,
                         data2[,c("num",
                                  "cell_code",
                                  "site_code",
                                  "type_hab",
                                  "lat",
                                  "lon",
                                  "opened_at",
                                  "technicien_1",
                                  "time_start",
                                  "time_finish",
                                  "temp_c",
                                  "sky",
                                  "wind",
                                  "note")],
                         by = "num")
campaign$closed_at <- campaign$opened_at

# Gestion des heures
campaign$time_finish <- stringr::str_sub(as.character(campaign$time_finish), 1, -4)
campaign$time_start <- stringr::str_sub(as.character(campaign$time_start), 1, -4)

# Gestion de la liste des tech
tech <- stringr::str_split(campaign$technicien_1, ",")

tech <- lapply(tech, as.list)
campaign$technicien_1 <- tech

names(campaign)[names(campaign) == "technicien_1"] <- "technician_list"

#### Etape 6 - Tester l'injection dans coleo - ODONATES ####

camp <- campaign[campaign$type == "odonates",]
# Retrait des lignes avec NA dans taxa_name
camp <- camp[!is.na(camp$taxa_name),]
# ici correction orthographe tourbiere
camp$type_hab[camp$type_hab == "tourbiere"] <- "tourbière"

# Reprise ici de la vignette odonate
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/AGOLtoCOLEO")
# 7.2. Acquisition des informations dans Coléo
# Acquisition cellules Coléo
cells <- rcoleo::get_cells()
cells <- do.call("rbind", cells[[1]]$body)

# Acquisition sites Coléo
sites <- rcoleo::get_sites()
sites <- do.call("rbind", sites[[1]]$body)

# Acquisition nom espèces Coléo
species <- rcoleo::get_species()
species <- do.call("rbind", species[[1]]$body)

# Acquisition des attributs dans Coléo
attrs <- rcoleo::get_gen("/attributes")
attrs <- do.call(plyr::rbind.fill, attrs$body)

# 7.3.1. Vérification
# Test pour vérifier l'existence des cellules dans Coléo
cell_abs <- rcoleo::COLEO_comp(unique(camp$cell_code),
                               unique(cells$cell_code))
cell_abs

# Récupération des cell_id
camp <- dplyr::left_join(camp,
                         cells[, c("id", "cell_code")],
                         by = "cell_code")
names(camp)[names(camp) == "id"] <- "cell_id"

# 7.3.2. Vérification
# Test pour vérifier l'existence des sites dans Coléo
site_abs <- rcoleo::COLEO_comp(unique(camp$site_code),
                               unique(sites$site_code))
site_abs

# Récupération des site_id
camp <- dplyr::left_join(camp,
                         sites[, c("id", "site_code")],
                         by = "site_code")
names(camp)[names(camp) == "id"] <- "site_id"

# 7.3.3. Vérification
# Test pour vérifier l'existence des noms des espèces dans Coléo
sp_abs <- rcoleo::COLEO_comp(unique(camp$taxa_name),
                             unique(species$name))
sp_abs

# 8.1.1. Sélection
camp_camp <- dplyr::select(camp,
                           site_id,
                           type,
                           technician_list,
                           opened_at,
                           closed_at)
# 8.1.2. Retrait des duplicat
camp_camp <- camp_camp[!duplicated(camp_camp),]
# 8.1.4. Conversion de l'objet pour l'injection
camp_ls <- apply(camp_camp, 1, as.list)
# 8.1.5. Injection
COLEO_camp_inj <- rcoleo::post_campaigns(camp_ls) 

# 8.1.6. Liste des campagnes
campaigns <- rcoleo::get_campaigns()
campaigns <- do.call(plyr::rbind.fill, campaigns[[1]]$body)

# 8.1.7. Récupération des IDs des campagnes
camp <- dplyr::left_join(camp,
                         campaigns[, c("id", "site_id", "opened_at", "type")],
                         by = c("site_id", "opened_at", "type"))

names(camp)[names(camp) == "id"] <- "campaign_id"

# 8.2.1. Sélection
land_camp <- dplyr::select(camp,
                           campaign_id,
                           lat,
                           lon)

# 8.2.2. Retrait des duplicats
land_camp <- land_camp[!duplicated(land_camp),]
# 8.2.3. Conversion de l'objet pour l'injection
land_ls <- apply(land_camp, 1, as.list)
# 8.2.4. Création de la variable `geom`
geom <- apply(land_camp, 1, function(x){
  
  if(!any(is.na(x["lat"]),is.na(x["lon"]))){
    
    return(geojsonio::geojson_list(as.numeric(c(x["lon"],x["lat"])))$features[[1]]$geometry)
    
  } else {
    
    return(NA)
    
  }})
# 8.2.5. Fusion des listes
for(i in 1:length(land_ls)){
  
  land_ls[[i]]$geom <- geom[i][[1]]
  
  if(is.list(land_ls[[i]]$geom)){
    
    land_ls[[i]]$geom$crs <- list(type = "name", properties = list(name = "EPSG:4326"))
  }
}
# 8.2.6. Injection
COLEO_land_inj <- rcoleo::post_landmarks(land_ls)
# 8.3.1. Sélection
env_camp <- dplyr::select(camp,
                   campaign_id,
                   wind,
                   sky,
                   temp_c)
# 8.3.2. Retrait des duplicats
env_camp <- env_camp[!duplicated(env_camp),]

# Conversion des variables
env_camp$wind <- as.character(env_camp$wind)
env_camp$sky <- as.character(env_camp$sky)
# 8.3.3. Conversion de l'objet pour l'injection
env_camp_ls <- apply(env_camp, 1, as.list)
# 8.3.4. Injection
COLEO_env_inj <- rcoleo::post_environments(env_camp_ls)
# 8.4.1. Sélection
eff_camp <- dplyr::select(camp,
                   campaign_id,
                   time_start,
                   time_finish)
# 8.4.2. Retrait des duplicats
eff_camp <- eff_camp[!duplicated(eff_camp),]
# 8.4.3. Conversion de l'objet pour l'injection
eff_camp_ls <- apply(eff_camp, 1, as.list)
# 8.4.4. Injection
COLEO_eff_inj <- rcoleo::post_efforts(eff_camp_ls) 
# 8.5.1. Création & sélection
# Création de 2 variables nécessaires
camp$date_obs <- camp$opened_at
camp$is_valid <- 1 # valeur de 1 par défaut

# Sélection des champs d'intérêts
obs_camp <- dplyr::select(camp,
                   date_obs,
                   is_valid,
                   notes = note,
                   campaign_id)
# 8.5.2. Retrait des duplicats
obs_camp <- obs_camp[!duplicated(obs_camp),]
# 8.5.3. Conversion de l'objet pour l'insertion
obs_camp_ls <- apply(obs_camp, 1, as.list)
# 8.5.4. Injection
COLEO_obs_inj <- rcoleo::post_obs(obs_camp_ls)

# 8.5.5. Acquisition de la liste d'observations de Coléo
obs <- rcoleo::get_gen("/observations")
obs <- do.call(plyr::rbind.fill, obs$body)

# Mise à jour des données à injecter avec l'observation_id
camp <- dplyr::left_join(camp,
                         obs[, c("id", "campaign_id", "date_obs")],
                         by = c("campaign_id", "date_obs"))
names(camp)[names(camp) == "id"] <- "observation_id"
# 8.6.1. Sélection
obs_spe_camp <- dplyr::select(camp,
                       observation_id,
                       value = abondance,
                       taxa_name)

# Ajout d'une variable
obs_spe_camp$variable <- "abondance"

# 8.6.2. Conversion de l'objet pour l'injection
obs_spe_camp_ls <- apply(obs_spe_camp, 1, as.list)

# 8.6.3. Injection
COLEO_obsref_inj <- rcoleo::post_obs_species(obs_spe_camp_ls)

#### Etape 6BIS - Tester l'injection dans coleo - PAPILIONIDES ####

camp <- campaign[campaign$type == "papilionidés",]
# Retrait des lignes avec NA dans taxa_name
camp <- camp[!is.na(camp$taxa_name),]
# ici correction orthographe tourbiere
camp$type_hab[camp$type_hab == "tourbiere"] <- "tourbière"

# Reprise ici de la vignette papilionides
# 7.2. Acquisition des informations dans Coléo
# Acquisition cellules Coléo
cells <- rcoleo::get_cells()
cells <- do.call("rbind", cells[[1]]$body)

# Acquisition sites Coléo
sites <- rcoleo::get_sites()
sites <- do.call("rbind", sites[[1]]$body)

# Acquisition nom espèces Coléo
species <- rcoleo::get_species()
species <- do.call("rbind", species[[1]]$body)

# Acquisition des attributs dans Coléo
attrs <- rcoleo::get_gen("/attributes")
attrs <- do.call(plyr::rbind.fill, attrs$body)

# 7.3.1. Vérification
# Test pour vérifier l'existence des cellules dans Coléo
cell_abs <- rcoleo::COLEO_comp(unique(camp$cell_code),
                               unique(cells$cell_code))
cell_abs

# Récupération des cell_id
camp <- dplyr::left_join(camp,
                         cells[, c("id", "cell_code")],
                         by = "cell_code")
names(camp)[names(camp) == "id"] <- "cell_id"

# 7.3.2. Vérification
# Test pour vérifier l'existence des sites dans Coléo
site_abs <- rcoleo::COLEO_comp(unique(camp$site_code),
                               unique(sites$site_code))
site_abs

# Sélection des lignes du tableau concernant les sites manquants
site_df <- camp[camp$site_code %in% site_abs, c("cell_id", "site_code", "type_hab", "opened_at", "lat", "lon")]

# Retrait des lignes dupliquées
site_df <- site_df[!duplicated(site_df),]

# Changement du nom de la variable "type_hab" pour correspondre à celle de Coléo ("type")
names(site_df)[names(site_df) == "type_hab"] <- "type"

# Création de la variable geom à partir des variables "lat" & "lon"
site_df_ls <- apply(site_df, 1, as.list) # Création de la liste
str(site_df_ls) # Vérification de la structure de l'objet

geom <- apply(site_df,1, function(x){
  
  if(!any(is.na(x["lat"]), is.na(x["lon"]))){
    
    return(geojsonio::geojson_list(as.numeric(c(x["lon"], x["lat"])))$features[[1]]$geometry)
    
  } else {
    
    return(NA)
    
  }})

for(i in 1:length(site_df_ls)){ # Fusionner les deux listes (geomations + sites)
  
  site_df_ls[[i]]$geom <- geom[i][[1]]
  if(is.list(site_df_ls[[i]]$geom)){
    
    site_df_ls[[i]]$geom$crs <- list(type = "name",
                                     properties = list(name="EPSG:4326"))
  }
}

# Envoi de la liste des nouveaux sites vers Coléo
COLEO_sites <- rcoleo::post_sites(site_df_ls)

# Mise à jour de la liste des sites provenant de Coléo
sites <- rcoleo::get_sites()
sites <- do.call("rbind", sites[[1]]$body)

# Récupération des site_id
camp <- dplyr::left_join(camp,
                         sites[, c("id", "site_code")],
                         by = "site_code")
names(camp)[names(camp) == "id"] <- "site_id"

# 7.3.3. Vérification
# Test pour vérifier l'existence des noms des espèces dans Coléo
sp_abs <- rcoleo::COLEO_comp(unique(camp$taxa_name),
                             unique(species$name))
sp_abs
# 8.1.1. Sélection
camp_camp <- dplyr::select(camp,
                           site_id,
                           type,
                           technician_list,
                           opened_at,
                           closed_at)
# 8.1.2. Retrait des duplicat
camp_camp <- camp_camp[!duplicated(camp_camp),]
# 8.1.4. Conversion de l'objet pour l'injection
camp_ls <- apply(camp_camp, 1, as.list)
# 8.1.5. Injection
COLEO_camp_inj <- rcoleo::post_campaigns(camp_ls) 
# 8.1.6. Liste des campagnes
campaigns <- rcoleo::get_campaigns()
campaigns <- do.call(plyr::rbind.fill, campaigns[[1]]$body)
# 8.1.7. Récupération des IDs des campagnes
camp <- dplyr::left_join(camp,
                         campaigns[, c("id", "site_id", "opened_at", "type")],
                         by = c("site_id", "opened_at", "type"))

names(camp)[names(camp) == "id"] <- "campaign_id"
# 8.2.1. Sélection
land_camp <- dplyr::select(camp,
                           campaign_id,
                           lat,
                           lon)
# 8.2.2. Retrait des duplicats
land_camp <- land_camp[!duplicated(land_camp),]
# 8.2.3. Conversion de l'objet pour l'injection
land_ls <- apply(land_camp, 1, as.list)
# 8.2.4. Création de la variable `geom`
geom <- apply(land_camp, 1, function(x){
  
  if(!any(is.na(x["lat"]),is.na(x["lon"]))){
    
    return(geojsonio::geojson_list(as.numeric(c(x["lon"],x["lat"])))$features[[1]]$geometry)
    
  } else {
    
    return(NA)
    
  }})
# 8.2.5. Fusion des listes
for(i in 1:length(land_ls)){
  
  land_ls[[i]]$geom <- geom[i][[1]]
  
  if(is.list(land_ls[[i]]$geom)){
    
    land_ls[[i]]$geom$crs <- list(type="name",properties=list(name="EPSG:4326"))
    
  }
}
# 8.2.6. Injection
COLEO_land_inj <- rcoleo::post_landmarks(land_ls)
# 8.3.1. Sélection
env_camp <- dplyr::select(camp,
                   campaign_id,
                   wind,
                   sky,
                   temp_c)
# 8.3.2. Retrait des duplicats
env_camp <- env_camp[!duplicated(env_camp),]

# Conversion des variables
env_camp$wind <- as.character(env_camp$wind)
env_camp$sky <- as.character(env_camp$sky)
# 8.3.3. Conversion de l'objet pour l'injection
env_camp_ls <- apply(env_camp, 1, as.list)
# 8.3.4. Injection
COLEO_env_inj <- rcoleo::post_environments(env_camp_ls)
# 8.4.1. Sélection
eff_camp <- dplyr::select(camp,
                   campaign_id,
                   time_start,
                   time_finish)
# 8.4.2. Retrait des duplicats
eff_camp <- eff_camp[!duplicated(eff_camp),]
# 8.4.3. Conversion de l'objet pour l'injection
eff_camp_ls <- apply(eff_camp, 1, as.list)
# 8.4.4. Injection
COLEO_eff_inj <- rcoleo::post_efforts(eff_camp_ls) 
# 8.5.1. Création & sélection
# Création de 2 variables nécessaires
camp$date_obs <- camp$opened_at
camp$is_valid <- 1 # valeur de 1 par défaut

# On sélectionne les champs d'intérêts.
obs_camp <- dplyr::select(camp,
                   date_obs,
                   is_valid,
                   notes = note,
                   campaign_id)
# 8.5.2. Retrait des duplicats
obs_camp <- obs_camp[!duplicated(obs_camp),]
# 8.5.3. Conversion de l'objet pour l'insertion
obs_camp_ls <- apply(obs_camp, 1, as.list)
# 8.5.4. Injection
COLEO_obs_inj <- rcoleo::post_obs(obs_camp_ls)
# 8.5.5. Acquisition de la liste d'observations de Coléo
obs <- rcoleo::get_gen("/observations")
obs <- do.call(plyr::rbind.fill, obs$body)

# Mise à jour des données à injecter avec l'observation_id
camp <- dplyr::left_join(camp, obs[, c("id", "campaign_id", "date_obs")], by = c("campaign_id", "date_obs"))
names(camp)[names(camp) == "id"] <- "observation_id"
# 8.6.1. Sélection
obs_spe_camp <- dplyr::select(camp,
                       observation_id,
                       value = abondance,
                       taxa_name)

# Ajout d'une variable
obs_spe_camp$variable <- "abondance"
# 8.6.2. Conversion de l'objet pour l'injection
obs_spe_camp_ls <- apply(obs_spe_camp, 1, as.list)
# 8.6.3. Injection
COLEO_obsref_inj <- rcoleo::post_obs_species(obs_spe_camp_ls)
