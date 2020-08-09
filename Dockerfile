FROM rocker/binder:4.0.2
MAINTAINER ross@ecohealthalliance.org

ENV NB_USER=jovyan

## Copies your repo files into the Docker Container
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
RUN install2.r renv
RUN Rscript -e 'install.packages(unique(renv::dependencies(progress = FALSE)[, "Package"]), repoc = c(CRAN="https://packagemanager.rstudio.com/all/__linux__/focal/latest"))'

## Become normal user again
USER ${NB_USER}
WORKDIR /home/${NB_USER}


CMD jupyter notebook --ip 0.0.0.0


