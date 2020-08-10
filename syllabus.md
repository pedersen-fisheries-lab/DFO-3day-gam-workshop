---
title: Course syllabus
---

# Overview

We have 6 sessions, propose we have an "accelerate" type format where the intro stuff we take longer to cover and then give more of a tour of the complex bits, pointing participants to external info/have a q&a/allow them to dictate topics by poll before the last day.

# Learning Goals

-   Understand the basic GAM model, basis functions, and penalties
-   Fit 1D, 2D, and tensor-product GAMs to normal and nonnormal data
-   Plot GAM fits, and understand how to explain GAM outputs
-   Diagnose common mispecification problems when fitting GAMs
-   Practice using GAMs for more complicated models

# Syllabus

(The last 3 sections are probably uneven and might need to be adjusted, but also we can have an extended Q&A in that last session which might be helpful.)

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

-   adding more than one smooth to yr model

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

## 5. more complex models

\*\* Lead instructor: Eric \*\*

-   other smoothers (each needs an example)

    -   random effects
    -   cyclic smoothers
    -   soap
    -   MRFs
    -   factor-smooths

-   other responses:

    -   `ocat`/gev/`mvn`/etc

## 6. Connections, Q&A

\*\* Lead instructor: David, all \*\*

-   GAMs in context with other methods

    -   INLA/hierarchical modelling/`lme4`/etc.
    -   Connection to covariance matrices in regression for dependent data
    -   Bayesian views of GAMs

-   links to other software

    -   utility: `mgcvUtils`
    -   fitting: `jagam`/`brms`/TMB

-   Q&A

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
