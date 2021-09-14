#' install packages, only if there are missing and without attaching them
#' @return no output
#' @import tibble
#' @import dplyr
#' @import magrittr
#' @import tools
#' @importFrom BiocManager install
#' @importFrom  remotes install_github
#' @importFrom utils  install.packages installed.packages
#' @param to_install tibble or data.frame with packages to install (attr: package: package name, source: {"CRAN","Github","Bioconductor","Other"}, url: username/package for Github, repo url for Other)
#' @param cran_repo_option CRAN repository to use (defaults to https://cloud.r-project.org/)
# @param dependencies_option whether to install dependencies
#' @export justinstall
justinstall <- function(to_install,
                        cran_repo_option="https://cloud.r-project.org/"){ #,
#                        dependencies_option="Depends"){

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
      dplyr::mutate(url=dplyr::if_else(url=="",cran_repo_option,url)) %>%
      dplyr::filter(source %in% crans) %>%
      dplyr::select(url) %>%
      dplyr::distinct() %>%
      dplyr::pull(url)

    options(repos = cran_repos)


    for(i in 1:nrow(missing)){
      if(missing[i,]$source %in% crans){
        install.packages(missing[i,]$package,
                       #  dependencies=dependencies_option,
                         repos = cran_repo_option)  # classic installation from CRAN
      }else{
        if(missing[i,]$source %in% c("Bioc","Bioconductor","BioConductor")){
          BiocManager::install(missing[i,]$package) #,
                            #   dependencies = dependencies_option)                                # Bioconductor
        }else{
          if(missing[i,]$source %in% c("Github","GitHub","github","gh")){
            remotes::install_github(missing[i,]$url) #
                         # ,dependencies = dependencies_option)                               #Github repository

          }else{
            if(missing[i,]$source %in% c("mini-cran","r-universe")){
              message("installing ",missing[i,]$package)
              install.packages(missing[i,]$package,repos=missing[i,]$url)#,dependencies = dependencies_option)          # mini-cran, r-universe style repo

              }else{message("I don't know how to install ",missing[i,]$package)}

          }
        }

      }
    }
  }

  #dep_check <- dplyr::if_else(dependencies_option==TRUE,"all",dependencies_option)

  #check that all dependencies have been installed
  #dependencies <- unlist(tools::package_dependencies(to_install$package,which=dep_check))
  #missing_deps <- dependencies[!(dependencies %in% installed_packages)]
  #if(length(missing_deps)==0){
  #  message("no missing dependencies")
  #}else{
  #    message(paste("installing dependencies:", missing_deps))
  #    install.packages(missing_deps,dependencies=dependencies_option,repos = cran_repo_option)
  #    message("dependencies installed")
  #}

  # goodbye

  message("Task done. Goodbye!")

}





