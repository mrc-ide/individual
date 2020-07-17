test_that('cpp_api can be made with null parameters', {
  S <- State$new('S', 10)
  I <- State$new('I', 1)
  human <- Individual$new('test', list(S, I))
  sim <- setup_simulation(list(human), parameters = list(null_parameter = NULL))
  expect_true(TRUE)
})
