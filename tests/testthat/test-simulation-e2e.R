
test_that("empty simulation exits gracefully", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', S, I, R)
  simulation <- simulate(human, list(), 4)
  true_df <- data.frame(
    timestep=as.numeric(rep(0:4, 1, NA, 4)),
    state=factor(c(
      rep('S', 20)
    ), levels = c('S', 'I', 'R'))
  )
  expect_mapequal(true_df, simulation$render(human))

  simulation <- simulate(human, list(), 0)
  true_df <- data.frame(
    timestep=0,
    state=factor(c(
      rep('S', 4)
    ), levels = c('S', 'I', 'R'))
  )
  expect_mapequal(true_df, simulation$render(human))

  expect_error(
    simulate(human, list(), -1),
    '*'
  )
})

test_that("deterministic model works", {
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', S, I, R)

  shift_generator <- function(from, to, rate) {
    return(function(frame) {
      from_state <- frame$get_state(human, from)
      StateUpdate$new(
        human,
        from_state[seq_len(min(rate,length(from_state)))],
        to
      )
    })
  }

  processes <- list(
    shift_generator(S, I, 2),
    shift_generator(I, R, 1)
  )

  simulation <- simulate(human, processes, 4)
  true_df <- data.frame(
    timestep=as.numeric(rep(0:4, 1, NA, 4)),
    state=factor(c(
      rep('S', 4), #t=0
      rep('S', 2), #t=1
      rep('I', 2),
      rep('I', 3), #t=2
      'R',
      rep('I', 2), #t=3
      rep('R', 2),
      rep('I', 1), #t=4
      rep('R', 3)
    ), levels = c('S', 'I', 'R'))
  )
  rendered <- simulation$render(human)
  expect_mapequal(
    sort_simulation(true_df),
    sort_simulation(rendered)
  )
})
