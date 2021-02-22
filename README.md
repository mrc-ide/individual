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

You start by defining your model. This helps others clearly see the structure of
your model.

```R
population <- 1000

# States
S <- State$new('S', population)
I <- State$new('I', 0)
R <- State$new('R', 0)

# Variables
immunity <- Variable$new('immunity', function(size) runif(size, 0, .2))
age <- Variable$new('age', function(size) rexp(size, rate=1/10))

# Individuals
human <- Individual$new(
  'human',
  list(S, I, R),
  variables = list(immunity, age)
)
```

Then you define processes. These are functions that describe how Variables and
States change throughout your simulation.

```R
recovery_event <- Event$new('recovery')
recovery_event$add_listener(function(api, target) {
  api$queue_state_update(human, R, target)
})

recovery_process <- function(api) {
  infected <- api$get_state(human, I)
  already_scheduled <- api$get_scheduled(recovery_event)
  infected <- setdiff(infected, already_scheduled) 
  to_recover <- infected[runif(length(infected)) < .5]
  api$schedule(recovery_event, to_recover, 5)
}
```

You can then pass your complete model to the main simulation loop:

```R
simulate(human, list(recovery_process), 5*365, events=(recovery_event))
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
death_process <- function(api) {
  # reset the state and all variables
  # ...
}

infection_process <- function(api) {
  # update the state and variables to represent an infection
  # ...
}

simulate(human, list(infection_process, death_process), 5*365)
```

### API

Processes and listeners interact with the simulation through the API.

#### Simulation state

Processes can view the simulation through:

```
api$get_state
api$get_variable
```

and update it through:

```
api$queue_state_update
api$queue_variable_update
```

Updates are applied after all the processes are run.

#### Scheduling

Processes can view the schedule with:

```
api$get_scheduled
```

and update it through:

```
api$schedule
api$clear_schedule
```

#### Rendering

Processes can write to the simulation output using

```
api$render
```

All the API methods are documented in the package reference section.

## Usage

Please refer to the vignettes for tutorials on how to start making
epi models

## Contributing

Thank you! Please refer to the vignette on Contributing for info on how to
contribute :)

## License
[MIT](https://choosealicense.com/licenses/mit/)
