# RColeo - Test de la fonction get_gen() et de la validité des endpoints

Rappel
*Champs communs à la plupart des tables dans COLEO* (champs en gras sont obligatoires)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
**id** | nombre entier | Identifiant unique | |
created_at | date-heure | Date et heure de création | |
updated_at | date-heure | Date et heure de mise à jour | |

## endpoints = "/cells"
Point d'accès: /api/v1/cells

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Non

Sortie de la requête: 

* $body[[1:7]] = 568 entrées ($body[[7]] = a tibble: 0 x 0)
* 8 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
name | texte | Nom de la cellule | |
cell_code | texte | Code de la cellule | |
geom | geometry | Localisation de la cellule | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**sites**| | | |
**geom.type**| | | |
**geom.coordinates**| | | |

***

## endpoints = "/sites"
Point d'accès: /api/v1/sites

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Non

Sortie de la requête: 

* $body[[1]] = 68 entrées
* 19 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id*| nombre entier | Identifiant unique | |
cell_id | nombre entier | Identifiant de la cellule | |
off_station_code_id | texte |  | |
site_code | texte | Identifiant unique du site | |
type | choix | Type d'inventaire réalisé sur le site | 'lac', 'rivière', 'forestier', 'marais', 'marais côtier', 'toundrique', 'tourbière' |
opened_at | date | Date de l'ouverture du site | |
--geom-- | geometry | Localisation du site | |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**campaigns** | | | |
**geom.type** | | | |
**geom.coordinates** | | | |
**cell.id** | | | |
**cell.name** | | | |
**cell.cell_code** | | | |
**cell.created_at** | | | |
**cell.updated_at** | | | |
**cell.geom.type** | | | |
**cell.geom.coordinates** | | | |

***

## endpoints = "/campaigns"
Point d'accès: /api/v1/campaigns

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Non

Sortie de la requête: 

* $body[[1]] = 80 entrées
* 34 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
site_id | texte | Identifiant unique du site attaché à la campagne d'échantillonnage | |
type | choix | Le type campagne réalisé | 'végétation', 'végétation_transect', 'sol', 'acoustique', 'phénologie', 'mammifères', 'papilionidés', 'odonates', 'insectes_sol', 'ADNe','zooplancton', 'température_eau', 'température_sol', 'marais_profondeur_température' |
technicians | ARRAY(texte) | Noms des technicien(ne)s | |
opened_at | date | Date d'ouverture de la campagne d'échantillonnage | |
closed_at | date | Date de fermeture de la campagne d'échantillonnage | |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**efforts** | | | |
**lures** | | | |
**landmarks** | | | |
**traps** | | | |
**environment.id** | | | |
**environment.campaign_id** | | | |
**environment.wind** | | | |
**environment.sky** | | | |
**environment.temp_c** | | | |
**environment.notes** | | | |
**environment.created_at** | | | |
**environment.updated_at** | | | |
**device.id** | | | |
**device.campaign_id** | | | |
**device.sd_card_codes** | | | |
**device.cam_code** | | | |
**device.cam_h_cm**| | | |
**device.mic_logger_code** | | | |
**device.mic_acc_code** | | | |
**device.mic_h_cm_acc** | | | |
**device.mic_ultra_code** | | | |
**device.mic_h_cm_ultra** | | | |
**device.mic_orientation** | | | |
**device.created_at** | | | |
**device.updated_at** | | | |

***

## endpoints = "/efforts"
Point d'accès: /api/v1/efforts

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Oui

Sortie de la requête: 

* $body[[1:2]] = 105 entrées
* 10 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
campaing_id | nombre entier | Numéro d'identification de la campagne | |
stratum | choix | Strate de végétation concernée par l'effort d'échantillonage | 'arbres', 'arbustes/herbacées', 'bryophytes' |
time_start | date et heure | Date et heure de début de l'inventaire | |
time_finish | date et heure | Date et heure de fin de l'inventaire | |
samp_surf | nombre décimal| Taille de la surface d'échantillonage | |
samp_surf_unit | choix | Unité de mesure utilisé pour la surface d'échantillonnage | 'cm2', 'm2', 'km2' |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |

***

## endpoints = "/environment"
Point d'accès: /api/v1/environment

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Non

Sortie de la requête: 

