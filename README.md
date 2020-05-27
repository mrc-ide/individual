<!-- badges: start -->
[![Build Status](https://travis-ci.org/mrc-ide/individual.svg?branch=master)](https://travis-ci.org/mrc-ide/individual) [![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/mrc-ide/individual?branch=master&svg=true)](https://ci.appveyor.com/project/mrc-ide/indiviudal) [![codecov](https://codecov.io/github/mrc-ide/individual/branch/master/graphs/badge.svg)](https://codecov.io/github/mrc-ide/individual)
<!-- badges: end -->

# Individual

An R package for specifying and simulating individial based models.

This package is designed to:

  1. encourage clear and testable components for defining your individual based 
models, and
  2. provide memory efficient, fast code for executing your model

## Installation

The package can be installed from github using the "remotes" library

```R
library('remotes')
install_github('mrc-ide/vivax')
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

## The Basics

### Execution loop

### API

#### Simulation state

#### Scheduling

#### Rendering

## Usage

Please refer to the "Modelling" vignette for a tutorial on how to start making
SIR models

## Code organisation

*R/simulation.R* - Contains the main entry point and configuration for models.

*R/individual.R* - Defines classes for individuals, states, variables and constants.

*R/api.R* - Defines the R api for processes and listeners

*src/* - The C++ side of the R interface

*inst/include/State.h* - The simulation state code
*inst/include/Scheduler.h* - The scheduler code
*inst/include/Process.h* - The C++ api for user processes and listeners

*tests/* - are divided into unit and integration tests. Integration tests are
strongly recommended for large process functions and unit tests for model
calculations.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to
discuss what you would like to change.

Please make sure to update tests and documentation as appropriate.

Code reviews will be carried out in-line with RESIDE-IC's [review
process](https://reside-ic.github.io/articles/pull-requests/)

## License
[MIT](https://choosealicense.com/licenses/mit/)
