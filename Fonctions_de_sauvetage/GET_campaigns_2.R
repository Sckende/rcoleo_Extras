funRcoleo <- list.files(path = "/home/claire/PostDoc_COLEO/GitHub/rcoleo_CCJ/R", full.names = TRUE)[-c(3,11)]
lapply(funRcoleo, source)

#' Obtenir l'ensemble des campagnes attachées à un site
#'
#' @param site_code `character` vecteur contenant les codes de sites pour lesquelles ont désire récupérer les campagnes (ex. 134_111_F01)
#' @param opened_at `character` vecteur contenant les dates de début de campagnes (ex. 2017-01-30)
#' @param closed_at `character` vecteur contenant les dates de fin de campagnes (ex. 2017-01-30)
#' @param type `character` vecteur contenant le type de campagnes d'inventaires réalisé (ex. végétation)
#' @return
#' Retourne une objet de type `list` contenant les réponses de l'API. Chaque niveau de la liste correspond à une page. Pour chacun des appels sur l'API (page), la classe retourné est `getSuccess` ou `getError`. Une réponse de classe `getSuccess` est une liste à deux niveaux composé du contenu (`body`), et la réponse [httr::response]. Une réponse de classe `getError` dispose de la même structure mais ne contiendra pas de body, seulement la réponse de l'API.
#' @inheritParams get_gen
#' @examples
#' \dontrun{
#' get_campaigns()
#' get_campaigns(type="végétation")
#' }
#' @export

get_campaigns_2 <- function(site_code = NULL, opened_at = NULL, closed_at = NULL, type = NULL, ...){

  # Preparation de l'objet de sortie
  responses <- list()
  class(responses) <- "coleoGetResp"

  endpoint <- endpoints()$campaigns

  # Si tous les arguments sont nuls
  if(all(is.null(site_code), is.null(opened_at), is.null(closed_at), is.null(type))){

    responses[[1]] <- get_gen(endpoint, ...)

  } else {

    # Retrieve the site id
    if(!is.null(site_code)){
      sites <- get_sites(site_code=site_code#, endpoint=endpoints()$sites
                         )
      site_code <- sapply(sites,function(x) x$body[[1]][,"id"])
    } else {
      site_code <- NULL
    }

    # tests args to set iterator
    len <- max(c(length(site_code),length(opened_at),length(closed_at),length(type)))

    # Prep query
    for(r in 1:len){

      query <- list(site_id=site_code[r],
                    opened_at = opened_at[r],
                    closed_at = closed_at[r],
                    type = type[r])

      responses[[r]] <- get_gen(endpoint,query=query, ...)
    }
  }

  return(responses)

}
