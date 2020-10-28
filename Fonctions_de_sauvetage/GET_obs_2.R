funRcoleo <- list.files(path = "/home/claire/PostDoc_COLEO/GitHub/rcoleo_CCJ/R", full.names = TRUE)[-10]
lapply(funRcoleo, source)


get_obs_2 <- function (site_code = NULL, opened_at = NULL, closed_at = NULL,
          type = NULL, ...)
{
  endpoint <- endpoints()$observations
  token <- ifelse(is.na(bearer()), list(...)$token, bearer())
  responses <- list()
  class(responses) <- "coleoGetResp"

  # ----------------------------------------------------------------- #
  if (all(is.null(site_code), is.null(opened_at), is.null(closed_at),
          is.null(type))) {
    responses[[1]] <- get_gen(endpoint, ...)
    responses[[1]] <- lapply(responses[[1]]$body, function(page) {
      campaign_ids <- unique(page$campaign_id)
      # campaign_ids <- NULL
      # for(i in 1:length(page)){
      #   c <- unique(page[[i]]$campaign_id)
      #   campaign_ids <- c(campaign_ids, c)
      # }
      #campaign_ids <- unique(campaign_ids)
      #browser()
      campaigns_info <- list()
      for (i in 1:length(campaign_ids)) {
        campaign <- httr::content(httr::GET(url = paste0(server(),
                                                         "/api/v1/campaigns/", campaign_ids[i]),
                                            config = httr::add_headers(`Content-type` = "application/json",
                                                                       Authorization = paste("Bearer", token)),
                                            ua), simplify = TRUE)

        if (is.null(campaign$closed_at))
          campaign$closed_at <- NA
        campaigns_info[[i]] <- data.frame(campaign_id = campaign$id,
                                          site_id = campaign$site_id, opened_at = campaign$opened_at,
                                          closed_at = campaign$closed_at, type = campaign$type)
      }

      campaigns_info <- do.call(plyr::rbind.fill, campaigns_info)
      #browser()
      #page$body <- merge(page$body, campaigns_info, by = "campaign_id")
      page <- merge(page, campaigns_info, by = "campaign_id")
      site_ids <- unique(page$site_id)
      sites_info <- list()

      for (i in 1:length(site_ids)) {
        site <- httr::content(httr::GET(url = paste0(server(),
                                                     "/api/v1/sites/", site_ids[i]), config = httr::add_headers(`Content-type` = "application/json",
                                                                                                                Authorization = paste("Bearer", token)),
                                        ua), simplify = TRUE)
        sites_info[[i]] <- data.frame(site_id = site$id,
                                      site_code = site$site_code, cell_code = site$cell$cell_code)
      }
      sites_info <- do.call(plyr::rbind.fill, sites_info)
      page <- merge(page, sites_info, by = "site_id")
      page <- dplyr::select(page, "id",
                                 "cell_code", "site_code", "opened_at",
                                 "closed_at", "type", "axis",
                                 "distance", "distance_unit", "sample_id",
                                 "date_obs", "obs_species.taxa_name",
                                 "obs_species.variable", "obs_species.value",
                                 "is_valid", "media", "notes",
                                 "created_at", "updated_at")
      return(page)
    })

  ###########################  end of function lapply(responses[[1]], page)##############################################
  }
  ############################# end of first if condition ################################
  else {
    #browser()
    len <- max(c(length(site_code), length(opened_at), length(closed_at),
                 length(type)))

    #------------------------- 21 sept 2020 ----------- #
    for (r in 1:len) {
      #browser()
      cc <- rcoleo::get_campaigns(site_code = site_code[r],
                            opened_at = opened_at[r],
                            closed_at = closed_at[r],
                            type = type[r])
      # cc <- get_campaigns_2(site_code = site_code[r],
      #                             opened_at = opened_at[r],
      #                             closed_at = closed_at[r],
      #                             type = type[r])

      # sortie similaire avec rcoleo::get_campaigns & get_campaigns_2
      ccc <- lapply(cc, function(x) x$body[[1]]$id)
      campaigns_ids <- unlist(ccc)
    }
    #------------------------- 21 sept 2020 ----------- #
    #browser()
    # On récupère les observations pour la campagne concernée
    for (i in 1:length(campaigns_ids)) responses[[i]] <- get_gen(endpoint,
                                                                 query = list(campaign_id = campaigns_ids[i]), ...)
    if(FALSE){
      # TODO: Fonction d'extend plus generic
    responses <- lapply(responses, function(response) {
      lapply(response, function(page) {
        campaign_id <- unique(page$campaign_id)
        stopifnot(length(campaign_id) == 1)
        campaign_info <- httr::content(httr::GET(url = paste0(server(),
                                                              "/api/v1/campaigns/",
                                                              campaign_id),
                                                 config = httr::add_headers(`Content-type` = "application/json",
                                                                            Authorization = paste("Bearer", ifelse(is.na(bearer()),
                                                                                                                   token, bearer()))), ua), simplify = TRUE)
        site_info <- httr::content(httr::GET(url = paste0(server(),
                                                          "/api/v1/sites/", campaign_info$site_id),
                                             config = httr::add_headers(`Content-type` = "application/json",
                                                                        Authorization = paste("Bearer", ifelse(is.na(bearer()),
                                                                                                               token, bearer()))), ua), simplify = TRUE)
        page$site_code <- site_info$site_code
        page$cell_code <- site_info$cell$cell_code
        page$opened_at <- campaign_info$opened_at
        page$closed_at <- campaign_info$closed_at
        page$type <- campaign_info$type
        page <- dplyr::select(page, "id",
                                   "cell_code", "site_code", "opened_at",
                                   "closed_at", "type", "axis",
                                   "distance", "distance_unit", "sample_id",
                                   "date_obs", "obs_species.taxa_name",
                                   "obs_species.variable", "obs_species.value",
                                   "is_valid", "media", "notes",
                                   "created_at", "updated_at")
        return(page)
      })
    })
    }
  }
  return(responses)
}

obj <- get_obs_2()
obj <- do.call("rbind", obj[[1]])
names(obj)
traceback()
debug(get_obs_2)

test <-lapply(resp$body, function(page){
  campaign_ids <- unique(page$campaign_id)
  print(campaign_ids)})

responses <- list()
class(responses) <- "coleoGetResp"
responses[[1]] <- get_gen("/observations")
responses[[1]] <- lapply(responses[[1]]$body, function(page) {
  campaign_ids <- unique(page$campaign_id)
  print(campaign_ids)})
