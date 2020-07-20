test_that("initialisation function is called before sim is run", {
  init <- mockery::mock(function(api) {
    expect_equal(api$get_timestep(), 0)
  })
  population <- 4
  S <- State$new('S', population)
  I <- State$new('I', 0)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))
  render <- simulate(human, list(), 4, initialisation=init)
  mockery::expect_called(init, 1)
})
