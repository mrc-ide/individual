---
title: 'individual: An R package for individual-based epidemiological models'
tags:
  - R
  - epidemiology
  - individual based
  - agent based
  - infectious disease
  - simulation
  - stochastic
authors:
  - name: Giovanni D. Charles
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

`individual` is an R package which provides users a set of useful primitive elements
for specifying individual-based models (IBMs), also called agent-based models
(ABMs), with special attention to models for infectious disease epidemiology. 
Users build models by specifying variables for each characteristic describing individuals 
in the simulated population using data structures from the package.
`individual` provides efficient methods for finding
subsets of individuals based on these variables, or cohorts. Cohorts can then
be targeted for variable updates or scheduled for events.
Variable updates queued during a time step are executed at the end of a discrete time step,
and the code places no restrictions on how individuals are allowed to interact.
These data structures are designed to provide an intuitive way for users to turn their conceptual
model of a system into executable code, which is fast and memory efficient.

# Statement of need

Complex stochastic models are crucial for many tasks 
in infectious disease epidemiology.
Such models can formalize theory, generate synthetic data, evaluate counterfactual 
scenarios, forecast trends, and be used for statistical inference [@Ganyani:2021]. IBMs are a way to 
design disaggregated simulation models, usually contrasted
with mathematical models, which may model a density or concentration
of individuals, or otherwise lump individuals with similar attributes together in some
way [@Shalizi:2006]. For modeling finite numbers of individuals with significant
between-individual heterogeneity and complex dynamics, IBMs are a natural modeling
choice when a representation using mathematical models would be cumbersome
or impossible [@Willem:2017]. Even if an aggregated representation were feasible, there are many 
reasons why an individual-based representation is to be preferred. Synthetic data
may need to produce individual level outcomes, which aggregated models by their very 
nature are unable to provide [@Tracy:2018]. Other complexities, such as when events occur after
a random delay whose distribution differs from a Markovian
one, mean even aggregated models will need to store individual completion times,
necessitating more complex simulation algorithms and data structures; in such
cases it is often more straightforward to adopt an individual-based representation
from the start.

For practical use, individual-based models 
need to balance comprehensibility and speed. A fast model whose code is only
understood by the author can be difficult to use as a basis for scientific
exploration, which necessarily requires the development of multiple models to
test hypotheses or explore sensitivity to certain assumptions. On the
other hand a clear yet slow model can be practically unusable for tasks such as
uncertainty quantification or statistical inference. `individual`
provides a toolkit for users to write models that is general enough
to cover nearly all models of practical interest using simple, standardized code which is
fast enough to be useful for computationally taxing applications.

# State of the field

There are many software libraries for epidemiological simulation,
both in R and other programming languages. However, based on our review of
existing software, no other library exists in
the R language which provides users with a set of primitive elements for defining 
epidemiological models without imposing strong restrictions upon the type of model
that may be simulated (e.g.; compartmental, network, etc.), or limiting users to particular
mathematical forms for model dynamics.

### General R packages

Generic individual-based simulation packages in R include
IBMPopSim [@Giorgi:2020], ibm [@Oliveros:2016] and ibmcraftr [@Tun:2016].
IBMPopSim provides sophisticated simulation algorithms, but requires users to input C++ code
as a string which is then compiled, making it difficult to interface with the
existing R ecosystem.

### Epidemiological R packages

EpiModel [@Jenness:2018] allows the simulation of highly detailed discrete time
models on networks, relying on the statnet [@Handcock:statnet] project for
classes and algorithms. However due to its focus on directly transmitted
diseases, `individual` may be more applicable to other epidemiological situations 
such as vector-borne diseases. In addition it does not offer an interface for
compiled code.

hybridModels [@Fernando:2020], similarly provides tools for simulating epidemics
on dynamic networks. However, it is fully implemented in R, limiting the scope for
scale and optimisation.

Other packages in R are more specialised or restrict the model's transmission dynamics 
to specific mathematical forms (e.g.; mass action). These include SimInf [@Bauer:2016], 
nosoi [@Lequime:2020], SPARSEMODr [@Mihaljevic:2021], EpiILMCT [@Almutiry:2020] and
EpiILM [@Warriyar:2020].

# Design principles

Because in many epidemiological models the most important representation of state
is a finite set of mutually exclusive values, such as the Susceptible, Infectious, Recovered
classes from the well-known SIR model [@Allen:2017], `individual` uses a bitset to store these data.
At the R level users can call set operations (union, intersection,
complement, symmetric difference, set difference) which are implemented as bitwise
operations in the C++ source. This lets users write clear, highly efficient
code for updating their model, fully in R. 

In contrast to other individual-based modeling software, where users focus on
defining a type for simulated individuals,
in `individual` users instead define variables, one for each characteristic
of the simulated population.
Individual agents are defined by their their position in each bitset giving 
membership in a variable, or element in a vector of integers or floats.
This design is similar to a component system, a design pattern to help
decouple complicated types [@Nystrom:2014]. 
Because of this disaggregated representation of state, performing
operations to find and schedule cohorts of individuals benefits from fast bitwise operators.
This state representation is (to our knowledge), novel for epidemiological simulation. 
While @Rizzi:2018 proposed using a bitset to represent the state of each
simulated individual, the population was still stored as types in an array.

`individual` uses `Rcpp` [@Rcpp] to link to C++ source code, 
which underlies the data structures exposed to the user. 
The API for `individual` uses `R6` [@R6] classes at the R level
which users call to create, update, and query variables.
`individual` also provides a C++ header-only interface which advanced users
can link to from their R package.
Users can then write their own C++ code or benefit from other packages with
a compiled interface,
significantly enhancing the extensibility of `individual`'s API, and
documentation on interacting with `individual`'s C++ API is available in
the package [documentation](https://mrc-ide.github.io/individual/articles/Performance.html).

After a user has specified all the variables in their model, dynamics
are specified by processes which run each time step, and events which can be
scheduled to update specific cohorts in the future. The simulation loop then
executes processes, fires events and updates state on each discrete time step.

![A flow diagram for the simulation loop](sim_loop.png)

# Licensing and availability

`individual` is licensed under the MIT License, with all
source code stored at [GitHub](https://github.com/mrc-ide/individual).
Requests, suggestions, and bug reports are encouraged via
filing an [issue](https://github.com/mrc-ide/individual/issues).
A general guide on how to contribute to `individual` is available at
the [package's website](https://mrc-ide.github.io/individual/articles/Contributing.html).
The automated test coverage can be found at
[codecov.io](https://app.codecov.io/gh/mrc-ide/individual/). Example code can
be found in the
[tutorial section](https://mrc-ide.github.io/individual/articles/Tutorial.html)
of the package documentation.


# Acknowledgements

We would like to thank Dr. Pete Winskill and Dr. Oliver Watson for their
encouragement, testing and contributions to the repository. And Dr. Richard
Fitzjohn for his early technical feedback and expert advice on R package
development.

# References
