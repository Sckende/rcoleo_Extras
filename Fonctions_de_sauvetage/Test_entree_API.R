test_endpoint <- function(api_acces){
  j <- get_gen(endpoint = api_acces)
  print(j)
  print(names(get_gen(endpoint = api_acces)$body[[1]]))
}

