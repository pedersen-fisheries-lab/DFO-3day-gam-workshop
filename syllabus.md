---
title: Course syllabus

---

# General idea

We have 6 sessions, propose we have an "accelerate" type format where the intro stuff we take longer to cover and then give more of a tour of the complex bits, pointing participants to external info/have a q&a/allow them to dictate topics by poll before the last day.

# Rough syllabus

(The last 3 sections are probably uneven and might need to be adjusted, but also we can have an extended Q&A in that last session which might be helpful.)

1. 1d (temperature anomaly/campylobacterosis)
  - why smooth?
  - simple models with `s()`
  - what's going on behind the scenes here?
    - interpolation vs. linear models
    - wiggles/penalties (non-technical)
  - adding more than one smooth to yr model
  - `summary` and `plot`
2. "twiddling knobs in `gam`"
  - moving beyond normal data (campylobacter?)
    - exponential family and conditionally exp family (i.e., `family` + `tw` + `nb`)
  - more dimensions (something spatial)
    - thin-plate 2d
    - what are tensors?
      - `ti` vs `te`
    - spatio-temporal modelling
      - `te(x,y,t)` constructions
3. model checking and selection (follow-up on one or more of the previous data sets, spatial/spatiotemporal seem promising)
  - `gam.check` is yr pal
    - 4 plots
    - checking `k`
    - limitations with count data
  - fitting to the residuals
  - `AIC` etc
  - shrinkage and `select=TRUE`
4. predictions and variance
  - `predict` (`exclude=`?)
  - what are those bands
  - getting summaries (abundance estimates?)
  - posterior simulation
5. more complex models
  - other smoothers (each needs an example)
    - random effects
    - cyclic smoothers
    - soap
    - MRFs
    - factor-smooths
  - other responses:
    - `ocat`/gev/`mvn`/etc
6. connections
  - GAMs in context with other methods
    - INLA/hierarchical modelling/`lme4`/etc
  - links to other software
    - Visualisation: `gratia`/`mgcViz`
    - diagnostic: `DHARMa`
    - utility: `mgcvUtils`
    - fitting: `jagam`/TMB

# Other things we've collectively taught

(Where we might look for example data, materials to reuse.)

- All:
  - [Original ESA workshop](https://eric-pedersen.github.io/mgcv-esa-workshop/)
- Dave:
  - [NOAA workshop](https://converged.yt/mgcv-workshop/) based on ESA
  - [Distance DSM workshop](http://workshops.distancesampling.org/online-dsm-2020/)

