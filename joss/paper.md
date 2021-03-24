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
 - name:  MRC Centre for Global Infectious Disease Analysis, Abdul Latif Jameel 
 Institute for Disease and Emergency Analytics (J-IDEA), Imperial College 
 London, London, UK.
   index: 1
 - name: Division of Epidemiology and Biostatistics, School of Public Health, 
 University of California, Berkeley, CA 94720, USA
   index: 2
date: 13 August 2017
bibliography: paper.bib
---

# Summary

Simulation of individual-based models (IBM) is a crucial tool for many tasks 
in public health, and especially in infectious disease epidemiology. Such models
can help formalize theory, generate synthetic data, evaluate counterfactual 
scenarios, forecast trends, and be used for statistical inference [@Tracy:2021]. 
In many cases, especially during epidemic scenarios, a variety of models must be quickly
developed to be useful for informing policy. Even under normal research 
settings, models should be easy to develop and fast to run, to facilitate the 
evaluation of various hypotheses and comparison to data.




The forces on stars, galaxies, and dark matter under external gravitational
fields lead to the dynamical evolution of structures in the universe. The orbits
of these bodies are therefore key to understanding the formation, history, and
future state of galaxies. The field of "galactic dynamics," which aims to model
the gravitating components of galaxies to study their structure and evolution,
is now well-established, commonly taught, and frequently used in astronomy.
Aside from toy problems and demonstrations, the majority of problems require
efficient numerical tools, many of which require the same base code (e.g., for
performing numerical orbit integration).

# Statement of need

`Gala` is an Astropy-affiliated Python package for galactic dynamics. Python
enables wrapping low-level languages (e.g., C) for speed without losing
flexibility or ease-of-use in the user-interface. The API for `Gala` was
designed to provide a class-based and user-friendly interface to fast (C or
Cython-optimized) implementations of common operations such as gravitational
potential and force evaluation, orbit integration, dynamical transformations,
and chaos indicators for nonlinear dynamics. `Gala` also relies heavily on and
interfaces well with the implementations of physical units and astronomical
coordinate systems in the `Astropy` package [@astropy] (`astropy.units` and
`astropy.coordinates`).

`Gala` was designed to be used by both astronomical researchers and by
students in courses on gravitational dynamics or astronomy. It has already been
used in a number of scientific publications [@Pearson:2017] and has also been
used in graduate courses on Galactic dynamics to, e.g., provide interactive
visualizations of textbook material [@Binney:2008]. The combination of speed,
design, and support for Astropy functionality in `Gala` will enable exciting
scientific explorations of forthcoming data releases from the *Gaia* mission
[@gaia] by students and experts alike.

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
