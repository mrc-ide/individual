test_that("Premature render works", {
  render <- Render$new(2)
  render$render('human_S_count', 10, 1)
  render$render('human_I_count', 100, 1)
  render$render('human_R_count', 0, 1)
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
  state <- CategoricalVariable$new(c('S', 'I'), c(rep('S', 10), rep('I', 100)))

  render <- Render$new(2)

  render_states <- categorical_count_renderer_process(
    render,
    state,
    c('S', 'I')
  )

  render_states(1)

  state$queue_update('I', c(3, 6))
  state$.update()

  render_states(2)

  rendered <- render$to_dataframe()
  expected <- data.frame(
    timestep = c(1, 2),
    S_count = c(10, 8),
    I_count = c(100, 102)
  )
  expect_mapequal(rendered, expected)
})

test_that("Render default works", {
  render <- Render$new(3)
  render$set_default('human_S_count', 100)
  render$render('human_S_count', 10, 2)
  true_render <- data.frame(
    timestep = c(1, 2, 3),
    human_S_count = c(100, 10, 100)
  )
  rendered <- render$to_dataframe()
  expect_mapequal(true_render, rendered)
})
