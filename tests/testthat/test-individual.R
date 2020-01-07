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

test_that("individuals are readonly", {
  i <- Individual$new('test', list(State$new('S', 1)))
  expect_error(i$name <- 'not test', '*')
})
