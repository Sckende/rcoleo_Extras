#### Tuto - API building ####
# https://cran.r-project.org/web/packages/httr/vignettes/api-packages.html

library(httr)
git_api <- function(path){
  url <- httr::modify_url("https://api.github.com", path = path)
  httr::GET(url)
}

##############################
library(httr)
library(jsonlite)
github_api <- function(path) {
  url <- httr::modify_url("https://api.github.com", path = path) #creation de l'url qui permettra d'acquerir la ressource
  
  resp <- httr::GET(url) #acquisition de la ressource - formulation d'une requete GET
  if (httr::http_type(resp) != "application/json") {#verification du format des donnees acquises (XML/JSON)
    stop("API did not return json", call. = FALSE)
  }
  
  parsed <- jsonlite::fromJSON(httr::content(resp, as = "text"), simplifyVector = FALSE) #Conversion du contenu de la requete (forma text) en JSON

  
  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "github_api"
  )
}

print.github_api <- function(x, ...) {
  cat("<GitHub ", x$path, ">\n", sep = "")
  str(x$content)
  invisible(x)
}

github_api("/users/hadley")

####################################
#### Tests grandeur nature GET ####
###################################
library(rcoleo)
setwd("C:/Users/HP_9470m/Desktop/rcoleo_Extras/Tests_injections/Test_injections_sites")

# Informations initiales nécessaires
path <- "/campaigns"
bearer <- function() ifelse(file.exists(".httr-oauth"), as.character(readRDS(".httr-oauth")), NA)
ua <- httr::user_agent("rcoleo")
limit <- 100

# Construction et envoi de la requete GET

#get_get <- function(path){
url <- httr::modify_url("https://coleo.biodiversite-quebec.ca", path = paste0("/api/v1",path))

resp <- httr::GET(
  url = url,
  config = httr::add_headers("Content-type" = "application/json",
                       Authorization = paste("Bearer", bearer()),
                       Accept = "application/json"),
  ua
)
#}

# Exploration de la réponse du serveur

str(resp)
http_type(resp)
http_status(resp)

httr::content(resp)
httr::content(resp, as = "raw") # Egal "body" de la reponse envoyee par le serveur - Ce qui interesse l'utilisateur lors de requete GET
httr::content(resp, as = "text") # Contenu du "body" en format text

#respR <- jsonlite::fromJSON(content(resp, as = "text")) # Conversion de l'objet JSON vers un object R
respR <- jsonlite::fromJSON(httr::content(resp, as = "text"), flatten = TRUE, simplifyDataFrame = TRUE) # Conversion de l'objet JSON vers un object R - dataframe
class(respR)
summary(respR)
jsonlite::toJSON(respR,
                 pretty = TRUE)

#######################################
#### Tests grandeur nature DELETE ####
#####################################

library(rcoleo)
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
setwd("~/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")

# Informations initiales nécessaires
path <- "/cells"
bearer <- function() ifelse(file.exists(".httr-oauth"), as.character(readRDS(".httr-oauth")), NA)
ua <- httr::user_agent("rcoleo")
limit <- 100

# Construction et envoi de la requete DELETE pour retirer des observations dupliquées

# Pour ce cas, retrait des campagnes odonates
# camp2 <- rcoleo::get_campaigns(type = "odonates")
# camp2 <- do.call(plyr::rbind.fill, camp2[[1]]$body)

# Pour ce cas, retrait des campagnes papillons
# camp2 <- rcoleo::get_campaigns(type = "papilionidés")
# camp2 <- do.call(plyr::rbind.fill, camp2[[1]]$body)

# Pour ce cas, retrait des campagnes zooplanctons
# camp2 <- rcoleo::get_campaigns(type = "zooplancton")
# camp2 <- do.call(plyr::rbind.fill, camp2[[1]]$body)

for(i in noID$id){

  url <- httr::modify_url("https://coleo.biodiversite-quebec.ca", path = paste0("/api/v1",path, "/", i))
  
  resp <- httr::DELETE(url = url,
                       config = httr::add_headers("Content-type" = "application/json",
                                                  Authorization = paste("Bearer", bearer()),
                                                  Accept = "application/json"),
                       ua)  
  
  print(resp$status_code)
}

#######################################
<<<<<<< HEAD
#### Tests grandeur nature MODIFY ####
#####################################

library(rcoleo)
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
setwd("~/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")

