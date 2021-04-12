---
title: 'individual: An R package for individual based epidemiological models'
tags:
  - R
  - epidemiology
  - individual based
  - agent based
  - infectious disease
  - simulation
  - stochastic
authors:
  - name: Giovanni D. Charles^[Custom footnotes for e.g. denoting who the corresponding author is can be included like this.]
    orcid: 0000-0003-0872-7098
    affiliation: 1
  - name: Sean L. Wu
    orcid: 0000-0002-5781-9493
    affiliation: 2
affiliations:
 - name:  MRC Centre for Global Infectious Disease Analysis, Abdul Latif Jameel Institute for Disease and Emergency Analytics (J-IDEA), Imperial College London, London, UK.
   index: 1
 - name: Division of Epidemiology and Biostatistics, School of Public Health, University of California, Berkeley, CA 94720, USA
   index: 2
date: 13 August 2017
bibliography: paper.bib
---

# Summary

Complex stochastic models are a crucial tool for many tasks 
in public health, and especially in infectious disease epidemiology [@Ganyani:2021]. 
Such models can help formalize theory, generate synthetic data, evaluate counterfactual 
scenarios, forecast trends, and be used for statistical inference. Individual-based
models (IBMs) in particular are useful because of the relative ease with which individual
level characteristics can be specified. Such characteristics may include age, 
genetics, demographics, and personal behaviors which contribute to health outcomes 
arising due to interactions with others [@Tracy:2018]. The specification of 
such a population's characteristics, and the processes (such as disease transmission)
which are a result of contact between individuals, may be cumbersome or practically
impossible to represent in an "aggregated" manner such as compartmental mathematical
models. Even if a compartmental representation were available, there are many 
reasons why an individual-based representation is to be preferred. Synthetic data
may need to include a individual level outcome data, which aggregated models by their very 
nature are unable to provide. Other complexities, such as when events occur after
a random delay whose distribution differs from a Geometric (or Exponential)
one, mean even aggregated models will need to store individual completion times,
necessitating more complex simulation algorithms and data structures; in such
cases it is often more straightforward to adopt an individual-based representation
from the start.

`individual` is an R package which provides a set of useful primitive elements
for specifying and simulating IBMs, with special attention to the types of models
encountered in infectious disease epidemiology, although the software is generic.
Users specify variables, one for each characteristic of an individual in the
simulated population. The package provides efficient methods for finding
subsets of individuals based on these variables, or cohorts. Cohorts can then
be targeted for variable updates or future events. Models developed in `individual`
are updated on a discrete time step, and individuals can interact in a completely
general manner. While `individual` can represent almost any kind of IBM, it is
designed to be used for the types of models encountered in epidemiology, 
where interactions between individuals are structured by discrete variables, such as
position on a network, and more efficient alternatives may exist for continuous
space models or cellular automata.

# Statement of need

In many applications, but especially epidemiology, individual-based models often
need to balance comprehensibility and speed. A fast model whose code is only
understood by the author can be difficult to use as a basis for scientific
exploration, which necessitates the development of various similar models to
test different hypotheses or explore sensitivity to certain assumptions. On the
other hand a clear yet slow model can be practically unusable for tasks such as
uncertainty quantification or statistical inference on model parameters. `individual`
provides a toolkit for epidemiologists to write models which is general enough
to cover nearly all models of practical interest using simple, standardized code which is
fast enough to be useful for computation heavy applications.

- say something about how writing models in "individual" looks a lot like how one
conceptually thinks about models as defining state and processes/rules which update state?

The `individual` package is written in the R language, which is a *lingua franca*
in epidemiological applications. The package uses `Rcpp` [@Rcpp] to link to
the C++ source code, which underlies the data structures exposed to the user. 
The API for `individual` uses a `R6` [@R6] class-based design at the R level
which users call to create, update, and query variables.

Because in many epidemiological models the most important individual level
characteristic can be represented as belonging to mutually exclusive 
types in a finite set (such as susceptible or infectious), the software
uses a fast bitset object at the C++ level to represent each individual's value.
Bitwise operations at the R level implementing the various set operations 
including union, intersection, set difference, symmetric difference and complement 
allow users to write highly efficient R code for updating their model.

`individual` also provides a C++ header-only interface which advanced users
can link to from their R package. The C++ interface allows a user to interact
with the C++ types directly, if the R interface remains too slow for their use case.

# State of the field

TODO

