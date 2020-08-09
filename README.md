# DFO-3day-gam-workshop

A short course on how to fit, plot, and evaluate GAMs

## Setup

-   You will need to install **R** and we recommend using **RStudio**. The latest version of R can be downloaded [here](https://cran.r-project.org/mirrors.html). RStudio is an application (an integrated development environment or IDE) that facilitates the use of R and offers a number of nice additional features. It can be downloaded [here](https://www.rstudio.com/products/rstudio/download/). You will need the free Desktop version for your computer.

-   Download the course materials as a ZIP file [here](https://github.com/pedersen-fisheries-lab/DFO-3day-gam-workshop/archive/master.zip). Alternatively, if you have the [**usethis**](), R package, running the following command will download the course materials and open them:

    ``` {.r}
    usethis::use_course('pedersen-fisheries-lab/DFO-3day-gam-workshop')
    ```

-   Install the R packages required for this course by running the following line of code your R console:

    ``` {.r}
    install.packages(c("dplyr", "rnaturalearth", "sf", "lwgeom", "dsm", "ggplot2", "gratia", "mgcv", "tidyr"))
    ```

### Online environment

-   You can also use a free online environment rather than installing R on your machine. Click here to launch an online RStudio environment with the course materials and packages already installed: [![Launch binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/pedersen-fisheries-lab/DFO-3day-gam-workshop/master?urlpath=rstudio)

    (Note that this will be a temporary environment run on the free [Binder]() service. Download and save any materials you create, as your session will not be saved after quitting.)