* $body[[1]] = 29 entrées
* 8 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
campaing_id | nombre entier | Numéro d'identification de la campagne | |
wind | choix | Vent en km/h | 'calme (moins de 1 km/h)', 'très légère brise (1 à 5 km/h)', 'légère brise (6 à 11 km/h)', 'petite brise (12 à 19 km/h)', 'jolie brise (20 à 28 km/h)' |
sky | choix | Allure du ciel | 'dégagé (0 à 10 %)', 'nuageux (50 à 90 %)', 'orageux', 'partiellement nuageux (10 à 50 %)', 'pluvieux' |
temp_c | nombre décimal | Date et heure de fin de l'inventaire | |
--samp_surf-- | nombre décimal| Température en celsius | |
--samp_surf_unit-- | choix | Unité de mesure utilisé pour la surface d'échantillonnage | 'cm2', 'm2', 'km2' |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |

***

## endpoints = "/devices"
Point d'accès: /api/v1/devices

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Oui

Sortie de la requête: 

* $body[[1]] = 12 entrées
* 13 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
campaing_id | nombre entier | Numéro d'identification de la campagne | |
sd_card_codes | ARRAY(texte) | Numéro d'identification des cartes SD utilisées |  |
cam_code | ARRAY(texte) | Numéro d'identification de la caméra utilisée |  |
cam_h_cm | nombre décimal | Hauteur de la camera en centimètres | |
mic_logger_code | texte| Numéro d'identification du enregistreur utilisé | |
mic_acc_code | texte | Numéro d'identification du microphone accoustique utilisé | |
mic_h_cm_acc | nombre décimal | Hauteur du microphone ultrason utilisé en centimètres | |
mic_ultra_code | texte | Hauteur du microphone ultrason utilisé en centimètres | |
mic_orientation | choix | Orientation du dispositif | 'n', 's', 'e', 'o', 'ne', 'no', 'se', 'so' |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |

***

## endpoints = "/lures"
Point d'accès: /api/v1/lures

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: non

Sortie de la requête: 

* $body[[1]] = 34 entrées
* 6 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
lure | nombre entier | Numéro d'identification de la campagne | |
installed_at | date | Date d'installation de l'appât/leurre | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
campaign_id | | | |

***

## endpoints = "/traps"
Point d'accès: /api/v1/traps

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: non

Sortie de la requête: 

* $body[[1]] = 44 entrées
* 8 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
trap_code | texte | Code du piège | |
campaign_id | texte | Code d'identification de la campagne | |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**landmarks**| | | |
**samples**| | | |

***

## endpoints = "/landmarks"
Point d'accès: /api/v1/landmarks

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: non

Sortie de la requête: 

* $body[[1]] = 63 entrées
* 21 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
campaing_id | nombre entier | Numéro d'identification de la campagne | |
tree_code | texte | Identifiant unique de l'arbre repère | |
taxa_name | texte | Espèce de l'arbre repère | |
dbh | nombre entier | DHP de l'arbre repère | |
dbh_unit | choix | Unité pour le DHP | 'mm','cm','m' |
axis | choix | L'axe du transect pour la végétation | 'n','se','so' |
azimut | nombre entier | Azimut du dispositif/appât/borne depuis le repère (arbre ou borne), entre 0 et 360 | |
distance | nombre décimal | Distance du dispositif/appât/borne depuis le repère (arbre ou borne) | | 
distance_unit | choix | Distance du dispositif/appât/borne depuis le repère (arbre ou borne) | 'mm','cm','m' |
--geom-- | geometry(POINT) | Position du repère |  |
type | choix |  Type de repère | 'gps', 'arbre', 'gps+arbre', 'borne_axe', 'thermographe' | 
thermograph_type | choix | Type de thermographe | 'eau', 'eau_extérieur', 'sol', 'sol_extérieur', 'puit_marais' |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**trap_id**| | | |
**device_id**| | | |
**lure_id**| | | |
**thermographs**| | | |
**geom.type**| | | |
**geom.coordinates**| | | |

***

## endpoints = "/samples"
Point d'accès: /api/v1/samples

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Oui

Sortie de la requête: 

* $body[[1]] = 81 entrées
* 7 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
sample_code | texte | Numéro de l'échantillon | |
date_samp | date | Date de collecte de l'échantillon | |
trap_id | nombre entier | Numéro d'identification unique du piège | |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |

***

## endpoints = "/thermographs"
Point d'accès: /api/v1/thermographs

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Non

Sortie de la requête: 

     AUCUNE (A tibble: 0 x 0)
***

## endpoints = "/observations"
Point d'accès: /api/v1/observations

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Non

**Inclus dans le résultat**: media, obs_soil, obs_species, obs_soil_decomposition

Cette table est la table principale qui contient les informations communes à toutes les observations. Dépendamment du type de campagne, les informations complémentaires sont dans les tables obs_*

Sortie de la requête: 

