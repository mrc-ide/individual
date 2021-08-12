# Individual <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->
[![R build status](https://github.com/mrc-ide/individual/workflows/R-CMD-check/badge.svg)](https://github.com/mrc-ide/individual/actions)
[![codecov.io](https://codecov.io/github/mrc-ide/individual/coverage.svg)](https://codecov.io/github/mrc-ide/individual)
[![CRAN](https://www.r-pkg.org/badges/version/individual)](https://cran.r-project.org/package=individual)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

An R package for specifying and simulating individual based models.

This package is designed to:

  1. encourage clear and testable components for defining your individual based 
models, and
  2. provide memory efficient, fast code for executing your model

## Installation

The package can be installed from github using the "remotes" library

```R
library('remotes')
install_github('mrc-ide/individual')
```

Alternatively you can install individual directly from CRAN, but be aware that
the CRAN version may not be the most recent version of the package:

```R
install.packages("individual")
```

For development it is most convenient to run the code from source. You can
install the dependencies in RStudio by opening the project and selecting "Build" > "Install and Restart"

Command line users can execute:

```R
library('remotes')
install_deps('.', dependencies = TRUE)
```

Docker users can build a minimal image with

```bash
docker build . -f docker/Dockerfile -t [your image name]
```

Or if you would like devtools and documentation tools you can run

```bash
docker build . -f docker/Dockerfile.dev -t [your image name]
```

## Usage

We recommend first reading `vignette("Tutorial")` which describes
how to simulate a simple SIR model in "individual", and later `vignette("API")`
which describes in detail how to use the data structures in "individual" to
build more complicated models. If you are running into performance issues,
learn more about how to speed up your model in `vignette("Performance")`.

## Statement of need

Individual based models are important tools for infectious disease epidemiology,
but practical use requires an implementation that is both comprehensible so that
code may be maintained and adapted, and fast. "individual" is an R package which
provides users a set of primitive classes using the [R6](https://github.com/r-lib/R6)
class system that define elements common to many tasks in infectious disease
modeling. Using R6 classes helps ensure that methods invoked on objects are
appropriate for that object type, aiding in testing and maintenance of models
programmed using "individual". Computation is carried out in C++ using 
[Rcpp](https://github.com/RcppCore/Rcpp) to link to R, helping achieve good
performance for even complex models.

"individual" provides a unique method to specify individual based models compared
to other agent/individual based modeling libraries, where users specify a type
for agents, which are subsequently stored in an array or other data structure.
In "individual", users instead instantiate a object for each variable which
describes some aspect of state, using the appropriate R6 class. Finding subsets
of individuals with particular combinations of state variables for further
computation can be efficiently accomplished with set operations, using a custom
bitset class implemented in C++. Additionally, the software makes no assumptions
on the types of models that may be simulated (*e.g.* mass action, network),
and updates are performed on a discrete time step.

We hope our software is useful to infectious disease modellers, ecologists, and
others who are interested in individual-based modeling in R.

## Contributing

Thank you! Please refer to the vignette on `vignette("Contributing")` for info on how to
contribute :)

## Alternatives

### Non R Software

 - Repast
 - Mesa
 - NetLogo
 - Agents.jl

### Non R Software for Epi

 - EpiFire
 - SimpactCyan
 - Numerus Model Builder
 - NOVA
 - EMOD
 - Pathogen.jl, a package for individual based simulation of common compartmental models.

### General R Packages

 - nlrx, RNetLogo, NetLogoR are NetLogo interfaces
 - RRepast is a repast interface
 - simecol, provides classes and methods to enhance reproducibility of ecological models.

### R based DES

 - simmeR
 - SpaDES

### R based IBMs

 - IBMPopSim
 - ibm
 - ibmcraftr

### R based Epi

 - EpiModel 
 - SimInf
 - hybridModels
 - epinet
 - EpiDynamics
 - nosoi, generate synthetic data for phylogenetic analysis
 - EpiILMCT
 - EpiILM
 - SPARSEMODr
