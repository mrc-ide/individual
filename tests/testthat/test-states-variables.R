test_that("getting the state works", {
  S <- State$new('S', 10)
  human <- Individual$new('test', list(S))
  state <- create_state(list(human))
  scheduler <- new.env()
  render <- new.env()
  cpp_api <- create_process_api(state, scheduler, list(), render)
  api <- SimAPI$new(cpp_api, scheduler, list(), render)

  expect_setequal(api$get_state(human, list(S)), seq(10))

  I <- State$new('I', 100)
  human <- Individual$new('test', list(S, I))
  state <- create_state(list(human))
  cpp_api <- create_process_api(state, scheduler, list(), render)
  api <- SimAPI$new(cpp_api, scheduler, list(), render)

  expect_setequal(api$get_state(human, list(I)), seq(100) + 10)
})

test_that("Getting multiple states works", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 20)
  human <- Individual$new('test', list(S, I, R))

  state <- create_state(list(human))
  scheduler <- new.env()
  render <- new.env()
  cpp_api <- create_process_api(state, scheduler, list(), render)
  api <- SimAPI$new(cpp_api, scheduler, list(), render)
  expect_setequal(api$get_state(human, list(S, R)), c(seq(10), seq(20) + 110))
})

test_that("getting a non registered state index fails", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('test', list(S, I))

  state <- create_state(list(human))
  scheduler <- new.env()
  render <- new.env()
  cpp_api <- create_process_api(state, scheduler, list(), render)
  api <- SimAPI$new(cpp_api, scheduler, list(), render)

  expect_error(
    api$get_state(human, list(R)),
    '*'
  )
})

test_that("getting variables works", {
  S <- State$new('S', 10)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  sequence_2 <- Variable$new('sequence 2', function(size) seq_len(size) + 10)
  human <- Individual$new('test', list(S), variables=list(sequence, sequence_2))

  state <- create_state(list(human))
  scheduler <- new.env()
  render <- new.env()
  cpp_api <- create_process_api(state, scheduler, list(), render)
  api <- SimAPI$new(cpp_api, scheduler, list(), render)

  expect_equal(api$get_variable(human, sequence), 1:10)
  expect_equal(api$get_variable(human, sequence_2), (1:10) + 10)
})
