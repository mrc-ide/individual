expect_targeted_listener <- function(listener, call, t, target) {
  mock_args <- mockery::mock_args(listener)
  expect_equal(mock_args[[call]][[1]], t)
  expect_equal(mock_args[[call]][[2]]$to_vector(), target)
}