List of R packages to follow up on when comparing to existing software.
  - [https://cran.r-project.org/web/packages/hybridModels/index.html](https://cran.r-project.org/web/packages/hybridModels/index.html)
  - [https://siminf.org/](https://siminf.org/)
  - SpaDES [https://spades.predictiveecology.org/](https://spades.predictiveecology.org/)
  - simmeR [https://r-simmer.org/](https://r-simmer.org/)
  - IBM for animal breeding [https://academic.oup.com/g3journal/article/11/2/jkaa017/6025179](https://academic.oup.com/g3journal/article/11/2/jkaa017/6025179)
  - IBMs in R [https://cran.r-project.org/web/packages/ibm/index.html](https://cran.r-project.org/web/packages/ibm/index.html)  doesnt really have a unified API for users, but is a collection of examples?
  - ibmcraftr [https://cran.r-project.org/web/packages/ibmcraftr/index.html](https://cran.r-project.org/web/packages/ibmcraftr/index.html) for CTMCs, basically
  - IBMPopSim [https://github.com/DaphneGiorgi/IBMPopSim](https://github.com/DaphneGiorgi/IBMPopSim) compiles intensity functions on the fly into Rcpp and then runs. Different from us.
  - Continuous and discrete time simulation and inference of SIR/SINR on networks [https://github.com/waleedalmutiry/EpiILMCT/](https://github.com/waleedalmutiry/EpiILMCT/) [https://github.com/waleedalmutiry/EpiILM](https://github.com/waleedalmutiry/EpiILM)
  - stochastic leslie matrix models [https://mran.microsoft.com/snapshot/2017-05-24/web/packages/population/index.html](https://mran.microsoft.com/snapshot/2017-05-24/web/packages/population/index.html)
  - fish ecosystem IBM [https://www.r-pkg.org/pkg/osmose](https://www.r-pkg.org/pkg/osmose)
  - plant-plant interaction IBM [https://www.r-pkg.org/pkg/facilitation](https://www.r-pkg.org/pkg/facilitation)
  - plant model [https://www.r-pkg.org/pkg/siplab](https://www.r-pkg.org/pkg/siplab)
  - Interface to Repast [https://www.r-pkg.org/pkg/rrepast](https://www.r-pkg.org/pkg/rrepast)
  - NetLogoR [https://www.r-pkg.org/pkg/NetLogoR](https://www.r-pkg.org/pkg/NetLogoR) netlogo, but in r
      - [https://www.r-pkg.org/pkg/RNetLogo](https://www.r-pkg.org/pkg/RNetLogo) interface
  - SimEcol [http://simecol.r-forge.r-project.org/](http://simecol.r-forge.r-project.org/)
  - EpiModel [http://www.epimodel.org/](http://www.epimodel.org/) for networks
  - nosoi: just for pathogen transmission [https://slequime.github.io/nosoi/](https://slequime.github.io/nosoi/)

# Overview

The primitives in the `individual` package can be separated into variables,
processes, events and rendering. Each primitive is designed to simplify and
optimise a common challenge in the simulation of infectious disease models.

The package is designed to allow models integrate easily with other R and C++
packages. There is no compilation of model code, and primitives are made
available through `R6` [@R6] or C++ classes.

## Variables

A variable represents an attribute of each individual in the model. While
many variables will be dynamically updated throughout a simulation, they can
also remain constant. `individual` currently provides variables for categorical,
integer-based and Real-valued attributes. Example model variables could 
include an individual's infection state, age or level of immune response.

Variables expose methods for creating cohorts. Users can define
cohorts by selecting ranges of attribute values, or combining other cohorts
using efficient set operations. This simplifies much of the modelling code into 
performant, vectorised operations.

In discrete time models, users often want to model processes which occur
simultaneously each time step. They do not want variable updates from one
process to affect variable accesses in another. Variables in `individual`
achieve this with transactional updates. Every process has access to the
same variable values from the previous time step. They are able to queue updates
to a variable, but they are not applied until all processes have been run for
the current time step.

## Processes

Processes determine the dynamics which update the model from one time step to
the next. Each process will update variables and schedule events to reflect
some biological or interventional effect on each individual. Several processes
can be combined to create complex disease transmission dynamics. For example,
one process could govern the waning in each individual's immunity, while another
could introduce infection through contact with a disease vector.

Users can define processes in either R or C++. Processes are implemented as
closures in R, and a std::function in C++. This gives the user the flexibility
to use other tools in their respective ecosystems, test their processes in
isolation, and trade off between development speed for performance.

`individual` provides process generators for common infectious disease
dynamics. Users can parameterise these generators with their model variables 
to speed up development and reduce their code size. Current
generators include an `infection_age_process`, a `bernoulli_process`, a
`fixed_probability_multinomial_process` among others.

## Events

In some cases, users would like processes to execute at specific time steps.
Events provide that functionality. Events can be scheduled before or during
model simulation, they can be pre-empted, and they can be targeted to a 
cohort of individuals. Users can attach listeners to these events to define the
change to model dynamics once they are triggered. Events are useful for
modelling  interventions like vaccinations, or delayed biological events like
incubation periods.

Like processes, listeners can be defined in R or C++. `individual` also provides
listener generators like `reschedule_listener` and `update_category_listener`.

## Rendering

The rendering primitives are used to record statistics from the simulation.
The `Render` class combines statistics disparate processes into a dataframe
for further analysis.

## Simulation loop

The simulation loop combines the primitives to run a discrete-time simulation
and produce a dataframe of results. It executes processes, triggered listeners 
and then variable updates for each time step.

The simulation loop has predictable resolutions for conflicting variable update
transactions. The user specifies the order in which processes and
listeners (if triggered) are executed. Variable updates are executed in FIFO
order with later updates overwriting earlier ones. This results in later
processes and listeners taking precedence over earlier ones. Updates produced
by listeners take precedence over any updates produced from processes.

![A flow diagram for the simulation loop](sim_loop.png)

# Example

A simple SIR model

# Acknowledgements

Pete Winskill, Richard Fitzjohn, Oliver Watson

TODO

# References
