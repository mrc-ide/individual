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
This representation of discrete finite variables is (to our knowledge),
novel for epidemiological simulation. While @Rizzi:2018 proposed using a bitset
to represent each agent, the agents were still stored as types an array.

In contrast to other individual based modeling software, users define variables,
one for each attribute of an individual, rather than defining a type for the 
simulated individuals. Individual agents are only defined by their unique id,
their position in bitset that defines membership to a finite variable, or the
element of a vector of integers or floats for unbounded or real variables.
This architecture is reminiscent of the entity component system design
Each variable type (categorical, integer, or double) is managed by a data type with
both an R and C++ interface.

`individual` also provides a C++ header-only interface which advanced users
can link to from their R package. The C++ interface allows a user to interact
with the C++ types directly, if the R interface remains too slow for their use case.
This means that users can link to other R packages that expose a C or C++ interface,
significantly enhancing the extensibility of both `individual`'s R and C++ API.


# State of the field

## Non R Software

There are currently a variety of software libraries for epidemiological simulation,
both in the R language and other programming languages. However, we are not yet aware
of a similar package in any language written especially for epidemiologists which allows 
simulation of generic individual-based infectious processes by providing users 
with a set of specialized data types and methods without making assumptions about 
model structure (e.g. network, metapopulation, lattice grid, etc).

A wide variety of simulation software exist for generic agent-based models. Among the best
known are Repast [@North:2013], Mesa [@Masad:2015], and NetLogo [@Wilensky:1999].
In the Julia programming language, Agents.jl [@Vahdati:2019] provides an efficient
platform for specifying and simulation agent-based models. Unlike `individual`,
in Agents.jl a user specifies a custom type that defines a single agent, whereas
in `individual` users define variables that implicitly specify the possible model
states. Pathogen.jl is a package for individual based simulation of SEIR, 
SEI, SIR, and SI type epidemic models, where infection, incubation, and recovery 
events may depend on specific characteristics of each individual (or pairs, in
the case of infection). Nonetheless it is restricted to these types of epidemic models,
and does not support arbitrary waiting time distributions.

Various software libraries also exist specifically for epimiological simulation.
EpiFire [@Hladish:2012] and SimpactCyan [@Liesenborgs:2019] are C++ libraries
for simulation of epidemics on networks. The Numerus Model Builder [@Getz:2018] 
and NOVA [@Salter:2013] platforms use a specialized scripting language for users
to define models. EMOD [@Bershteyn:2018] is a highly successful and complex modeling 
software in C++ which relies on JSON configuration files to interact with.

## R Software

### General R Packages

Several R packages provide interfaces to other software libraries.
The nlrx package provides an R interface to NetLogo [@Salecker:2019] to set up reproducible
experiements and focuses on sensitivity analysis, and RNetLogo is a more basic interface [@Thiele:2014].
For the Repast library, RRepast provides a sophisticated interface [@Garcia:2016].

Among software written specifically for R, there are several generic modeling platforms
which support agent based models. For discrete event simulation simmeR [@Ucar:2017] 
develops a similar `R6` interface with linked C++ but whose API is set up for
modeling the types of sytstems commonly encountered in operations research, such as
queueing processes, but would be difficult to use for epidemiological applications.
SpaDES [@Mcintire:2021] is a generic discrete event simulator designed for large
ecological models on raster landscapes, but has a learning curve.
For general models, NetLogoR [@Bauduin:2019] is a complete translation of NetLogo into R.

ibm [@Oliveros:2016] provides examples of simple, extensible, individual based models
in R but does not provide a generic interface. ibmcraftr [@Tun:2016] allows creation
of discretized CTMC simulations in R.

