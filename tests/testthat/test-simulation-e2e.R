

test_that("deterministic model works", {
  population <- 4
  human <- individual::individual('human', population)
  states <- list(
    individual::create_state('S', population),
    individual::create_state('I', 0),
    individual::create_state('R', 0)
  )
  human$register_states(states)

  shift_generator <- function(from, to, rate) {
    return({
      i <- human$get_state_index(from)
      return list(
          states=list(
            to,
            i[1:min(rate,length(i))]
          )
        )
    })
  }

  processes <- list(
    individual::create_process(shift_generator(states[1], states[2], 2)),
    individual::create_process(shift_generator(states[2], states[3], 1)),
  )

  simulation_frame <- individual::simulate(list(human), processes, 4)
  true_df <- data.frame(
    id=rep(1:4, 4),
    timestep=rep(1:4, 1, NA, 4),
    state=c(
      rep('S', 4), #t=1
      rep('S', 2), #t=2
      rep('I', 2),
      rep('I', 3), #t=3
      'R',
      rep('I', 2), #t=4
      rep('R', 2)
    )
  )

  expect(all_equal(true_df, simulation_frame))
})
