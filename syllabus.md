---
title: Course syllabus
---

# Overview

This is a 6-session workshop, developed with the goal of giving you enough GAM knowledge to feel comfortable fitting and working with GAMs in your day-to-day modelling practice. We will be covering a basic intro to GAM theory, with the rest focused on practical applications and a few advanced topics that we think might be interesting.

# Learning Goals

-   Understand the basic GAM model, basis functions, and penalties
-   Fit 1D, 2D, and tensor-product GAMs to normal and non-normal data
-   Plot GAM fits, and understand how to explain GAM outputs
-   Diagnose common mispecification problems when fitting GAMs
-   Use GAMs to make predictions about new data, and assess model uncertainty
-   See how more complicated GAM models can be used as part of a modern workflow

# Syllabus

## 1. What is a GAM, and 1d smoothers

**Lead instructors: Eric**

-   *Example data: temperature with depth*

-   refresher on GLMs (regression, parameters, link functions)

-   why smooth?

-   simple models with `s()`

-   introduction to the data

-   what's going on behind the scenes here?

    -   interpolation vs. linear models
    -   wiggles/penalties (non-technical)

-   adding more than one smooth to your model

-   `summary` and `plot`

## 2. "twiddling knobs in `gam`"

**Lead instructors: David**

-   moving beyond normal data (richness, shrimp biomass)

    -   exponential family and conditionally exp family (i.e., `family` + `tw` + `nb`)

-   more dimensions (Shrimp biomass)

    -   thin-plate 2d (Shrimp biomass with space)

    -   what are tensors? (Shrimp biomass as a function of depth and temperature)

        -   `ti` vs `te`

    -   spatio-temporal modelling

        -   `te(x,y,t)` constructions

-   centering constraints

    -   what does the intercept mean?

## 3. model checking and selection (follow-up on temperature, richness, and shrimp data sets)

**Lead instructors: Noam**

-   `gam.check` is yr pal

    -   4 plots
    -   checking `k`
    -   limitations with count data

-   quantile residuals

-   diagnostic: `DHARMa`

-   fitting to the residuals

-   `AIC` etc.

-   shrinkage and `select=TRUE`

## 4. predictions and variance

**Lead instructor: Gavin**

-   `predict` (`exclude=`?)
-   what are those bands
-   getting summaries (abundance estimates?)
-   posterior simulation


## 5. Connections, Q&A

**Lead instructor: David, all **

-   GAMs in context with other methods

    -   INLA/hierarchical modelling/`lme4`/etc.
    -   Connection to covariance matrices in regression for dependent data
    -   Bayesian views of GAMs

-   links to other software

    -   utility: `mgcvUtils`
    -   fitting: `jagam`/`brms`/TMB

-   Q&A



## 6. more complex models for fisheries and aquatic ecology

**Lead instructor: Eric **

-   other smoothers

    -   random effects
    -   cyclic smoothers
    -   Gaussian Markov Random Fields
    -   factor-smooths
    -   geographically weighted regression

-   other responses:

    -   `twlss`/`betar`

# Other things we've collectively taught

(Where we might look for example data, materials to reuse.)

-   All:

    -   [Original ESA workshop](https://eric-pedersen.github.io/mgcv-esa-workshop/)
    -   [Our paper on Hierarchical Generalized Additive Models](https://peerj.com/articles/6876/)


-   Dave:

    -   [NOAA workshop](https://converged.yt/mgcv-workshop/) based on ESA
    -   [Distance DSM workshop](http://workshops.distancesampling.org/online-dsm-2020/)

-   Noam:

    -   [GAMs in R tutorial](https://noamross.github.io/gams-in-r-course/)
    -   [Short talk on many types of models that can fit with mgcv](https://raw.githubusercontent.com/noamross/gam-resources/master/2017-11-14-noamross-gams-nyhackr.pdf)

-   Gavin:

    -   [Blog: From the Bottom of the Heap](https://fromthebottomoftheheap.net/)
    -   [Online GAM workshop](https://www.youtube.com/watch?v=sgw4cu8hrZM&feature=youtu.be)


# Other useful GAM resources:

 - Simon Wood's book "Generalized Additive Models: An Introduction with R, Second Edition", is an incredibly useful tool for learning about GAMs, and covers all of this material in depth.
 
- Hefley et al. (2017). "The basis function approach for modeling autocorrelation in ecological data". This is a great paper laying out how basis functions are used to model complex spatially structured systems. 


- The `mgcVis` package has more tools for plotting GAM model outputs. See Fasiolo et al.'s paper 2019 "Scalable visualization methods for modern generalized additive models". 
