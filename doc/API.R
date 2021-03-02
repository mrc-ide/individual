## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(individual)

## ---- eval=FALSE--------------------------------------------------------------
#  bernoulli_process <- function(variable, from, to, rate) {
#    function(t) {
#      variable$queue_update(
#        to,
#        variable$get_index_of(from)$sample(rate)
#      )
#    }
#  }

## -----------------------------------------------------------------------------
bernoulli_process_time <- function(variable, int_variable, from, to, rate) {
  function(t) {
    to_move <- variable$get_index_of(from)$sample(rate)
    int_variable$queue_update(values = t, index = to_move)
    variable$queue_update(to, to_move)
  }
}

n <- 5e4
state <- CategoricalVariable$new(c('S', 'I'), rep('S', n))
time <- IntegerVariable$new(initial_values = rep(0, n))

proc <- bernoulli_process_time(variable = state,int_variable = time,from = 'S',to = 'I',rate = 0.1)

t <- 0
while (state$get_size_of('S') > 0) {
  proc(t = t)
  state$.update()
  time$.update()
  t <- t + 1
}

times <- time$get_values()
ks.test(times, rgeom(n,prob = 0.1))

## ---- class.source="bg-primary", class.output="bg-primary",eval=FALSE---------
#  simulation_loop <- function(
#    variables = list(),
#    events = list(),
#    processes = list(),
#    timesteps
#    ) {
#    if (timesteps <= 0) {
#      stop('End timestep must be > 0')
#    }
#    for (t in seq_len(timesteps)) {
#      for (process in processes) {
#        execute_any_process(process, t)
#      }
#      for (event in events) {
#        event$.process()
#      }
#      for (variable in variables) {
#        variable$.update()
#      }
#      for (event in events) {
#        event$.tick()
#      }
#    }
#  }

