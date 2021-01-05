test_that("Premature render works", {
  render <- Render$new(2)
  render$add('human_S_count', 10, 1)
  render$add('human_I_count', 100, 1)
  render$add('human_R_count', 0, 1)
  rendered <- render$to_dataframe()
  true_render <- data.frame(
    timestep = c(1, 2),
    human_S_count = c(10, NA),
    human_I_count = c(100, NA),
    human_R_count = c(0, NA)
  )
  expect_mapequal(true_render, rendered)
})

test_that("Prefab state counts work correctly", {
  state <- CategoricalVariable(c('S', 'I'), c(rep('S', 10), rep('I', 100)))

  render <- Render$new(2)

  render_states <- categorical_count_renderer_process(
    renderer,
    state,
    c('S', 'I')
  )

  execute_process(render_states, 1)

  state$queue_update('I', c(3, 6))
  state$.update()

  execute_process(render_states, 2)

  rendered <- render$to_dataframe()
  expected <- data.frame(
    timestep = c(1, 2),
    S_count = c(10, 8),
    I_count = c(100, 102),
    R_count = c(0, 0)
  )
  expect_mapequal(rendered, expected)
})

test_that("Prefab variable summaries work correctly", {
  size <- 110
  sequence <- DoubleVariable$new(seq_len(size))
  render <- Render$new(2)

  render_variables <- variable_mean_renderer_process(
    'sequence',
    sequence
  )

  execute_process(render_variables, 1)

  sequence$queue_update(c((1:50) * 2, 51:110))
  state$.update()

  execute_process(render_variables, 2)

  rendered <- render$to_dataframe()
  expected <- data.frame(
    timestep = c(1, 2),
    sequence = c(55.5, 67.09091)
  )
  expect_mapequal(rendered, expected)
})
