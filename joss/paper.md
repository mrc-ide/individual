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
models (IBMs) are a way to design disaggregated simulation models, usually contrasted
with mathematical or equation-based models, which may model a density or concentration
of individuals, or otherwise lump individuals with similar attributes together in some
way [@Shalizi:2006]. For modeling finite numbers of individuals with significant between-individual
heterogeneity in characteristics, where both within and between individual dynamics
depend upon such characteristic in potentially complex ways, IBMs are a natural modeling
choice where a representation using mathematical models (especially compartmental models) would be cumbersome
or impossible [@Willem:2017]. Even if an aggregated representation were feasible, there are many 
reasons why an individual-based representation is to be preferred. Synthetic data
may need to include a individual level outcome data, which aggregated models by their very 
nature are unable to provide [@Tracy:2018]. Other complexities, such as when events occur after
a random delay whose distribution differs from a Markovian
one, mean even aggregated models will need to store individual completion times,
necessitating more complex simulation algorithms and data structures; in such
cases it is often more straightforward to adopt an individual-based representation
from the start.

`individual` is an R package which provides a set of useful primitive elements
for specifying their model, with special attention to the types of models
encountered in infectious disease epidemiology. Users build models using data 
structures exposed by the package to specify variables
for each individual in the simulated population. The package provides efficient methods for finding
subsets of individuals based on these variables, or cohorts. Cohorts can then
be targeted for variable updates or scheduled for events. These data structures
are designed to provide an intuitive way for users to turn their conceptual
model of a system into executable code, which is fast and memory efficient. Variable
updates queued during a time step are executed at the end of a discrete time step,
and the code places no restrictions on how individuals are allowed to interact.


# Acknowledgements

Pete Winskill, Richard Fitzjohn, Oliver Watson

TODO

# References