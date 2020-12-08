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
#setwd("C:/Users/HP_9470m/Desktop/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")
setwd("~/Bureau/PostDoc_COLEO/GitHub/rcoleo_Extras/Tests_injections")

# Informations initiales nécessaires
path <- "/campaigns"
bearer <- function() ifelse(file.exists(".httr-oauth"), as.character(readRDS(".httr-oauth")), NA)
ua <- httr::user_agent("rcoleo")
limit <- 100

# Construction et envoi de la requete DELETE pour retirer des observations dupliquées

# Pour ce cas, retrait des campagnes odonates
# camp2 <- rcoleo::get_campaigns(type = "odonates")
# camp2 <- do.call(plyr::rbind.fill, camp2[[1]]$body)

# camp2 <- rcoleo::get_campaigns(type = "papilionidés")
# camp2 <- do.call(plyr::rbind.fill, camp2[[1]]$body)

# camp2 <- rcoleo::get_campaigns(type = "zooplancton")
# camp2 <- do.call(plyr::rbind.fill, camp2[[1]]$body)

for(i in camp2$id){
  
  url <- httr::modify_url("https://coleo.biodiversite-quebec.ca", path = paste0("/api/v1",path, "/", i))
  
  resp <- httr::DELETE(url = url,
                       config = httr::add_headers("Content-type" = "application/json",
                                                  Authorization = paste("Bearer", bearer()),
                                                  Accept = "application/json"),
                       ua)  
  
  print(resp$status_code)
}

