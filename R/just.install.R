#' install packages, only if there are missing and without attaching them
#' @return no output
#' @import tibble
#' @import dplyr
#' @import  magrittr
#' @import  tools
#' @importFrom BiocManager install
#' @importFrom  remotes install_github
#' @importFrom utils  install.packages installed.packages
#' @param to_install tibble or data.frame with packages to install (attr: package: package name, source: {"CRAN","Github","Bioconductor","Other"}, url: username/package for Github, repo url for Other)
#' @param cran_repo CRAN repository to use (defaults to https://cloud.r-project.org/)
#' @export justinstall
justinstall <- function(to_install, cran_repo_option="https://cloud.r-project.org/"){

  installed_packages  <- rownames(installed.packages())

  there <- to_install[to_install$package %in% installed_packages,]
  missing   <- to_install[!(to_install$package %in% installed_packages),]

  # these packages are already installed
  for(i in 1:nrow(there)){
    message(there[i,]$package," already installed")
  }



  # installing new packages
  if(nrow(missing)>0){

    # collect CRAN and CRAN-like repositories

    crans <-  c("CRAN","miniCRAN","r-universe")

    cran_repos <- missing %>%
      mutate(url=if_else(url=="",cran_repo_option,url)) %>%
      filter(source %in% crans) %>%
      select(url) %>%
      distinct() %>%
      pull(url)

    options(repos = cran_repos)


    for(i in 1:nrow(missing)){
      if(missing[i,]$source %in% crans){
        install.packages(missing[i,]$package,
                         dependencies=TRUE,
                         repos = cran_repo_option)  # classic installation from CRAN
      }else{
        if(missing[i,]$source %in% c("Bioc","Bioconductor","BioConductor")){
          BiocManager::install(missing[i,]$package,dependencies = TRUE)                                # Bioconductor
        }else{
          if(missing[i,]$source %in% c("Github","GitHub","github","gh")){
            remotes::install_github(missing[i,]$url,dependencies = TRUE)                               #Github repository

          }else{
            if(missing[i,]$source %in% c("mini-cran","r-universe")){
              message("installing ",missing[i,]$package)
              install.packages(missing[i,]$package,repos=missing[i,]$url,dependencies = TRUE)          # mini-cran, r-universe style repo

              }else{message("I don't know how to install ",missing[i,]$package)}

          }
        }

      }
    }
  }

  #check that all dependencies have been installed
  dependencies <- unlist(tools::package_dependencies(to_install$package))
  missing_deps <- dependencies[!(dependencies %in% installed_packages)]
  if(length(missing_deps)==0){
    message("no missing dependencies")
  }else{
      message(str_c("installing dependencies:", missing_deps))
      install.packages(missing_deps,dependencies=TRUE,repos = cran_repo_option)
      message("dependencies installed")
  }

  # goodbye

  message("Task done. Goodbye!")

}


