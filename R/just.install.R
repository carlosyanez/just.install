#' simply install packages
#'
#' Simple utility to install packages from a number of sources. It only install if it not present already.
#' It does not attach any packages, existing or to be installed.
#'
#' @return no output
#' @import tibble
#' @import dplyr
#' @import magrittr
#' @import tools
#' @importFrom BiocManager install
#' @importFrom  remotes install_github
#' @importFrom utils  install.packages installed.packages
#' @param to_install tibble or data.frame with packages to install (attr: package: package name, source: {"CRAN","Github","Bioconductor","Other"}, url: username/package for Github, repo url for Other)
#' @param cran_repo_option CRAN repository. Defaults to system options
#' @examples
#' \dontrun{
#' to_install <- tibble::tibble(package=c("tidyverse","ochRe","customthemes"),
#'                              source=c("CRAN","Github","r-universe"),
#'                              url=c("","ropenscilabs/ochRe","https://carlosyanez.r-universe.dev"))
#'
#' just.install::justinstall(to_install)
#' }
#' @export justinstall
justinstall <- function(to_install,
                        cran_repo_option=getOption('repos')){

  installed_packages  <- rownames(installed.packages())

  there <- to_install[to_install$package %in% installed_packages,]
  missing   <- to_install[!(to_install$package %in% installed_packages),]

  # these packages are already installed
  if(nrow(there)==0){
    message("None installed")
  }
  else{
  for(i in 1:nrow(there)){
    message(there[i,]$package," already installed")
  }
  }

  # installing new packages
  if(nrow(missing)>0){


    for(i in 1:nrow(missing)){
      if(missing[i,]$source=='CRAN'){
        message('Installing ',missing[i,]$package,' from default repos')
        install.packages(missing[i,]$package,
                       #  dependencies=dependencies_option,
                         repos = cran_repo_option)  # classic installation from CRAN
      }else{
        if(missing[i,]$source %in% c("Bioc","Bioconductor","BioConductor")){
          message('Installing ',missing[i,]$package,' from BioConductor')
          BiocManager::install(missing[i,]$package) #,
                            #   dependencies = dependencies_option)                                # Bioconductor
        }else{
          if(missing[i,]$source %in% c("Github","GitHub","github","gh")){
            message('Installing ',missing[i,]$package,' from Github')
            remotes::install_github(missing[i,]$url) #
                         # ,dependencies = dependencies_option)                               #Github repository

          }else{
            if(missing[i,]$source %in% c("mini-cran","r-universe")){
              message("installing ",missing[i,]$package," from ",missing[i,]$url)
              install.packages(missing[i,]$package,repos=c(missing[i,]$url))#,dependencies = dependencies_option)          # mini-cran, r-universe style repo

              }else{message("I don't know how to install ",missing[i,]$package)}

          }
        }

      }
    }
    message("Task done. Goodbye!")
  }



}





