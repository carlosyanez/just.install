#' simply install packages
#'
#' Simple utility to install packages from a number of sources. It only install if it not present already.
#' It does not attach any packages, existing or to be installed.
#'
#' @return no output
#' @importFrom dplyr mutate case_when
#' @importFrom magrittr %>%
#' @import remotes
#' @importFrom utils  installed.packages
#' @importFrom stringr str_c
#' @param to_install tibble or data.frame with packages to install (see vignette for details)
#' @examples
#' \dontrun{
#' to_install <- tibble::tibble(package=c("tidyverse","ochRe","customthemes"),
#'                              source=c("CRAN","Github","r-universe"),
#'                              url=c("","ropenscilabs/ochRe","https://carlosyanez.r-universe.dev"))
#'
#' just.install::justinstall(to_install)
#' }
#' @export justinstall
justinstall <- function(to_install){

  #to comply with rmd checks
  source_type <- NULL

  # get list of installed packages
  installed_packages  <- utils::installed.packages()[,1]

  #determined which packages have been installed, which ones to install
  there     <- to_install[to_install$package %in% installed_packages,]
  missing   <- to_install[!(to_install$package %in% installed_packages),]

  #main installation logic
  if(nrow(there)==0){
    message("None installed")
  }
  else{
    # list all packages already installed
    for(i in 1:nrow(there)){
      message(there[i,]$package," already installed")
    }
    if(nrow(missing)==0){
      message(("Nothing to install"))
    }
    else{

      #standardise source names
      # fill bioconductor if source_type is empty
      missing <- missing %>%
                 dplyr::mutate(source_type=tolower(source_type),
                        source_type=dplyr::case_when(
                                      source_type=="gh"           ~ 'github',
                                      source_type=="universe"     ~ 'r-universe',
                                      source_type=="bioconductor" ~ 'bioc',
                                      TRUE ~ source_type
                                      )
                        ) %>%
                  dplyr::mutate(
                        source_param = dplyr::case_when(
                                      source_type=="bioc" & source_param=="" ~ source_type,
                                      TRUE ~ source_param
                                      )
                        )


      # installing new packages
      for(i in 1:nrow(missing)){
        install_package(missing[i,]$package,missing[i,]$source,missing[i,]$url)
      }
      message("Task complete Goodbye!")
    }
  }

}


#' internal function to that installs a single package based on data provided
#' @return no output
#' @param  package_name package name
#' @param  source_type  where it should be installed from
#' @param  source_param repository source, where it applies
#' @import remotes
#' @importFrom stringr str_c
install_package <- function(package_name,source_type,source_param){

  ### use {remotes} function based on source type

  message(stringr::str_c("Installing ", package_name, " from", source_type))

  switch(source_type,
         "bioc"       = {remotes::install_bioc(package_name)},
         "bitbucket"  = {remotes::install_bitbucket(source_param)},
         "cran"       = {remotes::install_cran(package_name)},
         "dev"        = {remotes::install_dev(package_name)},
         "git"        = {remotes::install_git(source_param)},
         "github"     = {remotes::install_github(source_param)},
         "gitlab"     = {remotes::install_gitlab(source_param)},
         "local"      = {remotes::install_local(source_param)},
         "svn"        = {remotes::install_svn(source_param)},
         "url"        = {remotes::install_url(source_param)},
         "r-universe" = {remotes::install_cran(package_name,repos=c(source_param))}

  )


  message(stringr::str_c(package_name, " installed"))


}