# Informations initiales nécessaires
path <- "/cells"
=======
#### Tests grandeur nature MODIFY ou exploration du problème de NA pour la variable wind dans la table "/environment" ####
#####################################
library(rcoleo)
#setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
setwd("~/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")

# Informations initiales nécessaires
path <- "/environment"
>>>>>>> d7a0e4fad9f00c7be605c352692bdfb2720589bd
bearer <- function() ifelse(file.exists(".httr-oauth"), as.character(readRDS(".httr-oauth")), NA)
ua <- httr::user_agent("rcoleo")
limit <- 100

<<<<<<< HEAD
# Modification du noms des cellules avec campagnes déjà insérées dans Coléo #
# Mise à jour du 17 décembre 2020 
setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Correction_nom_cellule")
cell <- rcoleo::get_cells()
cell <- do.call(plyr::rbind.fill, cell[[1]]$body)

upD <- read.csv("./update_namecells_pre2020.csv",
                sep = ";",
                header = TRUE)
#...#

# Construction et envoi de la requete MODIFY pour pour rectifier le nom des cellules existantes

# cellules dans coleo
cell <- rcoleo::get_cells()
cell <- do.call(plyr::rbind.fill, cell[[1]]$body)


for(i in ){
  
  url <- httr::modify_url("https://coleo.biodiversite-quebec.ca", path = paste0("/api/v1",path, "/", i))
  
  resp <- httr::DELETE(url = url,
                       config = httr::add_headers("Content-type" = "application/json",
                                                  Authorization = paste("Bearer", bearer()),
                                                  Accept = "application/json"),
                       ua)  
  
  print(resp$status_code)
}
=======
# Pour ce cas, modification de l'environnement des campagnes odonates
# Step 1 - Récupération des campagne_id pour les campagnes papillons/odonates
campPap <- rcoleo::get_campaigns(type = "papilionidés")
campPap <- do.call(plyr::rbind.fill, campPap[[1]]$body)

campOdo <- rcoleo::get_campaigns(type = "odonates")
campOdo <- do.call(plyr::rbind.fill, campOdo[[1]]$body)

# Step 2 - Récupération des env pour les campagnes Pap
env <- rcoleo::get_gen("/environment")
env <- do.call(plyr::rbind.fill, env$body)

# Pour les pap
envPap <- env[env$campaign_id %in% campPap$id,] # 2 envPap manquants
table(c(envPap$campaign_id, campPap$id)) # ==> ID campagnes manquantes : 608 & 624
View(campPap[campPap$id %in% c(608, 624),]) # ==> Corresponding site_code : 111_115_H01 (608) & 130_87_H01 (624) 

# Pour les odo
envOdo <- env[env$campaign_id %in% campOdo$id,] # 2 envOdo manquants
table(c(envOdo$campaign_id, campOdo$id)) # ==> ID campagnes manquantes : 452 & 471
View(campOdo[campOdo$id %in% c(452, 471),]) # ==> Corresponding site_code : 111_115_H01 (452) & 130_87_H01 (471) 

# Chargement des 2 campagnes manquantes
#data <- readr::read_delim("~/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/data/Campagne_papillon_V2.csv", delim = ";")

data <- readr::read_delim("~/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections/data/Campagne_odonate_V3.csv", delim = ";")

names(campOdo)[names(campOdo) == "site.site_code"] <- "site_code"
#campPap$site_code <- campPap$site.site_code
data$opened_at <- as.character(data$opened_at)


# data <- dplyr::left_join(data, 
#                          campPap[, c("id", "site_code", "opened_at")],
#                          by = c("site_code", "opened_at"))
data <- dplyr::left_join(data, 
                         campOdo[, c("id", "site_code", "opened_at")],
                         by = c("site_code", "opened_at"))
names(data)[names(data) == "id"] <- "campaign_id"

data <- data[data$site_code %in% c("111_115_H01", "130_87_H01"),]
# Sélection
data <- dplyr::select(data,
                   campaign_id,
                   wind,
                   sky,
                   temp_c)
data <-  data[!duplicated(data),]
# Conversion des variables
data$wind <- as.character(data$wind)
data$sky <- as.character(data$sky)

# Formattage de l'objet pour injection
data_ls <- apply(data, 1, as.list)

# Injection
#inj <- rcoleo::post_environments(data_ls)
inj
>>>>>>> d7a0e4fad9f00c7be605c352692bdfb2720589bd
