########
## Operating System
########

### OS version 
FROM ubuntu:xenial 
MAINTAINER Kelly Street, street.kelly@gmail.com

######################
## Environment
######################

## Constants
ENV R_VERSION 3.5.1-1xenial

### locations
ENV BIN /usr/local/bin
ENV R_DATA /usr/local/R/data
ENV R_STUDIO /usr/local/R
ENV SRC /usr/local/src

######################
## Dependencies and Tools
######################
##############
## Helper tools
RUN apt-get clean && apt-get update && \
    apt-get install -y unzip wget git

##############
## System tools
RUN apt-get install -y libssl-dev libcurl4-openssl-dev libgsl-dev\ 
    libxml2-dev libxt-dev libglu1-mesa-dev libfreetype6-dev

##############
## Install R
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial-cran35/" | tee -a /etc/apt/sources.list && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | apt-key add - && \
    apt-get update && \ 
    apt-get install -y r-recommended=${R_VERSION} && \
    apt-get install -y r-base=${R_VERSION}
RUN Rscript -e 'install.packages("BiocManager", repos = "http://cran.us.r-project.org")'

##############
## BiocManager for installing bioconductor packages
RUN echo "BiocManager::install(c(\"devtools\", \"remotes\", \"clusterExperiment\", \"drisso/fletcher2017data\", \"optparse\", \"logging\"), dependencies=TRUE)" > ${SRC}/install_pkgs.R  && \
    echo "BiocManager::install(\"slingshot\", INSTALL_opts = c(\"--install-tests\"))" >> ${SRC}/install_pkgs.R && \
    echo "BiocManager::install(\"BiocGenerics\", \"DelayedArray\", \"DelayedMatrixStats\", \"limma\", \"S4Vectors\", \"SingleCellExperiment\", \"SummarizedExperiment\"))" >> ${SRC}/install_pkgs.R && \
    Rscript ${SRC}/install_pkgs.R
    
## Install more monocle3 specific packages
RUN Rscript -e 'install.packages("reticulate")'
    Rscript -e 'reticulate::py_install("louvain")'
    Rscript -e 'devtools::install_github('cole-trapnell-lab/monocle3')'

##############
## Install wrapper script
CMD ["/bin/mkdir", "/software/scripts"]
ADD https://github.com/kstreet13/slingshot-docker/raw/master/run_slingshot.R /software/scripts/run_slingshot.R
