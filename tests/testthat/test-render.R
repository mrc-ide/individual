test_that("Premature render works", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))

  render <- Render$new(list(human), 2)
  frame <- mock_simulation_frame(list(
    human = list(
      S = seq_len(10),
      I = seq_len(100) + 10,
      R = c()
    )
  ))
  render$update(frame, 1)
  rendered <- render$to_dataframe()
  true_render <- data.frame(
    timestep = c(1, 2),
    human_S_count = c(10, NA),
    human_I_count = c(100, NA),
    human_R_count = c(0, NA)
  )
  expect_mapequal(true_render, rendered)
})

test_that("Simulation can render state counts", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  human <- Individual$new('human', list(S, I, R))

  render <- Render$new(list(human), 2)
  render$update(mock_simulation_frame(list(
    human = list(
      S = seq_len(10),
      I = seq_len(100) + 10,
      R = c()
    )
  )), 1)
  render$update(mock_simulation_frame(list(
    human = list(
      S = c(2, 4:10),
      I = c(1, 3, 11:110),
      R = c()
    )
  )), 2)
  rendered <- render$to_dataframe()
  true_render <- data.frame(
    timestep = c(1, 2),
    human_S_count = c(10, 8),
    human_I_count = c(100, 102),
    human_R_count = c(0, 0)
  )
  expect_mapequal(true_render, rendered)
})

test_that("Simulation can render variable summaries", {
  S <- State$new('S', 10)
  I <- State$new('I', 100)
  R <- State$new('R', 0)
  sequence <- Variable$new('sequence', function(size) seq_len(size))
  sequence_2 <- Variable$new('sequence_2', function(size) seq_len(size) * 10)
  human <- Individual$new('human', list(S, I, R), list(sequence, sequence_2))

  render <- Render$new(
    list(human),
    renderers = list(function(frame) {
      list(
        sequence_mean = mean(frame$get_variable(human, sequence)),
        sequence_2_mean = mean(frame$get_variable(human, sequence_2))
      )
    }),
    2
  )

  render$update(mock_simulation_frame(list(
    human = list(
      S = seq_len(10),
      I = seq_len(100) + 10,
      R = c(),
      sequence = seq_len(110),
      sequence_2 = seq_len(110) * 10
    )
  )), 1)

  render$update(mock_simulation_frame(list(
    human = list(
      S = c(2, 4:10),
      I = c(1, 3, 11:110),
      R = c(),
      sequence = c((1:50) * 2, 51:110),
      sequence_2 = seq_len(110) * 10
    )
  )), 2)

  rendered <- render$to_dataframe()
  true_render <- data.frame(
    timestep = c(1, 2),
    human_S_count = c(10, 8),
    human_I_count = c(100, 102),
    human_R_count = c(0, 0),
    sequence_mean = c(55.5, 67.09091),
    sequence_2_mean = c(555, 555)
  )
  expect_mapequal(true_render, rendered)
})
