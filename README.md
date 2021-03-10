<!-- badges: start -->
[![R build status](https://github.com/mrc-ide/individaul/workflows/R-CMD-check/badge.svg)](https://github.com/mrc-ide/individual/actions)
<!-- badges: end -->

# Individual

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

This package gives you a framework for creating new individual models.

You start by defining your variables. This helps others clearly see the structure of
your model.

```R
population <- 4
state <- CategoricalVariable$new(c('S', 'I', 'R'), rep('S', population))
immunity <- DoubleVariable$new(runif(population, 0, .2))
age <- DoubleVariable$new(rexp(population, rate=1/10))
```

Then you define processes. These are functions that describe how variables change in your simulation.

```R
recovery_event <- TargetedEvent$new('recovery')
recovery_event$add_listener(function(timestep, target) {
  state$queue_update('R', target)
})

recovery_process <- function(timestep) {
  infected <- state$get_index_of('I')
  already_scheduled <- recovery_event$get_scheduled()
  infected <- infected$and(already_scheduled$not())
  to_recover <- infected$sample(.5)
  recovery_event$schedule(to_recover, delay = 5)
}
```

You can then pass your complete model to the main simulation loop:

```R
simulation_loop(
  variables = list(state, immunity, age),
  processes = list(recovery_process),
  events = list(recovery_event),
  timesteps=100
)
```

### Execution loop

There are two types of processes:

1. Plain old processes. These run every timestep.
1. Event listeners. These are triggered by events.

The type of process that is most appropriate will depend on your modelling
style.

All processes work off the same simulation state. All state transitions and
variable updates are only applied *after* every process has run.

When processes create conflicting state updates, the last update will take
precedence. For example, if you have a death process and an infection process.
You will want to pass the death process last to the simulation loop to make sure
those changes persist:

```R
death_process <- function(timestep) {
  # reset the state and all variables
  # ...
}

infection_process <- function(timestep) {
  # update the state and variables to represent an infection
  # ...
}

simulation_loop(
  processes = list(death_process, infection_process),
  timesteps=100
)
```

## Usage

Please refer to the vignettes for tutorials on how to start making
epi models. We recommend first reading `vignette("Tutorial")` which describes
how to simulate a simple SIR model in "individual", and later `vignette("API")`
which describes in detail how to use the data structures in "individual" to
build more complicated models.

## Contributing

Thank you! Please refer to the vignette on vignette("Contributing") for info on how to
contribute :)

## License
[MIT](https://choosealicense.com/licenses/mit/)