IBMPopSim [@Giorgi:2020] is a sophisticated R package that allows simulation of 
general continuous time non-Markovian individual based models for demography, 
based on a thinning (also known as uniformization or Jensen's method) algorithm to simulate exact trajectories. 
However, it requires users to input C++ code as a string into the R interface 
which are compiled to give the rate function for each event, meaning use of 
other R packages to aid simulation is difficult.

simecol [@Petzoldt:2007] provides classes to implement and distribute ecological
models, but the focus is on structuring software projects to enhance reproducibility rather
than providing tools for simulation. 

### Epidemiological R Packages

There are a variety of packages in R designed to simulate epidemic processes on
networks. The SimInf package [@Bauer:2016] is able to run very large CTMC simulations
of epidemics on networks taking advantage of R's C interface to preform most computations in C.
However it doesn't support arbitrary waiting times, continuous 
or unbounded integer attributes for individuals, and has a highly structured API.
The hybridModels package [@Fernando:2020] also implements network-structured
CTMC models, but is fully implemented in R. epinet [@Groendyke:2018] and EpiDynamics [@Baquero:2020]
are other R packages with similar functionality. nosoi [@Lequime:2020] is an 
agent-based simulation framework designed to simulate transmission chains to generate 
synthetic data for phylogenetic analysis, with specialized data structures for this purpose.

EpiILMCT [@Almutiry:2020] and EpiILM [@Warriyar:2020] are R packages implementing 
simulation and inference for continuous time models on networks or spatial grids,
in continuous and discrete time, respectively, with computationally intensive routines
coded in Fortran. However, rate functions for events have highly restricted functional
forms and cannot interface with other R packages.

EpiModel [@Jenness:2018] is perhaps the closest R software we have reviewed, allowing simulation
of highly detailed discrete time models on networks, using functionality from the 
statnet [@Handcock:statnet] project for network classes and algorithms. However
the simulation API requires some time to become familiar with, and due to the 
focus on networks, `individual` can be easier to get started with for other types
of models (or vector borne diseases). In addition the C++ interface of `individual`
allows more straightforward manipulation of its underlying data structures, whereas
the network package [@Butts:2008] which is the basis for EpiModel uses a less well
documented C API.

Why we're awesome:

individual is great compared to non-R software because you can use anything else in R
as part of your model, including R's support for rasters, networks, data tables, etc etc

individual is great compared to R software because it allows execution of arbitrary
R code within the updating processes, and provides an Rcpp interface for advanced users
to link to for writing their own C++ process, potentially linking to outside C++ libraries.
We also don't have restrictions on the types of functions allowed for infection
(e.g.; mass action).

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
also remain constant. `individual` currently provides a variety variables for
suited for modelling seperate aspects of the model. Examples might include a
categorical variable specifying each individual's health status, a Real valued
variable giving their level of immune response, or an integer variable
giving their position on a spatial network.

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
the current time step. This means all agents update synchronously where
conflicts, multiple updates scheduled for a single agent, are resolved by the
process execution order.

### Categorical Variable

Most epidemiological models require the use of categorical variables, that is,
an attribute for each individual taking a value in some discrete, finite set.
Most well known compartmental models are represented solely in terms of 
categorical variables, for example, the Susceptible, Infectious, and Recovered 
classes in the classic SIR model.

There can be an unlimited number of categorical variable objects, but every 
individual can only take on a single value for each of them at any time. 
When using multiple categorical variables, the allowed states for each
individual is a contingency table whose margins are given by the set of states
of each individual categorical variable. In this way, one could model, for 
example, a SIR model where individuals are also partitioned by discrete age group
with two categorical variable objects.

In `individual` users may create a categorical variable corresponding to a set
of mutually exclusive states in R using the `CategoricalVariable` `R6` class.
The internal C++ API stores a bitset object for each value in the set of states.
The class implements common set operations (union, intersection, complement,
symmetric difference, set difference) as bitwise operations, making queries 
to find some subset of individuals extremely fast.

### Integer Variable

For discrete variables with state spaces which are unbounded, or large enough
to be impractical to store a bitset for each value, the `IntegerVariable` object
stores state as a vector of integers of length equal to the size of the simulated
population. This object supports finding and returning subsets of individuals
as bitset objects which can be used with the set operations of `CategoricalVariable`.

### Double Variable

In certain cases, such as modeling of immunity or other values which are best
represented as continuous quantities, a variable storing real valued quantities
is needed. The `DoubleVariable` stores its state as a vector of double precision
floating point values. Like `IntegerVariable`, it supports finding subsets of
individuals in some interval and returning bitsets giving their indices.

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

Because processes can schedule variable updates or events depending on the state
of variables in a completely general way, waiting times for events in 
`individual` can follow any distribution with a computable hazard function.
Distributions of time to event can depend on time, individual level attributes
of multiple individuals, and the time elapsed since an event was enabled. In 
fact enabling time dependency can be either implemented with a supplemental
variable to explicitly track for each individual that elapsed time, or with
a scheduled event, which can be cancled if interrupted prior to completion.
Either way, `individual` can simulate general non-Markovian processes.

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

To demonstrate how to use `individual` we will build and simulate a simple SIR
model. For details on the mathematical construction stochastic epidemic models,
please consult @Allen:2017. This example follows the 
[package vignette](https://mrc-ide.github.io/individual/articles/Tutorial.html).

The epidemic will be simulated in a population of 1000, where 5 persons are 
initially infectious, whose indices are randomly sampled. The effective contact
rate $\beta$ will be a function of the deterministic $R_{0}$ and recovery rate 
$\gamma$. We also specify `dt`, which is the size of the intended time step. 
Because in `individual` all time steps are of unit duration, by adjusting transition
rates appropriately by `dt` the unit time step can be scaled to any desired size.
Because the maximum time is `tmax` the number of discrete time steps taken is 
`tmax/dt`.

```{.r}
N <- 1e3 # population size
I0 <- 5 # initial number of infectious individuals
S0 <- N - I0 # initial number of susceptible individuals

dt <- 0.1 # size of time step
tmax <- 100 # maximum simulation time
steps <- tmax/dt 

gamma <- 1/10 # recovery rate
R0 <- 2.5 
beta <- R0 * gamma

# sample who is initially infectious
health_states <- c("S","I","R")
health_states_t0 <- rep("S",N)
health_states_t0[sample.int(n = N,size = I0)] <- "I"
```

Then the model's state is defined by a single `CategoricalVariable` object.

```{.r}
health <- CategoricalVariable$new(categories = health_states,initial_values = health_states_t0)
```

Next we define the infection process. This is a function that takes only a single 
argument, `t`, the current time step (unused here, but can model time-dependent 
processes, such as seasonality or school holiday). Within the function, we get 
the current number of infectious individuals, then calculate the per-capita 
force of infection on each susceptible person, $\lambda=\beta I/N$. Next we get 
a `Bitset` containing those susceptible individuals and use the sample method to 
randomly select those who will be infected on this time step. The probability is 
given by $1-e^{-\lambda\Delta t}$. This is the same as the CDF of an exponential 
random variate so we use the base R function `pexp` to compute that quantity. 
Finally, we queue a state update for those individuals who were sampled.

```{.r}
infection_process <- function(t){
  I <- health$get_size_of("I")
  foi <- beta * I/N
  S <- health$get_index_of("S")
  S$sample(rate = pexp(q = foi * dt))
  health$queue_update(value = "I",index = S)
}
```

Now we need to model recovery. For geometrically distributed infectious periods, 
we could use another process that randomly samples some individuals each time 
step to recover, but we’ll use a `TargetedEvent` to illustrate their use. The 
recovery event is quite simple. The “listener” which is a function 
that is called when the event triggers, taking two arguments, the time step it 
is called, and a `Bitset` of scheduled individuals. Those individuals are 
scheduled for a state update.

```{.r}
recovery_event <- TargetedEvent$new(population_size = N)
recovery_event$add_listener(function(t, target) {
  health$queue_update("R", target)
})
```

Finally, we need to define a recovery process that queues future recovery events. 
We first get `Bitset` objects of those currently infectious individuals 
and those who have already been scheduled for a recovery. Then, using bitwise 
operations, we get the intersection of already infectious persons with persons 
who have not been scheduled, precisely those who need to have recovery times 
sampled and scheduled. We sample those times from `rgeom`, where the probability 
for recovery is $1-e^{-\gamma\Delta t}$.

We note at this point would be possible to queue the recovery event at the same 
time the infection state update was made, but we separate event and process for 
additional illustration of how the package works.

```{.r}
recovery_process <- function(t){
  I <- health$get_index_of("I")
  already_scheduled <- recovery_event$get_scheduled()
  I$and(already_scheduled$not())
  rec_times <- rgeom(n = I$size(),prob = pexp(q = gamma * dt)) + 1
  recovery_event$schedule(target = I,delay = rec_times)
}
```

The last thing to do before simulating the model is rendering output to plot. 
We use a `Render` object which stores output from the model each time step. 

```{.r}
health_render <- Render$new(timesteps = steps)
health_render_process <- categorical_count_renderer_process(
  renderer = health_render,
  variable = health,
  categories = health_states
)
```

Finally, the simulation can be run by passing objects to the `simulation_loop` function.

```{.r}
simulation_loop(
  variables = list(health),
  events = list(recovery_event),
  processes = list(infection_process,recovery_process,health_render_process),
  timesteps = steps
)
```

By default, `Render` object return `data.frame` objects which can be easily
plotted and analyzed.

![A simulated SIR model trajectory](sir.png)

# Acknowledgements

Pete Winskill, Richard Fitzjohn, Oliver Watson

TODO

# References