* $body[[1:27]] = 2638 entrées
* 25 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
date_obs | date | Date d'observation à l'intérieur de la campagne d'inventaire | |
time_obs | heure HH:mm:ss| Heure de l'observation à l'intérieur de la campagne d'inventaire | |
stratum | choix | Strate de végétation inventoriée (spécifique aux campagnes de type végétation) | 'arborescente', 'arbustive', 'herbacées', 'bryophytes' |
axis | choix | L\'axe du transect pour la végétation | 'n','se','so' |
distance | nombre décimal| La distance le long du transect pour la végétation | | 
distance_unit | choix | Unité de mesure utilisé pour la distance le long du transect | |
depth | nombre décimal | Profondeur pour les observations de zooplancton | |
sample_id | nombre entier | numéro de l'échantillon | |
is_valid | booléen 1/0 | L'observation est-elle valide?| par défaut: 1 |
campaing_id | nombre entier | Numéro d'identification de la campagne | |
--campaing_info-- | champs virtuel | Informations sur la campagne | |
thermograph_id | nombre entier | Numéro du thermographe | |
notes | texte | Commentaires | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**media** | | | |
**obs_soil** | | | |
**obs_soil_decomposition** | | | |
**obs_species.id** | | | |
**obs_species.taxa_name** | | | |
**obs_species.variable** | | | |
**obs_species.value** | | | |
**obs_species.observation_id** | | | |
**obs_species.created_at** | | | |
**obs_species.updated_at** | | | |

  ***

## endpoints = "/obs_species"
Point d'accès: /api/v1/obs_species

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Oui

Sortie de la requête: 

* $body[[1:27]] = 2637 entrées
* 21 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
taxa_name | texte | Nom complet de l'espèce observée | |
variable | texte | Référence vers la table t'attributs | |
value | nombre décimal | Valeur de l'attribut | | 
observation_id | nombre entier | Identifiant unique de la table d'observations| 
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**attribute.variable** | | | |
**attribute.description** | | | |
**attribute.unit** | | | |
**attribute.created_at** | | | | 
**attribute.updated_at** | | | |
**ref_species.name** | | | |
**ref_species.vernacular_fr** | | | |
**ref_species.rank** | | | |
**ref_species.category** | | | | 
**ref_species.tsn** | | | |
**ref_species.vascan_id** | | | | 
**ref_species.bryoquel_id** | | | | 
**ref_species.created_at** | | | |
**ref_species.updated_at** | | | | 

  ***

## endpoints = "/attributes"
Point d'accès: /api/v1/attributes

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Oui

Sortie de la requête: 

* $body[[1]] = 3 entrées
* 5 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table). **Pas de id ici**


Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
variable | texte | Nom de la variable attribuée | |
description | texte | Description de la variable attribuée | |
unit | texte | Unité de la variable attribuée | |
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |

  ***

## endpoints = "/ref_species"
Point d'accès: /api/v1/?

Connexion à la base de données: Invalide

Similaire à la table cells dans COLEO: Non

Sortie de la requête: 

    Error in strsplit(httr::headers(resp)$"content-range", split = "\\D") : 
    l'argument n'est pas une chaîne de caractères

MAIS DONNÉES PRÉSENTES DANS COLEO - Problème avec API ?
***

## endpoints = "/obs_soil_decomposition"
Point d'accès: /api/v1/obs_soil_decomposition

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: ?

Sortie de la requête: 

     AUCUNE (A tibble: 0 x 0)

***

## endpoints = "/media"
Point d'accès: /api/v1/media

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: Oui

Sortie de la requête: 

* $body[[1:1256]] = 125 575 entrées
* 12 champs (en italique = champs générée par la BD; en gras = champs en plus que ceux trouvés dans la table de la BD; --champs-- = champs absent par rapport à la table)

Champs | Type | Description | Options
------------ | ------------- | ------------- | -------------
*id* | nombre entier | Identifiant unique | |
type | choix | Type de média | 'image', 'audio', 'video' | |
recorder | choix | Type d'enregistreur | 'ultrasound', 'audible' |
og_format | texte | Original format (jpeg, png, etc) | |
og_extention | texte | Original extension (.jpg, .png, etc.) | |
uuid | texte | UUID, Identifiant unique généré par Coléo | | 
name | texte | Nom du fichier original | | 
*created_at* | date-heure | Date et heure de création | |
*updated_at*| date-heure | Date et heure de mise à jour | |
**site_id** | | | |
**campaign_id** | | | |
**observations** | | | |

***

## endpoints = "/obs_media"
Point d'accès: /api/v1/obs_media

Connexion à la base de données: Valide

Similaire à la table cells dans COLEO: ?

Sortie de la requête: 

     AUCUNE
***