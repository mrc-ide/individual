test_that("Premature render works", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))

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
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))

  render <- Render$new(2)
  sim <- setup_simulation(list(human), renderer = render)

  render_states <- state_count_renderer_process(
    human$name,
    c(S$name, I$name, R$name)
  )

  execute_process(render_states, sim$cpp_api)

  sim$r_api$queue_state_update(human, I, c(3, 6))
  state_apply_updates(sim$state)
  scheduler_tick(sim$scheduler)

  execute_process(render_states, sim$cpp_api)

  rendered <- render$to_dataframe()
  expected <- data.frame(
    timestep = c(1, 2),
    human_S_count = c(10, 8),
    human_I_count = c(100, 102),
    human_R_count = c(0, 0)
  )
  expect_mapequal(rendered, expected)
})

test_that("Prefab variable summaries work correctly", {
  size <- 110
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  sequence <- Variable$new('sequence', seq_len(size))
  sequence_2 <- Variable$new('sequence_2', seq_len(size) * 10)
  human <- Individual$new('human', list(S, I, R), list(sequence, sequence_2))
  render <- Render$new(2)
  sim <- setup_simulation(list(human), renderer = render)

  render_variables <- variable_mean_renderer_process(
    human$name,
    c(sequence$name, sequence_2$name)
  )

  execute_process(render_variables, sim$cpp_api)

  sim$r_api$queue_variable_update(human, sequence, c((1:50) * 2, 51:110))
  state_apply_updates(sim$state)
  scheduler_tick(sim$scheduler)

  execute_process(render_variables, sim$cpp_api)

  rendered <- render$to_dataframe()
  expected <- data.frame(
    timestep = c(1, 2),
    human_sequence_mean = c(55.5, 67.09091),
    human_sequence_2_mean = c(555, 555)
  )
  expect_mapequal(rendered, expected)
})
