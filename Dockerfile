FROM rocker/binder:4.0.2
MAINTAINER ross@ecohealthalliance.org

## Copies your repo files into the Docker Container
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
RUN install2.r renv

## Become normal user again
USER ${NB_USER}

RUN R --quiet -e "renv::install(unique(renv::dependencies()$Package), library = .libPaths()[1])"
