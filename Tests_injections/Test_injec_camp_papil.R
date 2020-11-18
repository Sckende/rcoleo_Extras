#### Test injection des campagnes pour "papilionidés" ####
rm(list = ls())

#--------------------------------------------#
# WINDOWS
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
pap <- read.csv("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/data/Campagne_papillon.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")

head(pap)
tail(pap)
summary(pap)

#### Chargement des packages ####
library(dplyr)
library(plyr)
library(rcoleo)
library(stringr)

#### Importation des données Coléo ####
# Les cellules
cells <- rcoleo::get_cells()
cells <- do.call("rbind.fill", cells[[1]]$body)

# Les sites
sites <- rcoleo::get_sites()
sites <- do.call("rbind.fill", sites[[1]]$body)

# Les campagnes 
camps <- rcoleo::get_campaigns()
camps <- do.call("rbind.fill", camps[[1]]$body)

# Les noms d'espèces de référence
species <- rcoleo::get_species()
species <- do.call("rbind.fill", species[[1]]$body)

# Les attributs
attrs <- rcoleo::get_gen("/attributes")
attrs <- do.call("rbind.fill", attrs$body)

# Les environnements
envs <- rcoleo::get_gen("/environment")
envs <- do.call("rbind.fill", envs$body)

#### Vérification des variables aux entrées limitées ####
# vent
sort(unique(pap$vent))
sort(unique(envs$wind))

pap$vent[which(pap$vent == sort(unique(pap$vent))[3])] <- "Legere brise"

vent_pap <- c("Calme",
              "Legere brise",
              "Petite brise",
              "Tres legere brise")

wind_coleo <- c("calme (moins de 1 km/h)",
                "légère brise (6 à 11 km/h)",
                "petite brise (12 à 19 km/h)",
                "très légère brise (1 à 5 km/h)")

for (i in 1:length(vent_pap)){
  pap$vent <- str_replace_all(pap$vent, vent_pap[i], wind_coleo[i])
}

# ciel
sort(unique(pap$ciel))
sort(unique(envs$sky))

pap$ciel[which(pap$ciel == "Degage" | pap$ciel == "Degage ")] <- "degage (0 a 10%)"

ciel_pap <- c("degage (0 a 10%)",
              "Nuageux ",
              "Partiellement nuageux ")

sky_coleo <- c("dégagé (0 à 10 %)",
                "nuageux (50 à 90 %)",
                "partiellement nuageux (10 à 50 %)")

for (i in 1:length(ciel_pap)){
  pap$ciel <- str_replace_all(pap$ciel, ciel_pap[i], sky_coleo[i])
}

# type (hab_type)
names(pap)[names(pap) == "type"] <- "hab_type"

sort(unique(pap$hab_type))
sort(unique(sites$type))

pap$hab_type <- str_replace_all(pap$hab_type, "Marais", "marais")
pap$hab_type[which(pap$hab_type == "tourbiere" | pap$hab_type == "Tourbiere" | pap$hab_type == "tourbiere ")] <- "tourbière"

#### Vérification campagnes déjà insérées dans Coléo ####
