test_that("incorrect initialisations fail", {
  expect_error(
    Individual$new('test', list(State$new('S', -10), State$new('I', 1))),
    '*'
  )

  expect_error(
    Individual$new('test', list(State$new('S', 1), State$new('S', 2))),
    '*'
  )
})
