#### Test injection des campagnes pour "papilionidés" ####
rm(list = ls())

#--------------------------------------------#
# WINDOWS
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")

pap <- read.csv("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/data/Campagne_papillon_V2.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")

head(pap)
tail(pap)
summary(pap)

unique(pap$no_specimen)
unique(pap$note)

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
y <- sort(unique(pap$wind))
x <- sort(unique(envs$wind))

y %in% x

# ciel
y <- sort(unique(pap$sky))
x <- sort(unique(envs$sky))

y %in% x

# type (type_hab)
y <- sort(unique(pap$type_hab)); y
x <- sort(unique(sites$type)); x

y %in% x

#### Préparation des données à injecter ####
# Type de campagnes *** ATTENTION _ ENTRÉES LIMITÉES PAR COLEO ***
pap$type <- "papilionidés"

#### Extra nettoyage ####
pap <- pap[!is.na(pap$opened_at),]
pap <- pap[!(is.na(pap$vernacular_fr) & is.na(pap$taxa_name)),]

#### Vérification campagnes déjà insérées dans Coléo ####
# Préparation
test_pap <- paste(pap$site_code, pap$opened_at, pap$type)
test_coleo <- paste(camps$site.site_code, camps$opened_at, camps$type)

# Test
test1 <- test_pap %in% test_coleo

# Ajout dataframe
pap$statut_coleo <- test1

# On garde uniquement les nouvelles campagnes
pap <- pap[pap$statut_coleo == FALSE,]

#### Vérification cellules déjà insérées dans Coléo ####
cell_manquante <- rcoleo::COLEO_comp(unique(pap$cell_code), cells$cell_code)
cell_manquante
# -------------------- #
# insertion bébé vignette insertion cellule CACHÉE 
# -------------------- #
# ==> injections des cellules "94_192"  "86_180"  "146_134"

# Mise à jour de la liste des cellules issues de Coléo
cells <- rcoleo::get_cells()
cells <- do.call("rbind.fill", cells[[1]]$body)

#### Vérification sites déjà insérés dans Coléo ####
site_manquant <- rcoleo::COLEO_comp(unique(pap$site_code), sites$site_code)
site_manquant
# -------------------- #
# insertion bébé vignette insertion site CACHÉE
# -------------------- #
# ==> injections des sites "94_192_H01"  "86_180_H01"  "149_142_H02" en récupérant l'objet 

# Mise à jour de la liste des sites issues de Coléo
sites <- rcoleo::get_sites()
sites <- do.call("rbind.fill", sites[[1]]$body)

#### Vérification noms d'espéces de référence déjà insérés dans Coléo ####

test2 <- pap$taxa_name %in% species$name
all(test2)
# Si la valeur est TRUE, passer à l'étape suivante. Si la valeur est FALSE, référez vous à la vignette `injection des noms d'espèce`

# -------------------- #
# insertion bébé vignette insertion nom d'espèces CACHÉE
# -------------------- #

# Préparation du dataframe
# pap$stat_sp <- test2
# pap_sp_inj <- pap[pap$stat_sp == FALSE,] # Uniquement les lignes avec `stat_sp` == F
# pap_sp_inj <- select(pap_sp_inj,
#                      name = taxa_name,
#                      vernacular_fr) # colonne nécessaire
# 
# 
# pap_sp_inj <- pap_sp_inj[!duplicated(pap_sp_inj),] # retrait des duplicats
# 
# # Formattage
# pap_sp_inj_ls <- purrr::transpose(pap_sp_inj)
# 
# # Injection
# 
# COLEO_sp_inj <- rcoleo::post_species(pap_sp_inj_ls)

# ***ATTENTION*** Réfléchir au fait que toutes les informations pour les espèces ne sont pas renseignées avec cette méthode 
# ------ FIN DE BB VIGNETTE ------ #

#### Vérification attributs déjà insérés dans Coléo ####

#### Optimisation du tableau à injecter initial ####
# Ajout du site id
pap <- dplyr::left_join(pap, sites[, c("id", "site_code")], by = "site_code")
names(pap)[names(pap) == "id"] <- "site_id"

#### Insertion des campagnes de papillons ####

# On commence par séléctionner les champs d’interêts & on matche les noms de variables avec celles de Coléo.

camp_pap <- dplyr::select(pap,
                          site_id,
                          type,
                          technician_1,
                          technician_2,
                          opened_at,
                          closed_at)
