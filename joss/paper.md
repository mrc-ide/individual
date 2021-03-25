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
subsets of individuals based on these variables, which can then be scheduled to 
update all or some variables after an arbitrary delay. Models developed in `individual`
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

# Main section

A list of key references, including to other software addressing related needs. Note that the references should include full names of venues, e.g., journals and conferences, not abbreviations only understood in the context of a specific discipline. Mention (if applicable) a representative set of past or ongoing research projects using the software and recent scholarly publications enabled by it.

Notes on what the paper should have are in the [review checklist](https://joss.readthedocs.io/en/latest/review_checklist.html) and [review criteria](https://joss.readthedocs.io/en/latest/review_criteria.html#the-joss-paper).

This is what the paper should contain:

    1. Summary: Has a clear description of the high-level functionality and purpose of the software for a diverse, non-specialist audience been provided?
    2. A statement of need: Does the paper have a section titled ‘Statement of Need’ that clearly states what problems the software is designed to solve and who the target audience is?
    3. State of the field: Do the authors describe how this software compares to other commonly-used packages?
    4. Quality of writing: Is the paper well written (i.e., it does not require editing for structure, language, or writing quality)?
    5. References: Is the list of references complete, and is everything cited appropriately that should be cited (e.g., papers, datasets, software)? Do references in the text use the proper citation syntax?
    
Software docs should cover the following:

    1. A statement of need: Do the authors clearly state what problems the software is designed to solve and who the target audience is?
    2. Installation instructions: Is there a clearly-stated list of dependencies? Ideally these should be handled with an automated package management solution.
    3. Example usage: Do the authors include examples of how to use the software (ideally to solve real-world analysis problems).
    4. Functionality documentation: Is the core functionality of the software documented to a satisfactory level (e.g., API method documentation)?
    5. Automated tests: Are there automated tests or manual steps described so that the functionality of the software can be verified?
    6. Community guidelines: Are there clear guidelines for third parties wishing to 1) Contribute to the software 2) Report issues or problems with the software 3) Seek support

# Mathematics

Single dollars ($) are required for inline mathematics e.g. $f(x) = e^{\pi/x}$

Double dollars make self-standing equations:

$$\Theta(x) = \left\{\begin{array}{l}
0\textrm{ if } x < 0\cr
1\textrm{ else}
\end{array}\right.$$

You can also use plain \LaTeX for equations
\begin{equation}\label{eq:fourier}
\hat f(\omega) = \int_{-\infty}^{\infty} f(x) e^{i\omega x} dx
\end{equation}
and refer to \autoref{eq:fourier} from text.

# Citations

Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% }

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References
