#' install packages, only if there are missing and without attaching them
#' @return no output
#' @import tibble
#' @importFrom BiocManager install
#' @importFrom  remotes install_github
#' @importFrom utils  install.packages installed.packages
#' @param to_install tibble or data.frame with packages to install (attr: package: package name, source: {"CRAN","Github","Bioconductor","Other"}, url: username/package for Github, repo url for Other)
#' @export justinstall
justinstall <- function(to_install){

  installed_packages  <- rownames(installed.packages())

  there <- to_install[to_install$package %in% installed_packages,]
  missing   <- to_install[!(to_install$package %in% installed_packages),]

# these packages are already installed
  for(i in 1:nrow(there)){
    message(there[i,]$package," already installed")
  }

# installing new packages
  for(i in 1:nrow(missing)){
      if(missing[i,]$source %in% c("CRAN")){
        install.packages(missing[i,]$package,repos="https://cloud.r-project.org/")  # classic installation from CRAN
      }else{
        if(missing[i,]$source %in% c("Bioc","Bioconductor","BioConductor")){
          BiocManager::install(missing[i,]$package)                                # Bioconductor
        }else{
          if(missing[i,]$source %in% c("Github","GitHub","github","gh")){
            remotes::install_github(missing[i,]$url)                               #Github repository
            }else{
              install.packages(missing[i,]$package,repos=missing[i,]$url)          # mini-cran, r-universe style repo
            }
          }

        }
      }


# goodbye

message("Task done")

}


