library(individual)

population <- 1 * 100 * 1000
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
  shift_generator(I, R, 1),
  shift_generator(R, S, 1)
)


simulation <- simulate(human, processes, 1 * 1000)
rendered <- simulation$render(human)
print('done')
