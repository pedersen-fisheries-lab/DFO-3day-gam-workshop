FROM rocker/binder:4.0.2
MAINTAINER ross@ecohealthalliance.org


## Copies your repo files into the Docker Container
USER root
COPY . /home/${NB_USER}/DFO-3day-gam-workshop
RUN chown -R ${NB_USER} /home/${NB_USER}
COPY code/Rprofile /home/rstudio/.Rprofile
RUN chown ${NB_USER} /home/rstudio/.Rprofile
RUN install2.r renv
RUN Rscript -e 'remotes::install_cran(unique(renv::dependencies(progress = FALSE)[, "Package"]))'

## Become normal user again

USER ${NB_USER}
WORKDIR /home/${NB_USER}/DFO-3day-gam-workshop