# On garde une ligne unique par nouvelle campagne.
camp_pap <- camp_pap[!duplicated(camp_pap),]

# On créé la liste pour le nom des techniciens
tech <- list() # Création d'un objet `list` vide

for(i in 1:length(camp_pap$site_id)){
  tech[[i]] <- list(camp_pap$technician_1[[i]], camp_pap$technician_2[[i]])
} # Chaque niveau de la liste correspond à une association des deux noms des technicien/ne/s pour chaque ligne du tableau

camp_pap$technicians <- tech # Ajout de la liste au tableau à injecter dans Coléo

# On transforme le tableau en liste pour pouvoir injecter les données dans Coléo.
camp_ls <- apply(camp_pap, 1, as.list)
str(camp_ls)

# On injecte.
COLEO_camp_inj <- rcoleo::post_campaigns(camp_ls) # ==> DONE

# On met à jour la liste de campagnes provenant de Coléo.
camps <- rcoleo::get_campaigns()
camps <- do.call("rbind.fill", camps[[1]]$body)

# Si la liste ne se met pas à jour, redémarrer sa session r avec la commande .rs.restartR()


# On récupère le id unique pour chaque campagne nouvellement insérées.
pap <- dplyr::left_join(pap, camps[, c("id", "site_id", "opened_at", "type")], by = c("site_id", "opened_at", "type"))
names(pap)[names(pap) == "id"] <- "campaign_id"

# *** EN OPTION *** - ici récupération des campagnes pour lesquelles les observations n'ont pas été enregistrées dans coléo
obs <- rcoleo::get_gen("/observations")
obs <- do.call(rbind.fill, obs$body)

y <- pap$campaign_id
x <- unique(obs$campaign_id)
test3 <- y %in% x
 pap$stat_obs <- test3

 pap <- pap[pap$stat_obs == FALSE,]


#### Insertion des environnements ####

# On commence par séléctionner les champs d’interêts.
env_pap <- select(pap,
                  campaign_id,
                  wind,
                  sky,
                  temp_c)
head(env_pap)

# On garde une ligne par campagne.
env_pap <- env_pap[!duplicated(env_pap),]

# On transforme en liste.
env_pap_ls <- apply(env_pap, 1, as.list)
str(env_pap_ls)

# On injecte.
COLEO_env_inj <- rcoleo::post_environments(env_pap_ls) # ==> DONE

#### Insertion des efforts ####
# On sélectionne les champs d'intérêts.
eff_pap <- select(pap,
                  campaign_id,
                  time_start,
                  time_finish)


# On garde une ligne par campagne.
eff_pap <- eff_pap[!duplicated(eff_pap),]

# On transforme en liste.
eff_pap_ls <- apply(eff_pap, 1, as.list)
str(eff_pap_ls)

# On injecte.
COLEO_eff_inj <- rcoleo::post_efforts(eff_pap_ls) # ==> DONE


#### Insertion des observations ####
pap$date_obs <- pap$opened_at
# On sélectionne les champs d'intérêts.
obs_pap <- select(pap,
                  date_obs,
                  notes = note,
                  campaign_id)

# On ajoute deux variables supplémentaires.
obs_pap$is_valid <- 1 # valeur de 1 par défaut

# On garde une ligne par campagne.
obs_pap <- obs_pap[!duplicated(obs_pap),]

# On formatte les données à insérer.
obs_pap_ls <- apply(obs_pap, 1, as.list)
str(obs_pap_ls)

# On injecte.

COLEO_obs_inj <- rcoleo::post_obs(obs_pap_ls)

# Acquisition de la liste des observations de Coléo
obs <- rcoleo::get_gen("/observations")
obs <- do.call(rbind.fill, obs$body)

# Mise à jour des données à injecter avec l'observation_id
pap <- dplyr::left_join(pap, obs[, c("id", "campaign_id", "date_obs")], by = c("campaign_id", "date_obs"))
names(pap)[names(pap) == "id"] <- "observation_id"

#### Insertion des observations ####
# On sélectionne les champs d'intérêts.
obs_spe_pap <- select(pap,
                      observation_id,
                      value = abondance,
                      taxa_name)

# On ajoute une variable.
obs_spe_pap$variable <- "abondance"

# On formatte les données à injecter.
obs_spe_pap_ls <- apply(obs_spe_pap, 1, as.list)
str(obs_spe_pap_ls)

# On injecte.
COLEO_obsref_inj <- rcoleo::post_obs_species(obs_spe_pap_ls)
