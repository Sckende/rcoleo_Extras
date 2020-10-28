# install.packages("devtools")
# install.packages("dplyr")
library(dplyr)
library(devtools)
#install_github("TheoreticalEcosystemEcology/rcoleo")
library(rcoleo)

#saveRDS("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", ".httr-oauth")

#L’étape suivante permet d’extraire la liste d’espèces déjà sur Coléo
taxa_list <- get_species()

str(taxa_list, max.level = 3)

all_things <- dplyr::bind_rows(taxa_list[[1]]$body)


# Cette étape permet d’intégrer les données de la base de données des organismes vivants à ajouter à Coléo
corrections <- read.csv("Test_injec_sp.csv", header = TRUE, sep = ';', stringsAsFactors = FALSE, encoding = "UTF-8")

#Cette étape permet de s’assurer que les noms de colonnes sont les mêmes dans Coléo que dans votre base de données
glimpse(all_things)
glimpse(corrections)

#Étape facultative, elle permet de changer des noms de colonnes si ils ne sont pas écrits de la même façon que Coléo. Comme dans l’exemple ci-haut, la colonne name du fichier de corrections est écrite X.U.FEFF.name, ce qui n’est pas adéquat.

names(corrections)[1] <- c("name")
all(names(corrections) %in% names(all_things))

#Cette étape permet de visualiser quelles entrées de la base de données se retrouvent déjà dans Coléo en fonction du nom latin. Elle permet donc d’éviter les répétitions d’entrées.

semi_join(corrections, all_things, by = "name")

# En lien avec l’étape précédente, celle-ci permet de sélectionner toutes les entrées qui ne se trouvent pas dans Coléo en fonction du nom latin afin d’éviter les répétitions.

correctionsuniques <- anti_join(corrections, all_things, by = "name")

# Cette étape est seulement nécessaire si la base de données comprend des colonnes qui ne sont pas dans Coléo, ou si les colonnes tsn et/ou bryoquel comprennent des valeurs NA

correctionscol <- select(correctionsuniques, name, vernacular_fr, rank, category, tsn, vascan_id, bryoquel_id, createdAt, updatedAt) # Note: L’injection ne fonctionnera pas pour les entrées avec des valeurs de tsn et/ou bryoquel de NA. Après avoir injecté toutes les espèces qui ont un tsn et/ou bryoquel, enlever tsn et/ou bryoquel de la fonction si haut. De cette façon, l’injection se fera sans le tsn/bryoquel_id pour les espèces qui n’en ont pas.

# Transposer le dataframe afin de l’injecter

correctionstoupload <- purrr::transpose(correctionscol) #

# Cette dernière étape injecte les données de la base de données dans Coléo

rcoleo:::post_species(correctionstoupload)
