#' simply install packages
#'
#' Simple utility to install packages from a number of sources. It only install if it not present already.
#' It does not attach any packages, existing or to be installed.
#'
#' @return no output
#' @importFrom dplyr mutate case_when
#' @import remotes
#' @importFrom utils  installed.packages
#' @param to_install tibble or data.frame with packages to install (see vignette for details)
#' @param cran_repos list of CRAN repositories (defauls to getOptions("repos"))
#' @param dependencies whether to install dependencies, as per remotes::install_ specs (defaults to TRUE)
#' @examples
#' \dontrun{
#' to_install <- tibble::tibble(package=c("tidyverse","ochRe","customthemes"),
#'                              source=c("CRAN","Github","r-universe"),
#'                              url=c("","ropenscilabs/ochRe","https://carlosyanez.r-universe.dev"))
#'
#' just.install::justinstall(to_install)
#' }
#' @export justinstall
justinstall <- function(to_install,cran_repos=getOption("repos"),dependencies=TRUE){

  # get list of installed packages
  installed_packages  <- utils::installed.packages()[,1]

  #determined which packages have been installed, which ones to install
  there     <- to_install[to_install$package %in% installed_packages,]
  missing   <- to_install[!(to_install$package %in% installed_packages),]


  #main installation logic
  if(nrow(missing)==0){
    message("Nothing to install")
  }
  else{
    # list all packages already installed
    for(i in 1:nrow(there)){
      message(there[i,]$package," already installed")
    }
      #standardise source names
      # fill bioconductor if source_type is empty

      missing$source <- tolower(missing$source)

      missing <- missing |>
                 dplyr::mutate(source=dplyr::case_when(
                                      source=="gh"           ~ 'github',
                                      source=="universe"     ~ 'r-universe',
                                      source=="bioconductor" ~ 'bioc',
                                      TRUE ~ source
                                      )
                        ) |>
                  dplyr::mutate(url=dplyr::case_when(
                                      source=="bioc" & url=="" ~ source,
                                      TRUE ~ url
                                      )
                        )


      # installing new packages
      for(i in 1:nrow(missing)){
        install_package(missing[i,]$package,missing[i,]$source,missing[i,]$url,cran_repos,dependencies)
      }
      message("Task complete Goodbye!")

  }

}


#' internal function to that installs a single package based on data provided
#' @return no output
#' @param  package_name package name
#' @param  source_type  where it should be installed from
#' @param  source_param repository source, where it applies
#' @import remotes
#' @keywords internal
#' @NoRd
install_package <- function(package_name,source_type,source_param,cran_repos,depends){

  ### use {remotes} function based on source type

  message(paste0("Installing ", package_name, " from ", source_type,sep=""))
  message(cran_repos)

  switch(source_type,
         "bioc"       = {remotes::install_bioc(package_name,repos=c(cran_repos),dependencies=depends)},
         "bitbucket"  = {remotes::install_bitbucket(source_param,repos=c(cran_repos),dependencies=depends)},
         "cran"       = {remotes::install_cran(package_name,repos=c(cran_repos),dependencies=depends)},
         "dev"        = {remotes::install_dev(package_name,repos=c(cran_repos),dependencies=depends)},
         "git"        = {remotes::install_git(source_param,repos=c(cran_repos),dependencies=depends)},
         "github"     = {remotes::install_github(source_param,repos=c(cran_repos),dependencies=depends)},
         "gitlab"     = {remotes::install_gitlab(source_param,repos=c(cran_repos),dependencies=depends)},
         "local"      = {remotes::install_local(source_param,repos=c(cran_repos),dependencies=depends)},
         "svn"        = {remotes::install_svn(source_param,repos=c(cran_repos),dependencies=depends)},
         "url"        = {remotes::install_url(source_param,repos=c(cran_repos),dependencies=depends)},
         "r-universe" = {remotes::install_cran(package_name,repos=c(source_param,cran_repos),dependencies=depends)}

  )


  message(paste0(package_name, " installed",sep=""))

}




